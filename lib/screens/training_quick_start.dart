import 'dart:async';

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/training_history_entry.dart';
import '../services/leaderboard_hooks.dart';
import '../services/ongoing_quiz_store.dart';
import '../services/question_history_store.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/scoring.dart';
import '../services/training_history_store.dart';
import '../widgets/chip_selector.dart';
import '../widgets/play_mode_panels.dart';
import '../widgets/play_themed_scaffold.dart';
import 'exam_full_screen.dart';

class TrainingQuickStartScreen extends StatefulWidget {
  const TrainingQuickStartScreen({super.key});

  @override
  State<TrainingQuickStartScreen> createState() => _TrainingQuickStartScreenState();
}

class _TrainingQuickStartScreenState extends State<TrainingQuickStartScreen> {
  int _perQuestionSeconds = 10; // 5..10s/question via UI
  int _questionCount = 10; // default number of questions
  bool _loading = false;

  final List<int> _secondOptions = const [5, 6, 7, 8, 9, 10];
  final List<int> _countOptions = const [5, 10, 15, 20]; // allowed question counts

  Future<void> _start() async {
    bool dialogShown = false;
    setState(() => _loading = true);
    try {
      final List<Question> all = await QuestionLoader.loadENA();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      dialogShown = true;
      final List<Question> selected = await pickAndShuffle(
        all,
        _questionCount,
        dedupeByQuestion: true,
      );
      if (dialogShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }

      final proceed = await _handleShortDraw(selected, _questionCount);
      if (!proceed) {
        return;
      }

      if (!mounted) return;
      unawaited(
        QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError(
          (Object error, _) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Échec de l’enregistrement de l’historique des questions.'),
              ),
            );
          },
        ),
      );

      final totalSeconds = _perQuestionSeconds * selected.length;
      final scoring = const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 1);
      final title = 'Entraînement (${_perQuestionSeconds}s/question)';
      final quickState = OngoingQuickQuizState(
        title: title,
        questionIds: selected.map((q) => q.id).toList(growable: false),
        answers: List<int?>.filled(selected.length, null, growable: false),
        remainingSeconds: totalSeconds,
      );
      await OngoingQuickQuizStore.save(quickState);

      final startTime = DateTime.now();
      final res = await Navigator.push<ExamResult?>(context, MaterialPageRoute(
        builder: (_) => ExamFullScreen(
          questions: selected,
          duration: Duration(seconds: totalSeconds),
          scoring: scoring,
          title: title,
          showLocalSummary: true,
          initialAnswers: quickState.answers,
          initialRemainingSeconds: quickState.remainingSeconds,
          onStateChanged: (remaining, answers) {
            unawaited(
              OngoingQuickQuizStore.save(
                quickState.copyWith(
                  remainingSeconds: remaining,
                  answers: answers,
                ),
              ),
            );
          },
          onStateCleared: () {
            unawaited(OngoingQuickQuizStore.clear());
          },
        ),
      ));
      final completedAt = DateTime.now();
      if (res != null) {
        await OngoingQuickQuizStore.saveLastResult(
          QuickQuizSummary(
            title: title,
            completedAt: completedAt,
            correctAnswers: res.correctCount,
            totalQuestions: res.total,
          ),
        );
      } else {
        await OngoingQuickQuizStore.clearLastResult();
      }
      await OngoingQuickQuizStore.clear();
      final elapsedSeconds = completedAt.difference(startTime).inSeconds;

      if (res != null) {
        final bool success = res.total > 0 && (res.correctCount / res.total) >= 0.5; // ≥50% de bonnes réponses
        final entry = TrainingHistoryEntry(
          date: DateTime.now(),
          subject: 'Entraînement (mix)',
          chapter: 'Général',
          durationMinutes: (elapsedSeconds / 60).ceil(),
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
          wrong: res.wrongCount,
          blank: res.blankCount,
          durationSec: elapsedSeconds,
          percent: res.total == 0 ? 0.0 : (res.correctCount / res.total) * 100.0,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(success ? 'Tentative enregistrée — Validé.' : 'Tentative enregistrée — Échoué.')),
        );
      } else {
        // Abandon
        final entry = TrainingHistoryEntry(
          date: DateTime.now(),
          subject: 'Entraînement (mix)',
          chapter: 'Général',
          durationMinutes: (elapsedSeconds / 60).ceil(),
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
    } catch (e) {
      if (dialogShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }
      unawaited(OngoingQuickQuizStore.clear());
      unawaited(OngoingQuickQuizStore.clearLastResult());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du lancement de l\'entraînement : $e')),
      );
    } finally {
      if (dialogShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<bool> _handleShortDraw(List<Question> selected, int requested) async {
    if (selected.length >= requested) {
      return true;
    }
    if (!mounted) {
      return false;
    }
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
    final total = Duration(seconds: _perQuestionSeconds * _questionCount);
    String two(int x) => x.toString().padLeft(2, '0');
    final totalLabel = '${two(total.inMinutes)}:${two(total.inSeconds % 60)}';
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return PlayThemedScaffold(
      bodyMode: PlayThemedScaffoldBodyMode.panel,
      panelHeightFactor: 0.74,
      safeAreaTop: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlayPanelHeader(
                    icon: Icons.bolt_rounded,
                    title: 'Entraînement (5–10s/question)',
                    subtitle: 'Lancez un quiz rapide et chronométré',
                    chips: [
                      PlayInfoChip(
                        icon: Icons.speed_rounded,
                        label: '${_perQuestionSeconds}s/question',
                      ),
                      PlayInfoChip(
                        icon: Icons.format_list_numbered_rounded,
                        label: '$_questionCount questions',
                      ),
                      PlayCountdownChip(label: 'Temps total : $totalLabel'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PlayPanelSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temps par question', style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ChipSelector<int>(
                          options: _secondOptions,
                          selected: _perQuestionSeconds,
                          onSelected: (s) => setState(() => _perQuestionSeconds = s),
                          spacing: 8,
                          runSpacing: 8,
                          labelBuilder: (s) => '${s}s',
                        ),
                        const SizedBox(height: 24),
                        Text('Nombre de questions', style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ChipSelector<int>(
                          options: _countOptions,
                          selected: _questionCount,
                          onSelected: (n) => setState(() => _questionCount = n),
                          spacing: 8,
                          labelBuilder: (n) => '$n',
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PlayPrimaryButton(
                    label: _loading ? 'Chargement…' : 'Commencer',
                    icon: Icons.play_arrow_rounded,
                    busy: _loading,
                    onPressed: _loading ? null : _start,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
