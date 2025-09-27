import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../services/question_history_store.dart';
import '../../services/question_loader.dart';
import '../../services/question_randomizer.dart';
import '../competition_screen.dart';
import '../leaderboard_screen.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_menu_list.dart';

class DefisClassementScreen extends StatefulWidget {
  final CategoryDefinition definition;

  const DefisClassementScreen({
    super.key,
    required this.definition,
  });

  @override
  State<DefisClassementScreen> createState() => _DefisClassementScreenState();
}

class _DefisClassementScreenState extends State<DefisClassementScreen> {
  Future<void> _handleTap(int itemIndex) async {
    switch (itemIndex) {
      case 5:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
        );
        break;
      case 6:
        await _startCompetition();
        break;
      default:
        await showComingSoonDialog(context, 'Défi à venir');
        break;
    }
  }

  Future<void> _startCompetition() async {
    bool progressShown = false;
    try {
      const int desiredCount = 60;
      final all = await QuestionLoader.loadENA();
      if (!mounted) return;
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
      if (progressShown && mounted) Navigator.pop(context);

      final proceed = await _handleShortDraw(selected, desiredCount);
      if (!proceed || !mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      unawaited(
        QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError(
          (Object error, _) {
            if (!mounted) return;
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                    'Échec de l’enregistrement de l’historique des questions.'),
              ),
            );
          },
        ),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionScreen(
            questions: selected,
            timePerQuestion: 5,
            startTime: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      if (progressShown && mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load question bank: $e')),
      );
    }
  }

  Future<bool> _handleShortDraw(List<Question> selected, int requested) async {
    if (selected.length >= requested) return true;
    if (!mounted) return false;

    if (selected.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Historique épuisé'),
          content: const Text(
              'Toutes les questions ont déjà été vues. Réinitialiser l\'historique pour recommencer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(_, null),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                QuestionHistoryStore.clear();
                Navigator.pop(_, null);
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
      builder: (_) => AlertDialog(
        title: const Text('Commencer ?'),
        content: Text('Vous avez déjà vu la plupart des questions — '
            '${selected.length}/$requested disponibles.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              QuestionHistoryStore.clear();
              Navigator.pop(_, false);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    return proceed == true;
  }

  @override
  Widget build(BuildContext context) {
    final definition = widget.definition;
    return Scaffold(
      appBar: AppBar(title: Text(definition.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              definition.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: CategoryMenuList(
              definition: definition,
              onItemSelected: _handleTap,
            ),
          ),
        ],
      ),
    );
  }
}
