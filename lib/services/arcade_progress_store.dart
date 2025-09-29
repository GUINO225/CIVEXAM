import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../utils/arcade_level_utils.dart';
import 'user_profile_service.dart';

class ArcadeProgressData {
  final String levelLabel;
  final UserProfile? profile;

  const ArcadeProgressData({
    required this.levelLabel,
    this.profile,
  });

  int get resumeIndex {
    final nextLevelNumber = ArcadeProgressStore.levelNumberFromLabel(levelLabel);
    return nextLevelNumber > 0 ? nextLevelNumber - 1 : 0;
  }

  ArcadeProgressData copyWith({
    String? levelLabel,
    UserProfile? profile,
  }) {
    return ArcadeProgressData(
      levelLabel: levelLabel ?? this.levelLabel,
      profile: profile ?? this.profile,
    );
  }
}

class ArcadeProgressStore {
  static const String _prefsLevelLabelKey = 'arcade.progress.levelLabel';

  final UserProfileService _profileService;

  ArcadeProgressStore({UserProfileService? profileService})
      : _profileService = profileService ?? UserProfileService();

  Future<ArcadeProgressData> load() async {
    final prefs = await SharedPreferences.getInstance();
    var storedLabel = prefs.getString(_prefsLevelLabelKey);

    UserProfile? profile;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        profile = await _profileService.loadProfile(uid);
      } catch (e, st) {
        debugPrint('Failed to load profile for $uid: $e\n$st');
      }
    }

    if (profile != null) {
      storedLabel = normalizeArcadeLevel(profile.arcadeLevel);
      await prefs.setString(_prefsLevelLabelKey, storedLabel);
    } else {
      storedLabel = normalizeArcadeLevel(storedLabel);
      await prefs.setString(_prefsLevelLabelKey, storedLabel);
    }

    return ArcadeProgressData(levelLabel: storedLabel, profile: profile);
  }

  Future<ArcadeProgressData> save({
    required String levelLabel,
    UserProfile? baseProfile,
  }) async {
    final normalizedLabel = normalizeArcadeLevel(levelLabel);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLevelLabelKey, normalizedLabel);

    UserProfile? resolvedProfile = baseProfile;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      resolvedProfile ??= await _safeLoadProfile(uid);
      final nextProfile = UserProfile(
        firstName: resolvedProfile?.firstName ?? '',
        lastName: resolvedProfile?.lastName ?? '',
        nickname: resolvedProfile?.nickname ?? '',
        profession: resolvedProfile?.profession ?? '',
        photoUrl: resolvedProfile?.photoUrl ?? '',
        arcadeLevel: normalizedLabel,
      );
      final savedProfile = await _safeSaveProfile(nextProfile);
      resolvedProfile = savedProfile ?? resolvedProfile ?? nextProfile;
    }

    return ArcadeProgressData(levelLabel: normalizedLabel, profile: resolvedProfile);
  }

  Future<UserProfile?> _safeLoadProfile(String uid) async {
    try {
      return await _profileService.loadProfile(uid);
    } catch (e, st) {
      debugPrint('Failed to load profile for $uid: $e\n$st');
      return null;
    }
  }

  Future<UserProfile?> _safeSaveProfile(UserProfile profile) async {
    try {
      await _profileService.saveProfile(profile);
      return profile;
    } catch (e, st) {
      debugPrint('Failed to save arcade progress: $e\n$st');
      return null;
    }
  }

  static int levelNumberFromLabel(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    if (match == null) {
      return 1;
    }
    final value = int.tryParse(match.group(1)!);
    return value == null || value <= 0 ? 1 : value;
  }
}
