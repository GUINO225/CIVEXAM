import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LeaderboardEntry? _entry;
  int? _rank;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final entries = await CompetitionService().topEntries(limit: 1000);
    final index = entries.indexWhere((e) => e.userId == uid);
    if (!mounted) return;
    setState(() {
      _entry = index >= 0 ? entries[index] : null;
      _rank = index >= 0 ? index + 1 : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entry == null
              ? const Center(child: Text('Aucune donnée de compétition'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nom : ${_entry!.name}',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                          'Score : ${_entry!.percent.toStringAsFixed(1)}% (${_entry!.correct}/${_entry!.total})'),
                      const SizedBox(height: 8),
                      if (_rank != null)
                        Text('Classement global : $_rank'),
                    ],
                  ),
                ),
    );
  }
}
