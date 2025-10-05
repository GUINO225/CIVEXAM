import 'dart:ui'; // FontFeature

import 'package:flutter/material.dart';

import '../models/exam_history_entry.dart';
import '../services/history_store.dart';
import '../services/local_history_persistence.dart';
import '../widgets/play_bottom_nav_bar.dart';
import 'play_screen.dart';

/// Palette cohérente (violet + surface claire)
class _Brand {
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFF5B4DE1);
  static const secondary = Color(0xFF7F6AF8);
  static const surface = Color(0xFFF7F5FF);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF1E1E28);
  static const textMuted = Color(0xFF6E6B7A);
  static const border = Color(0xFFE6E1F9);
}

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

  void _handleUserChanged(String _) {
    if (!mounted) return;
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final entries = await HistoryStore.load();
    if (!mounted) return;
    setState(() {
      _items = entries;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Effacer l’historique examens ?'),
        content: const Text(
          'Cette action supprimera toutes les épreuves sauvegardées sur cet appareil.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Effacer')),
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
    return '${two(local.day)}/${two(local.month)}/${local.year} – ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final themed = base.copyWith(
      scaffoldBackgroundColor: _Brand.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _Brand.primary,
        brightness: base.brightness,
      ).copyWith(
        primary: _Brand.primary,
        surface: _Brand.surface,
        background: _Brand.surface,
        onSurface: _Brand.text,
        onPrimary: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _Brand.text,
        displayColor: _Brand.text,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: _Brand.surface,
        foregroundColor: _Brand.text,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: _Brand.border,
      chipTheme: base.chipTheme.copyWith(side: const BorderSide(color: _Brand.border)),
    );

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historique — Examens'),
          actions: [
            if (_items.isNotEmpty)
              IconButton(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Effacer l’historique',
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
            ? const _EmptyState()
            : RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = _items[index];
              final status = _statusFor(entry);
              final weakSubjects = entry.weakSubjects();
              final ratio = entry.overallSuccessRatio();

              return Container(
                decoration: BoxDecoration(
                  color: _Brand.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _Brand.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entête : date + totals + statut
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(entry.date),
                                style: themed.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Total pondéré : ${entry.totalPondere}',
                                  style: themed.textTheme.bodyLarge),
                              if (ratio != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Réussite globale : ${(ratio * 100).toStringAsFixed(0)}%',
                                  style: themed.textTheme.bodyLarge,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: status.backgroundColor,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: status.labelColor.withOpacity(.25)),
                          ),
                          child: Text(
                            status.label,
                            style: themed.textTheme.labelLarge?.copyWith(
                              color: status.labelColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Points à renforcer
                    if (weakSubjects.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Points à renforcer',
                          style: themed.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in weakSubjects)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _Brand.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: _Brand.border),
                              ),
                              child: Text(s, style: themed.textTheme.labelLarge),
                            ),
                        ],
                      ),
                    ],

                    // Détail par matière
                    _buildSubjectBreakdown(entry, themed.textTheme),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final Color brand = theme.colorScheme.primary;
            final Color onBrand = theme.colorScheme.onPrimary;
            final Color navHighlight =
                Color.alphaBlend(onBrand.withOpacity(0.14), brand);
            return PlayBottomNavBar(
              destinations: playNavDestinations,
              selectedIndex: 3,
              backgroundColor: brand,
              highlightColor: navHighlight,
              foregroundColor: onBrand,
              onDestinationSelected: (index) {
                if (index == 3) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayScreen(initialIndex: index),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  _EntryStatus _statusFor(ExamHistoryEntry entry) {
    if (entry.abandoned) {
      return const _EntryStatus(
        label: 'Abandonné',
        backgroundColor: Color(0xFFFFF1DB),
        labelColor: Color(0xFF8D4F00),
      );
    }
    if (entry.success) {
      return const _EntryStatus(
        label: 'Réussi',
        backgroundColor: Color(0xFFDFF3FF),
        labelColor: _Brand.primaryDark,
      );
    }
    return const _EntryStatus(
      label: 'Échec',
      backgroundColor: Color(0xFFFFE3E3),
      labelColor: Color(0xFFB71C1C),
    );
  }

  // ---- Sous-bloc : détail par matière
  Widget _buildSubjectBreakdown(ExamHistoryEntry entry, TextTheme textTheme) {
    final subjects = <String>{
      ...entry.correctBySubject.keys,
      ...entry.totalBySubject.keys,
      ...entry.scoresBruts.keys,
      ...entry.scoresPonderes.keys,
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (subjects.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Par matière', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...subjects.map((subject) {
            final total = entry.totalBySubject[subject] ?? 0;
            final correct = entry.correctBySubject[subject] ?? 0;
            final raw = entry.scoresBruts[subject] ?? 0;
            final weighted = entry.scoresPonderes[subject] ?? 0;
            final ratio = total > 0 ? (correct / total * 100).clamp(0, 100) : null;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _Brand.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _Brand.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(subject, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text(total > 0 ? '${correct.toString().padLeft(2, '0')}/$total' : '--',
                      style: textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Text('Brut $raw', style: textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Text('Pondéré $weighted', style: textTheme.bodyMedium),
                  if (ratio != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      '${ratio.toStringAsFixed(0)}%',
                      style: textTheme.bodyMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48, color: _Brand.secondary),
            const SizedBox(height: 8),
            Text('Aucune épreuve enregistrée pour l’instant.',
                textAlign: TextAlign.center,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Lance un examen pour voir les résultats détaillés ici.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: _Brand.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
