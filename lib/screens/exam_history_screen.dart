import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/exam_history_entry.dart';
import '../services/history_store.dart';
import '../services/local_history_persistence.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  List<ExamHistoryEntry> _items = const <ExamHistoryEntry>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    LocalHistoryPersistence.addUserChangeListener(_handleUserChanged);
    _load();
  }

  @override
  void dispose() {
    LocalHistoryPersistence.removeUserChangeListener(_handleUserChanged);
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() => _loading = true);
    }
    final entries = await HistoryStore.load();
    if (!mounted) return;
    setState(() {
      _items = entries;
      _loading = false;
    });
  }

  void _handleUserChanged(String _) {
    if (!mounted) {
      return;
    }
    _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer l\'historique examens ?'),
        content: const Text(
          'Cette action supprimera toutes les épreuves sauvegardées sur cet appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HistoryStore.clear();
      await _load();
    }
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} – '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Widget _buildSubjectBreakdown(ExamHistoryEntry entry, TextTheme textTheme) {
    final subjects = <String>{
      ...entry.correctBySubject.keys,
      ...entry.totalBySubject.keys,
      ...entry.scoresBruts.keys,
      ...entry.scoresPonderes.keys,
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Par matière',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        ...subjects.map((subject) {
          final total = entry.totalBySubject[subject] ?? 0;
          final correct = entry.correctBySubject[subject] ?? 0;
          final raw = entry.scoresBruts[subject] ?? 0;
          final weighted = entry.scoresPonderes[subject] ?? 0;
          final ratio = total > 0 ? (correct / total * 100).clamp(0, 100) : null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  total > 0
                      ? '${correct.toString().padLeft(2, '0')}/$total'
                      : '--',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Text(
                  'Brut $raw',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pondéré $weighted',
                  style: textTheme.bodyMedium,
                ),
                if (ratio != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${ratio.toStringAsFixed(0)}%',
                    style: textTheme.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique — Examens'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Effacer l\'historique',
            ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Aucune épreuve enregistrée pour l\'instant. Lance un examen pour voir les résultats détaillés ici.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final entry = _items[index];
              final status = _statusFor(entry);
                      final weakSubjects = entry.weakSubjects();
                      final ratio = entry.overallSuccessRatio();
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDate(entry.date),
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total pondéré : ${entry.totalPondere}',
                                          style: textTheme.bodyLarge,
                                        ),
                                        if (ratio != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Réussite globale : ${(ratio * 100).toStringAsFixed(0)}%',
                                            style: textTheme.bodyLarge,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      status.label,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: status.labelColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor: status.backgroundColor,
                                  ),
                                ],
                              ),
                              if (weakSubjects.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Points à renforcer',
                                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    for (final subject in weakSubjects)
                                      Chip(
                                        label: Text(subject),
                                        backgroundColor: theme.colorScheme.surfaceVariant,
                                      ),
                                  ],
                                ),
                              ],
                              _buildSubjectBreakdown(entry, textTheme),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  _EntryStatus _statusFor(ExamHistoryEntry entry) {
    if (entry.abandoned) {
      final color = Colors.orange.shade200;
      return _EntryStatus(
        label: 'Abandonné',
        backgroundColor: color,
        labelColor: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87,
      );
    }
    if (entry.success) {
      final color = Colors.green.shade200;
      return _EntryStatus(
        label: 'Réussi',
        backgroundColor: color,
        labelColor: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87,
      );
    }
    final color = Colors.red.shade200;
    return _EntryStatus(
      label: 'Échec',
      backgroundColor: color,
      labelColor: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : Colors.black87,
    );
  }
}

class _EntryStatus {
  final String label;
  final Color backgroundColor;
  final Color labelColor;

  const _EntryStatus({
    required this.label,
    required this.backgroundColor,
    required this.labelColor,
  });
}
