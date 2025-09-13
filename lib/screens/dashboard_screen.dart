import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LeaderboardEntry? _entry;
  int? _rank;
  UserProfile? _profile;
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
    final results = await Future.wait([
      CompetitionService().topEntries(limit: 1000),
      UserProfileService.loadProfile(uid),
    ]);
    final entries = results[0] as List<LeaderboardEntry>;
    final profile = results[1] as UserProfile?;
    final index = entries.indexWhere((e) => e.userId == uid);
    if (!mounted) return;
    setState(() {
      _entry = index >= 0 ? entries[index] : null;
      _rank = index >= 0 ? index + 1 : null;
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_profile != null)
                    Text('Nom : ${_profile!.name}',
                        style: Theme.of(context).textTheme.titleLarge),
                  if (_entry != null) ...[
                    const SizedBox(height: 8),
                    Text(
                        'Score : ${_entry!.percent.toStringAsFixed(1)}% (${_entry!.correct}/${_entry!.total})'),
                    const SizedBox(height: 8),
                    if (_rank != null)
                      Text('Classement global : $_rank'),
                  ] else ...[
                    const SizedBox(height: 8),
                    const Text('Aucune donnée de compétition'),
                  ]
                ],
              ),
            ),
    );
  }
}
