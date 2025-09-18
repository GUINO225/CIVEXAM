// lib/widgets/leaderboard_save_dialog.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';
import '../services/private_scores_store.dart';

Future<void> showSaveScoreDialog({
  required BuildContext context,
  required String mode, // 'training', 'concours' ou 'competition'
  String subject = '', String chapter = '',
  required int total, required int correct, required int wrong, required int blank,
  required int durationSec, required double percent,
}) async {
  // Mode compétition : utilise automatiquement l'utilisateur connecté
  if (mode == 'competition') {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Veuillez vous connecter pour enregistrer votre score.'),
          ),
        );
      }
      return;
    }

    final uid = user.uid;
    String name = user.displayName ?? user.email ?? 'Joueur';

    // Charge le profil pour récupérer le pseudonyme
    final profileService = UserProfileService();
    UserProfile? profile;
    try {
      profile = await profileService.loadProfile(uid);
    } catch (e, st) {
      debugPrint('Failed to load profile for $uid: $e\n$st');
      profile = null;
    }
    final nickname = profile?.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      name = nickname;
    }

    final entry = LeaderboardEntry(
      userId: uid,
      name: name,
      mode: mode,
      subject: subject,
      chapter: chapter,
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
      dateIso: DateTime.now().toIso8601String(),
    );
    final service = CompetitionService();
    await service.saveEntry(entry);
    if (!context.mounted) return;
    final top = await service.topEntries(limit: 1);
    if (!context.mounted) return;
    if (top.isNotEmpty && top.first.userId == uid) {
      final controller =
          ConfettiController(duration: const Duration(seconds: 2))..play();
      try {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: controller,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                ),
              ),
              AlertDialog(
                title: const Text('Félicitations !'),
                content: const Text('Vous êtes en tête du classement.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK')),
                ],
              ),
            ],
          ),
        );
      } catch (e, st) {
        debugPrint('Error showing leaderboard dialog: $e\n$st');
      } finally {
        controller.dispose();
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Score enregistré 🎉')));
    }
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  if (!context.mounted) return;
  final user = FirebaseAuth.instance.currentUser;
  String savedName = 'Joueur';
  if (user != null) {
    try {
      final profile = await UserProfileService().loadProfile(user.uid);
      savedName = profile?.nickname ?? 'Joueur';
      await prefs.setString('nickname', savedName);
    } catch (e, st) {
      debugPrint('Failed to load profile for ${user.uid}: $e\n$st');
      savedName = 'Joueur';
    }
  } else {
    savedName = prefs.getString('nickname') ?? 'Joueur';
  }
  final controller = TextEditingController(text: savedName);
  bool? submit;
  String name = savedName;
  try {
    submit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Enregistrer mon score'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              decoration: const InputDecoration(
                  labelText: 'Votre nom',
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
              controller: controller),
          const SizedBox(height: 12),
          Text('Mode : $mode  •  Score : ${percent.toStringAsFixed(1)}%'),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    name = controller.text;
  } finally {
    controller.dispose();
  }
  if (!context.mounted) return;

  if (submit == true) {
    final sanitizedName =
        name.trim().isEmpty ? 'Joueur' : name.trim();
    await prefs.setString('nickname', sanitizedName);
    final entry = LeaderboardEntry(
      userId: '',
      name: sanitizedName,
      mode: mode,
      subject: subject,
      chapter: chapter,
      total: total,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: durationSec,
      percent: percent,
      dateIso: DateTime.now().toIso8601String(),
    );
    await PrivateScoresStore.add(entry);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Score enregistré 🎉')));
  }
}
