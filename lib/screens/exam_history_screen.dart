import 'package:flutter/material.dart';
import '../models/exam_history_entry.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/history_store.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  List<ExamHistoryEntry> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await HistoryStore.load();
    if (!mounted) return;
    setState(() => _items = list);
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
        final cs = Theme.of(context).colorScheme;
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
          body: _items.isEmpty
              ? const Center(
                  child: Text('Aucun examen enregistré pour le moment.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final e = _items[i];
                    final weak = e.weakSubjects();
                    Color chipBg;
                    String chipText;
                    if (e.abandoned) {
                      chipBg = cs.tertiaryContainer;
                      chipText = 'Abandonné';
                    } else if (e.success) {
                      chipBg = cs.primaryContainer;
                      chipText = 'Réussi';
                    } else {
                      chipBg = cs.errorContainer;
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
                                    child: Text('Examen du ${_fmt(e.date)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700))),
                                Chip(
                                    label: Text(chipText),
                                    backgroundColor: chipBg),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Total pondéré : ${e.totalPondere}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const Divider(height: 16),
                            const Text('Détails par matière :',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            for (final s in e.scoresBruts.keys) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(s)),
                                  Text(
                                      'Brut ${e.scoresBruts[s]} • Pondéré ${e.scoresPonderes[s]}'),
                                  const SizedBox(width: 8),
                                  Text(
                                      '(${e.correctBySubject[s]}/${e.totalBySubject[s]})'),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (weak.isNotEmpty) ...[
                              const Divider(height: 16),
                              Text(
                                'À renforcer : ${weak.join(', ')}',
                                style: TextStyle(
                                    color: cs.tertiary,
                                    fontWeight: FontWeight.w600),
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
