import 'dart:convert';
import 'dart:typed_data';

import 'package:civexam_pro/utils/io_stub.dart'
    if (dart.library.io) 'dart:io' as io;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Uint8List? _avatarBytes;
  String? _photoUrl;
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
    final storedPath = prefs.getString('avatar_path');
    Uint8List? storedBytes;
    if (kIsWeb) {
      final encoded = prefs.getString('avatar_bytes');
      if (encoded != null && encoded.isNotEmpty) {
        try {
          storedBytes = base64Decode(encoded);
        } catch (e, st) {
          debugPrint('Failed to decode stored avatar bytes: $e\n$st');
        }
      }
    }
    _pseudoController.text = prefs.getString('nickname') ?? '';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    String? storedPhotoUrl;
    if (uid != null) {
      try {
        final profile = await _profileService.loadProfile(uid);
        if (profile != null) {
          if (profile.nickname.isNotEmpty) {
            _pseudoController.text = profile.nickname;
          }
          storedPhotoUrl = profile.photoUrl;
        }
      } catch (e, st) {
        debugPrint('Failed to load profile: $e\n$st');
      }
    }
    if (!mounted) return;
    setState(() {
      _avatarPath = storedPath;
      _avatarBytes = storedBytes;
      _photoUrl = storedPhotoUrl;
    });
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
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        setState(() {
          _avatarBytes = bytes;
          _avatarPath = null;
          _photoUrl = null;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _avatarPath = picked.path;
          _avatarBytes = null;
          _photoUrl = null;
        });
      }
    }
  }

  String _buildPhotoUrlForStorage() {
    if (_avatarBytes != null) {
      return 'base64:${base64Encode(_avatarBytes!)}';
    }
    if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      return _avatarPath!;
    }
    return _photoUrl ?? '';
  }

  Widget _buildAvatarCircle() {
    final image = _currentAvatarImage();
    return CircleAvatar(
      radius: 50,
      backgroundImage: image,
      child: image != null ? null : const Icon(Icons.person, size: 50),
    );
  }

  ImageProvider? _currentAvatarImage() {
    if (_avatarBytes != null) {
      return MemoryImage(_avatarBytes!);
    }
    if (kIsWeb) {
      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        if (_photoUrl!.startsWith('http')) {
          return NetworkImage(_photoUrl!);
        }
        final base64Data = _extractBase64(_photoUrl!);
        if (base64Data != null) {
          return MemoryImage(base64Decode(base64Data));
        }
      }
      return null;
    }
    if (!kIsWeb) {
      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        final file = io.File(_avatarPath!);
        if (file.existsSync()) {
          return FileImage(file as dynamic);
        }
      }
    }
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      if (_photoUrl!.startsWith('http')) {
        return NetworkImage(_photoUrl!);
      }
      final base64Data = _extractBase64(_photoUrl!);
      if (base64Data != null) {
        return MemoryImage(base64Decode(base64Data));
      }
      if (!kIsWeb) {
        final file = io.File(_photoUrl!);
        if (file.existsSync()) {
          return FileImage(file as dynamic);
        }
      }
    }
    return null;
  }

  String? _extractBase64(String input) {
    if (input.startsWith('data:image')) {
      final commaIndex = input.indexOf(',');
      if (commaIndex != -1) {
        return input.substring(commaIndex + 1);
      }
    }
    if (input.startsWith('base64:')) {
      return input.substring('base64:'.length);
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_name', _firstNameController.text);
    await prefs.setString('last_name', _lastNameController.text);
    await prefs.setString('profession', _professionController.text);
    await prefs.setString('nickname', _pseudoController.text);
    if (kIsWeb) {
      if (_avatarBytes != null) {
        await prefs.setString('avatar_bytes', base64Encode(_avatarBytes!));
      } else {
        await prefs.remove('avatar_bytes');
      }
    } else {
      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        await prefs.setString('avatar_path', _avatarPath!);
      } else {
        await prefs.remove('avatar_path');
      }
    }
    final profile = UserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      nickname: _pseudoController.text,
      profession: _professionController.text,
      photoUrl: _buildPhotoUrlForStorage(),
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
                  child: _buildAvatarCircle(),
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

