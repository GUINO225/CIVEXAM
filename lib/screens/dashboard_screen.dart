import 'dart:convert';
import 'dart:typed_data';

import 'package:civexam_pro/utils/io_stub.dart'
    if (dart.library.io) 'dart:io' as io;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';
import 'profile_edit_screen.dart';

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
        photoUrl: '');
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

  Future<void> _pickPhoto() async {
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
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );
    if (source == null) return;

    final file = await picker.pickImage(source: source, maxWidth: 600);
    if (file == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseStorage.instance.ref('profiles/$uid.jpg');
    if (kIsWeb) {
      final Uint8List bytes = await file.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    }
    if (!kIsWeb) {
      await ref.putFile(io.File(file.path) as dynamic);
    }
    final url = await ref.getDownloadURL();

    final profile = UserProfile(
        firstName: _profile?.firstName ?? '',
        lastName: _profile?.lastName ?? '',
        nickname: _profile?.nickname ?? '',
        profession: _profile?.profession ?? '',
        photoUrl: url);
    await _profileService.saveProfile(profile);
    if (!mounted) return;
    await _load();
  }

  Widget _buildAvatar() {
    final image = _resolveAvatar();
    return CircleAvatar(
      radius: 30,
      backgroundImage: image,
      child: image != null ? null : const Icon(Icons.person),
    );
  }

  ImageProvider? _resolveAvatar() {
    final photoUrl = _profile?.photoUrl;
    if (photoUrl == null || photoUrl.isEmpty) {
      return null;
    }
    if (kIsWeb) {
      if (photoUrl.startsWith('http')) {
        return NetworkImage(photoUrl);
      }
      final base64Data = _extractBase64(photoUrl);
      if (base64Data != null) {
        return MemoryImage(base64Decode(base64Data));
      }
      return null;
    }
    if (photoUrl.startsWith('http')) {
      return NetworkImage(photoUrl);
    }
    if (!kIsWeb) {
      final file = io.File(photoUrl);
      if (file.existsSync()) {
        return FileImage(file as dynamic);
      }
    }
    final base64Data = _extractBase64(photoUrl);
    if (base64Data != null) {
      return MemoryImage(base64Decode(base64Data));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon dashboard'),
        actions: [
          IconButton(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.camera_alt),
              tooltip: 'Changer la photo'),
          IconButton(
              onPressed: _openProfileEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier le profil'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entry == null
              ? const Center(child: Text('Aucune donnée de compétition'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Image.asset('assets/images/logo_splash.png', height: 150),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildAvatar(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Pseudo : ${_profile?.nickname ?? ''}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Prénom'),
                        subtitle: Text(_profile?.firstName ?? ''),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Nom'),
                        subtitle: Text(_profile?.lastName ?? ''),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.work),
                        title: const Text('Profession'),
                        subtitle: Text(_profile?.profession ?? ''),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.emoji_events),
                        title: const Text('Score'),
                        subtitle: Text(
                            '${_entry!.percent.toStringAsFixed(1)}% (${_entry!.correct}/${_entry!.total})'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.leaderboard),
                        title: const Text('Classement global'),
                        subtitle: Text('${_rank ?? 'Non classé'}'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
