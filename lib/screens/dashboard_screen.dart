// lib/screens/dashboard_screen.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:civexam_pro/utils/io_stub.dart'
    if (dart.library.io) 'dart:io' as io;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';
import 'profile_edit_screen.dart';
import '../utils/arcade_level_utils.dart';
import '../widgets/arcade_badge_chip.dart';
import '../widgets/play_themed_scaffold.dart';

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

    UserProfile? profile;
    try {
      profile = await _profileService.loadProfile(uid);
    } catch (e, st) {
      debugPrint('Failed to load profile for $uid: $e\n$st');
      profile = null;
    }

    profile ??= UserProfile(
      firstName: '',
      lastName: '',
      nickname: entry?.name ?? '',
      profession: '',
      photoUrl: '',
      arcadeLevel: normalizeArcadeLevel(entry?.arcadeLevel),
    );

    if (!mounted) return;
    setState(() {
      _entry = entry;
      _profile = profile;
      _rank = rank;
      _loading = false;
    });
  }

  Future<void> _openProfileEdit() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
    if (updated == true && mounted) {
      await _load();
    }
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
      const SnackBar(
        content: Text(
          'La sélection de photo n\'est pas disponible sur cette plateforme.',
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    if (!_isImagePickerSupported()) {
      _showImagePickerUnavailableMessage();
      return;
    }

    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galerie'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Caméra'),
