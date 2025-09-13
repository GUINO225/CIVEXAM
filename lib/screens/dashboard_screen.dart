import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _profileService = UserProfileService();
  LeaderboardEntry? _entry;
  UserProfile? _profile;
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
      setState(() => _loading = false);
      return;
    }
    final service = CompetitionService();
    final entries = await service.topEntries(limit: 1000);
    var index = entries.indexWhere((e) => e.userId == uid);
    LeaderboardEntry? entry;
    int? rank;
    if (index >= 0) {
      entry = entries[index];
      rank = index + 1;
    } else {
      entry = await service.entryForUser(uid);
    }
    final profile = await _profileService.loadProfile(uid);
    if (!mounted) return;
    setState(() {
      _entry = entry;
      _profile = profile;
      _rank = rank;
      _loading = false;
    });
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _entry?.name ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty) {
      final profile = UserProfile(
        firstName: _profile?.firstName ?? '',
        lastName: _profile?.lastName ?? '',
        nickname: newName.trim(),
        profession: _profile?.profession ?? '',
        photoUrl: _profile?.photoUrl ?? '',
      );
      await _profileService.saveProfile(profile);
      if (!mounted) return;
      await _load();
    }
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
                      Row(
                        children: [
                          Expanded(
                            child: Text('Nom : ${_entry!.name}',
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                          IconButton(
                              onPressed: _editName,
                              icon: const Icon(Icons.edit)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Score : ${_entry!.percent.toStringAsFixed(1)}% (${_entry!.correct}/${_entry!.total})'),
                      const SizedBox(height: 8),
                      Text('Classement global : ${_rank ?? 'Non classé'}'),
                    ],
                  ),
                ),
    );
  }
}
