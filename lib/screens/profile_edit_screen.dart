import 'dart:convert';
import 'dart:typed_data';

import 'package:civexam_pro/utils/io_stub.dart'
if (dart.library.io) 'dart:io' as io;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/leaderboard_entry.dart';
import '../services/user_profile_service.dart';
import '../services/competition_service.dart';
import '../services/private_scores_store.dart';
import 'dashboard_screen.dart';
import '../utils/arcade_level_utils.dart';
import '../widgets/play_bottom_nav_bar.dart';
import 'play_screen.dart';

/// Palette cohérente (violet + surface claire)
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
  String _arcadeLevel = '';

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
    String? remoteNickname;
    String? remoteArcadeLevel;
    if (uid != null) {
      try {
        final profile = await _profileService.loadProfile(uid);
        if (profile != null) {
          if (profile.firstName.isNotEmpty) _firstNameController.text = profile.firstName;
          if (profile.lastName.isNotEmpty) _lastNameController.text = profile.lastName;
          if (profile.profession.isNotEmpty) _professionController.text = profile.profession;
          if (profile.nickname.isNotEmpty) remoteNickname = profile.nickname;
          storedPhotoUrl = profile.photoUrl;
          remoteArcadeLevel = profile.arcadeLevel;
        }
      } catch (e, st) {
        debugPrint('Failed to load profile: $e\n$st');
      }
    }
    if (remoteNickname != null) {
      _pseudoController.text = remoteNickname;
    }
    if (!mounted) return;
    setState(() {
      _avatarPath = storedPath;
      _avatarBytes = storedBytes;
      if (remoteNickname != null) _pseudoController.text = remoteNickname;
      _photoUrl = storedPhotoUrl ?? _photoUrl;
      _arcadeLevel = normalizeArcadeLevel(remoteArcadeLevel ?? _arcadeLevel);
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

  bool _isImagePickerSupported() {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  void _showImagePickerUnavailableMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("La sélection d'image n'est pas disponible sur cette plateforme.")),
    );
  }

  Future<void> _pickImage() async {
    if (!_isImagePickerSupported()) {
      _showImagePickerUnavailableMessage();
      return;
    }
    final picker = ImagePicker();
    XFile? picked;
    try {
      picked = await picker.pickImage(source: ImageSource.gallery);
    } on MissingPluginException catch (e, st) {
      debugPrint('Image picker plugin missing: $e\n$st');
      _showImagePickerUnavailableMessage();
      return;
    }
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _avatarBytes = bytes;
        _avatarPath = null;
        _photoUrl = null;
      });
    } else {
      final avatarPath = picked.path;
      if (!mounted) return;
      setState(() {
        _avatarPath = avatarPath;
        _avatarBytes = null;
        _photoUrl = null;
      });
    }
  }

  String _buildPhotoUrlForStorage() {
    if (_avatarBytes != null) return 'base64:${base64Encode(_avatarBytes!)}';
    if (_avatarPath != null && _avatarPath!.isNotEmpty) return _avatarPath!;
    return _photoUrl ?? '';
  }

  ImageProvider? _currentAvatarImage() {
    if (_avatarBytes != null) return MemoryImage(_avatarBytes!);

    if (kIsWeb) {
      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        if (_photoUrl!.startsWith('http')) return NetworkImage(_photoUrl!);
        final base64Data = _extractBase64(_photoUrl!);
        if (base64Data != null) return MemoryImage(base64Decode(base64Data));
      }
      return null;
    }

    if (!kIsWeb && _avatarPath != null && _avatarPath!.isNotEmpty) {
      final file = io.File(_avatarPath!);
      if (file.existsSync()) return FileImage(file as dynamic);
    }

    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      if (_photoUrl!.startsWith('http')) return NetworkImage(_photoUrl!);
      final base64Data = _extractBase64(_photoUrl!);
      if (base64Data != null) return MemoryImage(base64Decode(base64Data));
      if (!kIsWeb) {
        final file = io.File(_photoUrl!);
        if (file.existsSync()) return FileImage(file as dynamic);
      }
    }
    return null;
  }

  String? _extractBase64(String input) {
    if (input.startsWith('data:image')) {
      final commaIndex = input.indexOf(',');
      if (commaIndex != -1) return input.substring(commaIndex + 1);
    }
    if (input.startsWith('base64:')) {
      return input.substring('base64:'.length);
    }
    return null;
  }

  Widget _buildAvatarCard() {
    final image = _currentAvatarImage();
    return Container(
      decoration: BoxDecoration(
        color: _Brand.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Brand.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(100),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: _Brand.surface,
              backgroundImage: image,
              child: image != null
                  ? null
                  : const Icon(Icons.person, size: 48, color: _Brand.primary),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Changer la photo'),
          ),
        ],
      ),
    );
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
      arcadeLevel: normalizeArcadeLevel(_arcadeLevel),
    );
    await _profileService.saveProfile(profile);

    if (_initialPseudo != _pseudoController.text) {
      final entries = await PrivateScoresStore.load();
      await PrivateScoresStore.clear();
      for (final e in entries) {
        await PrivateScoresStore.add(LeaderboardEntry(
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
          arcadeLevel: e.arcadeLevel,
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
            arcadeLevel: entry.arcadeLevel,
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
                decoration: const InputDecoration(labelText: 'Ancien mot de passe'),
                obscureText: true,
              ),
              TextField(
                controller: newController,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Annuler')),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.email == null) {
                  Navigator.of(dialogContext).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(outerContext)
                      .showSnackBar(const SnackBar(content: Text('Utilisateur non connecté')));
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
                  ScaffoldMessenger.of(outerContext)
                      .showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour')));
                } on FirebaseAuthException catch (e) {
                  Navigator.of(dialogContext).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    SnackBar(content: Text(e.message ?? 'Erreur lors du changement de mot de passe')),
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
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: _Brand.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Brand.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Brand.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Brand.primary),
        ),
        filled: true,
        fillColor: _Brand.card,
        labelStyle: base.textTheme.bodyMedium?.copyWith(color: _Brand.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _Brand.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      dividerColor: _Brand.border,
    );

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildAvatarCard(),
                  const SizedBox(height: 16),
                  // Carte formulaire
                  Container(
                    decoration: BoxDecoration(
                      color: _Brand.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _Brand.border),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Prénom'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Nom'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pseudoController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Pseudonyme'),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Choisis un pseudonyme' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _professionController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(labelText: 'Profession'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _showChangePasswordDialog, child: const Text('Changer le mot de passe')),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final Color brand = theme.colorScheme.primary;
            final Color onBrand = theme.colorScheme.onPrimary;
            final Color navHighlight =
                Color.alphaBlend(onBrand.withOpacity(0.14), brand);
            return PlayBottomNavBar(
              destinations: playNavDestinations,
              selectedIndex: 4,
              backgroundColor: brand,
              highlightColor: navHighlight,
              foregroundColor: onBrand,
              onDestinationSelected: (index) {
                if (index == 4) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayScreen(initialIndex: index),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
