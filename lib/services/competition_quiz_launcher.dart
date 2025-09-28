import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/question.dart';
import 'question_history_store.dart';
import 'question_loader.dart';
import 'question_randomizer.dart';
import '../screens/competition_screen.dart';

class CompetitionQuizLauncher {
  const CompetitionQuizLauncher._();

  static Future<void> launch(BuildContext context) async {
    bool progressShown = false;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      const int desiredCount = 60;
      final all = await QuestionLoader.loadENA();
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      progressShown = true;

      final selected = await pickAndShuffle(
        all,
        desiredCount,
        dedupeByQuestion: true,
      );

      if (progressShown && context.mounted) navigator.pop();

      final proceed = await _handleShortDraw(context, selected, desiredCount);
      if (!proceed || !context.mounted) return;

      if (messenger != null) {
        unawaited(
          QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError(
            (Object error, _) {
              if (!context.mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Échec de l\'enregistrement de l\'historique des questions.',
                  ),
                ),
              );
            },
          ),
        );
      }

      await navigator.push(
        MaterialPageRoute(
          builder: (_) => CompetitionScreen(
            questions: selected,
            timePerQuestion: 5,
            startTime: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      if (progressShown && context.mounted) navigator.pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load question bank: $e')),
      );
    }
  }

  static Future<bool> _handleShortDraw(
    BuildContext context,
    List<Question> selected,
    int requested,
  ) async {
    if (selected.length >= requested) return true;
    if (!context.mounted) return false;

    if (selected.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Historique épuisé'),
          content: const Text(
            'Toutes les questions ont déjà été vues. Réinitialiser l\'historique pour recommencer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                QuestionHistoryStore.clear();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        ),
      );
      return false;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Commencer ?'),
        content: Text(
          'Vous avez déjà vu la plupart des questions — '
          '${selected.length}/$requested disponibles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              QuestionHistoryStore.clear();
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );

    return proceed == true;
  }
}
