import 'package:flutter/material.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = true;
  List<Attempt> attempts = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HistoryService.load();
    if (!mounted) return;
    setState(() {
      attempts = data.reversed.toList();
      loading = false;
    });
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    return '${m}m ${ss}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Vider',
            onPressed: attempts.isEmpty ? null : () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Vider l’historique ?'),
                  content: const Text('Cette action est irréversible.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Vider')),
                  ],
                ),
              );
              if (ok == true) {
                await HistoryService.clear();
                if (!mounted) return;
                setState(() => attempts = const []);
              }
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : attempts.isEmpty
              ? const Center(child: Text('Aucun essai enregistré.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: attempts.length,
                  itemBuilder: (_, i) {
                    final a = attempts[i];
                    final pct = (a.score / a.total * 100).toStringAsFixed(0);
                    return Card(
                      child: ListTile(
                        title: Text('${a.subject} > ${a.chapter}'),
                        subtitle: Text('Score: ${a.score}/${a.total} • ${pct}% • Durée: ${_formatDuration(a.durationSeconds)}'),
                        trailing: Text(
                          '${a.timestamp.day.toString().padLeft(2, '0')}/${a.timestamp.month.toString().padLeft(2, '0')}/${a.timestamp.year}'
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
