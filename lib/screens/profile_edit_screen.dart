import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/leaderboard_entry.dart';
import '../services/user_profile_service.dart';
import '../services/leaderboard_store.dart';
import '../services/competition_service.dart';
import 'dashboard_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _pseudoController = TextEditingController();
  final _professionController = TextEditingController();
  final _profileService = UserProfileService();
  String? _avatarPath;
  String? _initialPseudo;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _firstNameController.text = prefs.getString('first_name') ?? '';
    _lastNameController.text = prefs.getString('last_name') ?? '';
    _professionController.text = prefs.getString('profession') ?? '';
    setState(() {
      _avatarPath = prefs.getString('avatar_path');
    });
    _pseudoController.text = prefs.getString('nickname') ?? '';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final profile = await _profileService.loadProfile(uid);
      _pseudoController.text = profile?.nickname ?? _pseudoController.text;
    }
    _initialPseudo = _pseudoController.text;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _pseudoController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_name', _firstNameController.text);
    await prefs.setString('last_name', _lastNameController.text);
    await prefs.setString('profession', _professionController.text);
    await prefs.setString('nickname', _pseudoController.text);
    if (_avatarPath != null) {
      await prefs.setString('avatar_path', _avatarPath!);
    }
    final profile = UserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      nickname: _pseudoController.text,
      profession: _professionController.text,
      photoUrl: _avatarPath ?? '',
    );
    await _profileService.saveProfile(profile);

    if (_initialPseudo != _pseudoController.text) {
      final entries = await LeaderboardStore.all();
      await LeaderboardStore.clear();
      for (final e in entries) {
        await LeaderboardStore.add(LeaderboardEntry(
          userId: e.userId,
          name: _pseudoController.text,
          mode: e.mode,
          subject: e.subject,
          chapter: e.chapter,
          total: e.total,
          correct: e.correct,
          wrong: e.wrong,
          blank: e.blank,
          durationSec: e.durationSec,
          percent: e.percent,
          dateIso: e.dateIso,
        ));
      }
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final compService = CompetitionService();
        final entry = await compService.entryForUser(uid);
        if (entry != null) {
          final updatedEntry = LeaderboardEntry(
            userId: entry.userId,
            name: _pseudoController.text,
            mode: entry.mode,
            subject: entry.subject,
            chapter: entry.chapter,
            total: entry.total,
            correct: entry.correct,
            wrong: entry.wrong,
            blank: entry.blank,
            durationSec: entry.durationSec,
            percent: entry.percent,
            dateIso: entry.dateIso,
          );
          await compService.saveEntry(updatedEntry);
        }
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldController,
                decoration:
                    const InputDecoration(labelText: 'Ancien mot de passe'),
                obscureText: true,
              ),
              TextField(
                controller: newController,
                decoration:
                    const InputDecoration(labelText: 'Nouveau mot de passe'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.email == null) {
                  Navigator.of(dialogContext).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                      const SnackBar(content: Text('Utilisateur non connecté')));
                  return;
                }
                try {
                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldController.text,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newController.text);
                  Navigator.of(dialogContext).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                      const SnackBar(content: Text('Mot de passe mis à jour')));
                } on FirebaseAuthException catch (e) {
                  Navigator.of(dialogContext).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    SnackBar(
                      content: Text(e.message ??
                          'Erreur lors du changement de mot de passe'),
                    ),
                  );
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: InkWell(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                    child: _avatarPath == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pseudoController,
                decoration: const InputDecoration(labelText: 'Pseudonyme'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _professionController,
                decoration: const InputDecoration(labelText: 'Profession'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Enregistrer'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showChangePasswordDialog,
                child: const Text('Changer le mot de passe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

