// lib/widgets/leaderboard_save_dialog.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_store.dart';

Future<void> showSaveScoreDialog({
  required BuildContext context,
  required String mode, // 'training' ou 'concours'
  String subject = '', String chapter = '',
  required int total, required int correct, required int wrong, required int blank,
  required int durationSec, required double percent,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final savedName = prefs.getString('player_name') ?? 'Joueur';
  final controller = TextEditingController(text: savedName);

  final submit = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Enregistrer mon score'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(labelText: 'Votre nom', border: OutlineInputBorder()), controller: controller),
        const SizedBox(height: 12),
        Text('Mode : $mode  •  Score : ${percent.toStringAsFixed(1)}%'),
      ]),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Annuler')),
        FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Enregistrer')),
      ],
    ),
  );

  if (submit == true) {
    final name = controller.text.trim().isEmpty ? 'Joueur' : controller.text.trim();
    await prefs.setString('player_name', name);
    final entry = LeaderboardEntry(
      name: name, mode: mode, subject: subject, chapter: chapter,
      total: total, correct: correct, wrong: wrong, blank: blank,
      durationSec: durationSec, percent: percent, dateIso: DateTime.now().toIso8601String(),
    );
    await LeaderboardStore.add(entry);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Score enregistré 🎉')));
  }
}
