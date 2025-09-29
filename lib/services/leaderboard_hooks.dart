// lib/services/leaderboard_hooks.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../utils/arcade_level_utils.dart';
import '../widgets/leaderboard_save_dialog.dart';

class LeaderboardHooks {
  static Future<void> _save({
    required BuildContext context,
    required String mode,
    String subject = '',
    String chapter = '',
    required int total,
    required int correct,
    required int wrong,
    required int blank,
    required int durationSec,
    double? percent,
    String? arcadeLevel,
  }) async {
    final pct = percent ?? (total == 0 ? 0.0 : (correct / total) * 100.0);
    await showSaveScoreDialog(
      context: context,
      mode: mode,
      subject: subject,
      chapter: chapter,
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: pct,
      arcadeLevel: arcadeLevel,
    );
  }

  static Future<void> saveTraining({
    required BuildContext context,
    String subject = '',
    String chapter = '',
    required int total,
    required int correct,
    required int wrong,
    required int blank,
    required int durationSec,
    double? percent,
  }) async {
    await _save(
      context: context,
      mode: 'training',
      subject: subject,
      chapter: chapter,
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
    );
  }

  static Future<void> saveConcours({
    required BuildContext context,
    required int total,
    required int correct,
    required int wrong,
    required int blank,
    required int durationSec,
    double? percent,
  }) async {
    await _save(
      context: context,
      mode: 'concours',
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
    );
  }

  static Future<void> saveCompetition({
    required BuildContext context,
    required int total,
    required int correct,
    required int wrong,
    required int blank,
    required int durationSec,
    double? percent,
  }) async {
    final arcadeLevel = await _currentArcadeLevel();
    await _save(
      context: context,
      mode: 'competition',
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
      arcadeLevel: arcadeLevel,
    );
  }

  static Future<String?> _currentArcadeLevel() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    try {
      final profile = await UserProfileService().loadProfile(uid);
      if (profile == null) {
        return null;
      }
      return normalizeArcadeLevel(profile.arcadeLevel);
    } catch (_) {
      return null;
    }
  }
}
