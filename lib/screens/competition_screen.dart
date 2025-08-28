import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/scoring.dart';
import 'exam_full_screen.dart';
import '../services/leaderboard_hooks.dart';

/// Écran principal du mode Compétition.
///
/// Tire un ensemble de questions ENA et lance une épreuve chronométrée
/// de 5 minutes. À la fin, le score est sauvegardé pour le classement.
class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  bool _loading = true;
  List<Question> _pool = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final qs = await QuestionLoader.loadENA();
    if (!mounted) return;
    setState(() {
      _pool = qs;
      _loading = false;
    });
  }

  Future<void> _start() async {
    final questions = pickAndShuffle(_pool, 20);
    final start = DateTime.now();
    final res = await Navigator.push<ExamResult?>(
      context,
      MaterialPageRoute(
        builder: (_) => ExamFullScreen(
          questions: questions,
          duration: const Duration(minutes: 5),
          scoring: const ExamScoring(correct: 1, wrong: -1, blank: 0),
          title: 'Mode Compétition',
          antiCheat: true,
        ),
      ),
    );
    if (res != null) {
      final elapsed = DateTime.now().difference(start).inSeconds;
      if (!mounted) return;
      await LeaderboardHooks.saveCompetition(
        context: context,
        total: res.total,
        correct: res.correctCount,
        wrong: res.wrongCount,
        blank: res.blankCount,
        durationSec: elapsed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compétition')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ElevatedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.sports_kabaddi),
                label: const Text('Lancer la compétition (5 min)'),
              ),
            ),
    );
  }
}
