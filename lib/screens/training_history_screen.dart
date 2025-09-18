import 'package:flutter/material.dart';
import '../models/training_history_entry.dart';
import '../services/local_history_persistence.dart';
import '../services/training_history_store.dart';

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

  Future<void> _load() async {
    if (mounted) {
      setState(() => _loading = true);
    }
    final list = await TrainingHistoryStore.load();
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
        title: const Text('Effacer l’historique entraînement ?'),
        content: const Text('Cette action supprimera toutes les tentatives sauvegardées.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique — Entraînement'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(onPressed: _clearAll, icon: const Icon(Icons.delete_forever)),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Aucune tentative enregistrée pour l’instant.'))
              : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final e = _items[i];

                String statusText;
                Color statusColor;
                if (e.abandoned) {
                  statusText = 'Abandonné';
                  statusColor = Colors.orange.shade200;
                } else if (e.success) {
                  statusText = 'Validé';
                  statusColor = Colors.green.shade200;
                } else {
                  statusText = 'Échoué';
                  statusColor = Colors.red.shade200;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${e.subject} • ${e.chapter}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Chip(label: Text(statusText), backgroundColor: statusColor),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${_fmt(e.date)} • durée ${e.durationMinutes} min'),
                        const SizedBox(height: 6),
                        Text('Score : ${e.correct}/${e.total} — brut ${e.rawScore} • pondéré ${e.weightedScore}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
