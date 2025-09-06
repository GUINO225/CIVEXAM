// lib/widgets/leaderboard_save_dialog.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_store.dart';
import '../services/competition_service.dart';

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
    final name = user?.displayName ?? user?.email ?? 'Joueur';
    final uid = user?.uid ?? '';
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
  final savedName = prefs.getString('player_name') ?? 'Joueur';
  final controller = TextEditingController(text: savedName);

  final submit = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Enregistrer mon score'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            decoration: const InputDecoration(
                labelText: 'Votre nom', border: OutlineInputBorder()),
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
  if (!context.mounted) return;

  if (submit == true) {
    final name =
        controller.text.trim().isEmpty ? 'Joueur' : controller.text.trim();
    await prefs.setString('player_name', name);
    final entry = LeaderboardEntry(
      userId: '',
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
    await LeaderboardStore.add(entry);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Score enregistré 🎉')));
  }
}
