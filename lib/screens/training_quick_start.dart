import 'package:flutter/material.dart';
import '../services/question_loader.dart';
import '../models/question.dart';
import '../services/scoring.dart';
import '../services/question_randomizer.dart';
import '../models/training_history_entry.dart';
import '../services/training_history_store.dart';
import 'exam_full_screen.dart';
import '../services/leaderboard_hooks.dart';
import '../widgets/chip_selector.dart';

class TrainingQuickStartScreen extends StatefulWidget {
  const TrainingQuickStartScreen({super.key});

  @override
  State<TrainingQuickStartScreen> createState() => _TrainingQuickStartScreenState();
}

class _TrainingQuickStartScreenState extends State<TrainingQuickStartScreen> {
  int _perQuestionSeconds = 10; // 5..10s/question via UI
  int _questionCount = 10;
  bool _loading = false;

  final List<int> _secondOptions = const [5, 6, 7, 8, 9, 10];
  final List<int> _countOptions = const [5, 10, 15, 20];

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      final List<Question> all = await QuestionLoader.loadENA();
      final List<Question> selected = pickAndShuffle(all, _questionCount);

      final totalSeconds = _perQuestionSeconds * _questionCount;
      final scoring = const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 1);

      final res = await Navigator.push<ExamResult?>(context, MaterialPageRoute(
        builder: (_) => ExamFullScreen(
          questions: selected,
          duration: Duration(seconds: totalSeconds),
          scoring: scoring,
          title: 'Entraînement (${_perQuestionSeconds}s/question)',
          showLocalSummary: true,
        ),
      ));

      if (res != null) {
        final bool success = res.total > 0 && (res.correctCount / res.total) >= 0.5; // ≥50% de bonnes réponses
        final entry = TrainingHistoryEntry(
          date: DateTime.now(),
          subject: 'Entraînement (mix)',
          chapter: 'Général',
          durationMinutes: (totalSeconds / 60).ceil(),
          correct: res.correctCount,
          total: res.total,
          rawScore: res.rawScore,
          weightedScore: res.weightedScore,
          success: success,
          abandoned: false,
        );
        await TrainingHistoryStore.add(entry);
        await LeaderboardHooks.saveTraining(
          context: context,
          subject: 'Entraînement (mix)',
          chapter: 'Général',
          total: res.total,
          correct: res.correctCount,
          wrong: res.total - res.correctCount,
          blank: 0,
          durationSec: totalSeconds,
          percent: res.total == 0 ? 0.0 : (res.correctCount / res.total) * 100.0,
        );
if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Tentative enregistrée — Validé.' : 'Tentative enregistrée — Échoué.')),
        );
      } else {
        // Abandon
        final entry = TrainingHistoryEntry(
          date: DateTime.now(),
          subject: 'Entraînement (mix)',
          chapter: 'Général',
          durationMinutes: (totalSeconds / 60).ceil(),
          correct: 0,
          total: selected.length,
          rawScore: 0,
          weightedScore: 0,
          success: false,
          abandoned: true,
        );
        await TrainingHistoryStore.add(entry);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tentative enregistrée — Abandonné.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = Duration(seconds: _perQuestionSeconds * _questionCount);
    String two(int x) => x.toString().padLeft(2, '0');
    final totalLabel = '${two(total.inMinutes)}:${two(total.inSeconds % 60)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Entraînement (5–10s/question)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temps par question', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ChipSelector<int>(
              options: _secondOptions,
              selected: _perQuestionSeconds,
              onSelected: (s) => setState(() => _perQuestionSeconds = s),
              spacing: 8,
              runSpacing: 8,
              labelBuilder: (s) => '${s}s',
            ),
            const SizedBox(height: 16),
            const Text('Nombre de questions', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ChipSelector<int>(
              options: _countOptions,
              selected: _questionCount,
              onSelected: (n) => setState(() => _questionCount = n),
              spacing: 8,
              labelBuilder: (n) => '$n',
            ),
            const SizedBox(height: 16),
            Text('Temps total : $totalLabel', style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _start,
                icon: const Icon(Icons.play_arrow),
                label: Text(_loading ? 'Chargement...' : 'Commencer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
