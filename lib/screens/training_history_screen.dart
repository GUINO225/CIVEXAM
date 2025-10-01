import 'package:flutter/material.dart';

import '../models/training_history_entry.dart';
import '../services/local_history_persistence.dart';
import '../services/training_history_store.dart';

/// Palette cohérente avec les autres écrans (violet + surface claire).
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

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  List<TrainingHistoryEntry> _items = const [];
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
    final list = await TrainingHistoryStore.load();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Effacer l’historique entraînement ?'),
        content: const Text(
          'Cette action supprimera toutes les tentatives sauvegardées.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Effacer')),
        ],
      ),
    );
    if (ok == true) {
      await TrainingHistoryStore.clear();
      await _load();
    }
  }

  String _fmt(DateTime d) {
    final local = d.toLocal();
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
    );

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historique — Entraînement'),
          actions: [
            if (_items.isNotEmpty)
              IconButton(
                onPressed: _clearAll,
                tooltip: 'Effacer tout',
                icon: const Icon(Icons.delete_forever),
              ),
            IconButton(
              onPressed: _load,
              tooltip: 'Rafraîchir',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? _EmptyState(onRetry: _load)
            : RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final e = _items[i];
              return _HistoryTile(
                title: '${e.subject} • ${e.chapter}',
                dateTimeLabel: '${_fmt(e.date)} • durée ${e.durationMinutes} min',
                scoreLabel:
                'Score : ${e.correct}/${e.total} — brut ${e.rawScore} • pondéré ${e.weightedScore}',
                status: e.abandoned
                    ? _HistoryStatus.abandoned
                    : (e.success ? _HistoryStatus.passed : _HistoryStatus.failed),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ---- UI réutilisable ----

enum _HistoryStatus { passed, failed, abandoned }

class _HistoryTile extends StatelessWidget {
  final String title;
  final String dateTimeLabel;
  final String scoreLabel;
  final _HistoryStatus status;

  const _HistoryTile({
    required this.title,
    required this.dateTimeLabel,
    required this.scoreLabel,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Style du statut
    late final String statusText;
    late final Color pillBg;
    late final Color pillFg;
    switch (status) {
      case _HistoryStatus.passed:
        statusText = 'Validé';
        pillBg = const Color(0xFFDFF3FF); // doux/clair
        pillFg = _Brand.primaryDark;
        break;
      case _HistoryStatus.failed:
        statusText = 'Échoué';
        pillBg = const Color(0xFFFFE3E3);
        pillFg = const Color(0xFFB71C1C);
        break;
      case _HistoryStatus.abandoned:
        statusText = 'Abandonné';
        pillBg = const Color(0xFFFFF1DB);
        pillFg = const Color(0xFF8D4F00);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: _Brand.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Brand.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + statut
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: pillFg.withOpacity(.25)),
                ),
                child: Text(
                  statusText,
                  style: tt.labelLarge?.copyWith(
                    color: pillFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(dateTimeLabel, style: tt.bodyMedium?.copyWith(color: _Brand.textMuted)),
          const SizedBox(height: 6),
          Text(scoreLabel, style: tt.bodyMedium),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_toggle_off, size: 48, color: _Brand.secondary),
            const SizedBox(height: 8),
            Text('Aucune tentative enregistrée pour l’instant.',
                textAlign: TextAlign.center,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Lance un entraînement pour voir tes résultats ici.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: _Brand.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}
