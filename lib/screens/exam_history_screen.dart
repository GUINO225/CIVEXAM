import 'package:flutter/material.dart';
import '../models/exam_history_entry.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/history_store.dart';
import '../services/local_history_persistence.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  List<ExamHistoryEntry> _items = const [];
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
    setState(() => _loading = true);
    final list = await HistoryStore.load();
    if (!mounted) return;
    setState(() {
      _items = list;
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Effacer l’historique ?'),
        content: const Text('Cette action supprimera tous les résultats sauvegardés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Effacer')),
        ],
      ),
    );
    if (ok == true) {
      await HistoryStore.clear();
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
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final textTheme = theme.textTheme;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Historique des examens'),
            actions: [
              if (_items.isNotEmpty)
                IconButton(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Effacer l’historique',
                )
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(
                      child: Text('Aucun examen enregistré pour le moment.'))
                  : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final e = _items[i];
                    final weak = e.weakSubjects();
                    Color chipBg;
                    Color chipFg;
                    String chipText;
                    if (e.abandoned) {
                      chipBg = cs.tertiaryContainer;
                      chipFg = cs.onTertiaryContainer;
                      chipText = 'Abandonné';
                    } else if (e.success) {
                      chipBg = cs.primaryContainer;
                      chipFg = cs.onPrimaryContainer;
                      chipText = 'Réussi';
                    } else {
                      chipBg = cs.errorContainer;
                      chipFg = cs.onErrorContainer;
                      chipText = 'Échoué';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Examen du ${_fmt(e.date)}',
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    chipText,
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: chipFg,
                                    ),
                                  ),
                                  backgroundColor: chipBg,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Total pondéré : ${e.totalPondere}',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Divider(height: 16),
                            Text(
                              'Détails par matière :',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            for (final s in e.scoresBruts.keys) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      s,
                                      style: textTheme.bodyLarge,
                                    ),
                                  ),
                                  Text(
                                    'Brut ${e.scoresBruts[s]} • Pondéré ${e.scoresPonderes[s]}',
                                    style: textTheme.bodyLarge,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${e.correctBySubject[s]}/${e.totalBySubject[s]})',
                                    style: textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (weak.isNotEmpty) ...[
                              const Divider(height: 16),
                              Text(
                                'À renforcer : ${weak.join(', ')}',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: cs.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
