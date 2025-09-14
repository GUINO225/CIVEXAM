// lib/services/leaderboard_hooks.dart
import 'package:flutter/material.dart';
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
    await _save(
      context: context,
      mode: 'competition',
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
    );
  }
}
