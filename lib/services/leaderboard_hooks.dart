// lib/services/leaderboard_hooks.dart
import 'package:flutter/material.dart';

import '../services/arcade_progress_store.dart';
import '../utils/arcade_level_utils.dart';
import '../widgets/leaderboard_save_dialog.dart';

/// Hooks utilitaires pour l’enregistrement des scores
/// dans les différents modes (training, concours, competition, arcade).
class LeaderboardHooks {
  /// Méthode interne commune qui affiche la boîte de dialogue d’enregistrement.
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

  /// Enregistrement pour le mode entraînement.
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

  /// Enregistrement pour le mode concours (simulation).
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

  /// Enregistrement pour le mode compétition (classement global).
  static Future<void> saveCompetition({
    required BuildContext context,
    required int total,
    required int correct,
    required int wrong,
    required int blank,
    required int durationSec,
    double? percent,
    String? arcadeLevel,
  }) async {
    final resolvedArcadeLevel =
        arcadeLevel ?? await _currentArcadeLevel();
    await _save(
      context: context,
      mode: 'competition',
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
      arcadeLevel: resolvedArcadeLevel,
    );
  }

  /// Enregistrement pour le mode arcade (runs rapides orientés score).
  static Future<void> saveArcade({
    required BuildContext context,
    required int total,
    required int correct,
    required int wrong,
    required int blank,
    required int durationSec,
    double? percent,
    String? arcadeLevel,
  }) async {
    final resolvedArcadeLevel =
        arcadeLevel ?? await _currentArcadeLevel();
    await _save(
      context: context,
      mode: 'arcade',
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
      arcadeLevel: resolvedArcadeLevel,
    );
  }

  /// Récupère le niveau d’arcade courant depuis le profil utilisateur,
  /// puis le normalise via `normalizeArcadeLevel`.
  static Future<String?> _currentArcadeLevel() async {
    final progress = await ArcadeProgressStore().load();
    final label = normalizeArcadeLevel(progress.levelLabel);
    return label.isEmpty ? null : label;
  }
}
