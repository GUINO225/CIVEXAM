import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/question_history_store.dart';
import '../services/scoring.dart';
import '../services/leaderboard_hooks.dart';
import 'exam_full_screen.dart';

class ArcadeModeScreen extends StatefulWidget {
  static const String routeName = '/arcade';

  const ArcadeModeScreen({super.key});

  @override
  State<ArcadeModeScreen> createState() => _ArcadeModeScreenState();
}

class _ArcadeLevel {
  final String title;
  final String description;
  final int difficulty;
  final int questionCount;
  final int requiredCorrect;
  final int perQuestionSeconds;

  const _ArcadeLevel({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questionCount,
    required this.requiredCorrect,
    required this.perQuestionSeconds,
  });
}

class _ArcadeModeStateSummary {
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int blank;
  final int durationSec;

  const _ArcadeModeStateSummary({
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.durationSec,
  });
}

class _ArcadeModeScreenState extends State<ArcadeModeScreen> {
  static const List<_ArcadeLevel> _levels = [
    _ArcadeLevel(
      title: 'Palier 1 — Échauffement',
      description: 'Questions faciles pour se mettre en jambe.',
      difficulty: 1,
      questionCount: 6,
      requiredCorrect: 5,
      perQuestionSeconds: 12,
    ),
    _ArcadeLevel(
      title: 'Palier 2 — Accélération',
      description: 'Le rythme augmente avec des questions intermédiaires.',
      difficulty: 2,
      questionCount: 6,
      requiredCorrect: 4,
      perQuestionSeconds: 10,
    ),
    _ArcadeLevel(
      title: 'Palier 3 — Maîtrise',
      description: 'Difficulté élevée pour terminer la session.',
      difficulty: 3,
      questionCount: 8,
      requiredCorrect: 5,
      perQuestionSeconds: 9,
    ),
  ];

  static const ExamScoring _scoring =
      ExamScoring(correct: 3, wrong: -1, blank: 0, coefficient: 1);

  bool _preparing = false;
  String? _error;
  _ArcadeModeStateSummary? _lastSummary;

  Future<void> _startArcade() async {
    if (_preparing) return;
    setState(() {
      _preparing = true;
      _error = null;
    });

    try {
      final pool = await QuestionLoader.loadENA();
      if (!mounted) return;

      final requiredPerDiff = <int, int>{};
      for (final level in _levels) {
        requiredPerDiff[level.difficulty] =
            (requiredPerDiff[level.difficulty] ?? 0) + level.questionCount;
      }

      var availability = await drawQuestionsByDifficulty(pool, requiredPerDiff);
      if (availability.hasShortage) {
        final resolved = await _handleShortageDialog();
        if (!resolved) {
          setState(() {
            _error =
                'Pas assez de questions disponibles pour démarrer une session arcade.';
          });
          return;
        }
        availability = await drawQuestionsByDifficulty(pool, requiredPerDiff);
        if (availability.hasShortage) {
          setState(() {
            _error =
                'Banque insuffisante malgré la réinitialisation de l\'historique.';
          });
          return;
        }
      }

      final perDiffQueues = <int, Queue<Question>>{};
      availability.selections.forEach((diff, questions) {
        perDiffQueues[diff] = Queue<Question>.of(questions);
      });

      final sessionUsedIds = <String>{};
      final sessionStart = DateTime.now();
      int totalCorrect = 0;
      int totalWrong = 0;
      int totalBlank = 0;
      int totalQuestions = 0;
      bool aborted = false;

      for (final level in _levels) {
        final success = await _runLevel(
          level: level,
          pool: pool,
          perDiffQueues: perDiffQueues,
          sessionUsedIds: sessionUsedIds,
          onResult: (result) {
            totalCorrect += result.correctCount;
            totalWrong += result.wrongCount;
            totalBlank += result.blankCount;
            totalQuestions += result.total;
          },
        );
        if (!success) {
          aborted = true;
          break;
        }
      }

      if (sessionUsedIds.isNotEmpty) {
        unawaited(QuestionHistoryStore.addAll(sessionUsedIds));
      }

      if (aborted) {
        setState(() {
          _lastSummary = null;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session arcade interrompue.')),
        );
        return;
      }

      final elapsed = DateTime.now().difference(sessionStart).inSeconds;
      final summary = _ArcadeModeStateSummary(
        totalQuestions: totalQuestions,
        correct: totalCorrect,
        wrong: totalWrong,
        blank: totalBlank,
        durationSec: elapsed,
      );

      setState(() {
        _lastSummary = summary;
      });

      await LeaderboardHooks.saveArcade(
        context: context,
        total: summary.totalQuestions,
        correct: summary.correct,
        wrong: summary.wrong,
        blank: summary.blank,
        durationSec: summary.durationSec,
        percent: summary.totalQuestions == 0
            ? 0.0
            : (summary.correct / summary.totalQuestions) * 100.0,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Session arcade terminée'),
          content: Text(
            'Bravo ! Vous avez répondu correctement à ${summary.correct} '
            'questions sur ${summary.totalQuestions}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Échec du démarrage du mode arcade : $e';
        _lastSummary = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _preparing = false;
        });
      }
    }
  }

  Future<bool> _runLevel({
    required _ArcadeLevel level,
    required List<Question> pool,
    required Map<int, Queue<Question>> perDiffQueues,
    required Set<String> sessionUsedIds,
    required void Function(ExamResult result) onResult,
  }) async {
    final queue =
        perDiffQueues.putIfAbsent(level.difficulty, () => Queue<Question>());
    List<Question>? pending;

    while (true) {
      final questions = pending ?? _takeFromQueue(queue, level.questionCount);
      pending = null;
      if (questions.length < level.questionCount) {
        final replenished = await _fetchQuestionsForLevel(
          level: level,
          pool: pool,
          excludeIds: sessionUsedIds,
        );
        if (replenished == null || replenished.length < level.questionCount) {
          return false;
        }
        pending = replenished;
        continue;
      }

      final result = await Navigator.of(context).push<ExamResult?>(
        MaterialPageRoute(
          builder: (_) => ExamFullScreen(
            questions: questions,
            duration: Duration(seconds: level.questionCount * level.perQuestionSeconds),
            scoring: _scoring,
            title: level.title,
            showLocalSummary: true,
            overridePerQuestionSeconds: level.perQuestionSeconds,
          ),
        ),
      );

      if (result == null) {
        return false;
      }

      sessionUsedIds.addAll(questions.map((q) => q.id));
      onResult(result);

      if (result.correctCount >= level.requiredCorrect) {
        return true;
      }

      final retry = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Palier non validé — ${level.title}'),
          content: Text(
            'Vous avez répondu correctement à ${result.correctCount} '
            'question(s). Il en fallait ${level.requiredCorrect} pour avancer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Quitter'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );

      if (retry != true) {
        return false;
      }

      final redraw = await _fetchQuestionsForLevel(
        level: level,
        pool: pool,
        excludeIds: sessionUsedIds,
      );
      if (redraw == null || redraw.length < level.questionCount) {
        return false;
      }
      pending = redraw;
    }
  }

  List<Question> _takeFromQueue(Queue<Question> queue, int count) {
    final result = <Question>[];
    while (result.length < count && queue.isNotEmpty) {
      result.add(queue.removeFirst());
    }
    return result;
  }

  Future<List<Question>?> _fetchQuestionsForLevel({
    required _ArcadeLevel level,
    required List<Question> pool,
    required Set<String> excludeIds,
    bool allowReset = true,
  }) async {
    final result = await drawQuestionsByDifficulty(
      pool,
      {level.difficulty: level.questionCount},
      excludeIds: excludeIds,
    );

    if (!result.hasShortage) {
      return result.forDifficulty(level.difficulty);
    }

    if (!allowReset) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Questions insuffisantes pour ${level.title}. Session interrompue.',
            ),
          ),
        );
      }
      return null;
    }

    final reset = await _handleShortageDialog();
    if (!reset) {
      return null;
    }

    return _fetchQuestionsForLevel(
      level: level,
      pool: pool,
      excludeIds: excludeIds,
      allowReset: false,
    );
  }

  Future<bool> _handleShortageDialog() async {
    final choice = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Banque de questions insuffisante'),
        content: const Text(
          'Il n\'y a plus assez de questions inédites pour continuer. '
          'Souhaitez-vous réinitialiser l\'historique des questions ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (choice == true) {
      await QuestionHistoryStore.clear();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Arcade'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enchaînez des paliers de difficulté croissante. '
                      'Chaque niveau requiert un nombre minimal de bonnes réponses '
                      'pour accéder au suivant.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ..._levels.map((level) => _buildLevelCard(level, theme)),
                    if (_error != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ],
                    if (_lastSummary != null) ...[
                      const SizedBox(height: 24),
                      _buildSummaryCard(_lastSummary!, theme),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: _preparing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(_preparing ? 'Préparation…' : 'Lancer la session'),
                  onPressed: _preparing ? null : _startArcade,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(_ArcadeLevel level, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(level.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(level.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildChip(Icons.layers, '${level.questionCount} questions'),
              _buildChip(
                  Icons.verified,
                  '${level.requiredCorrect} bonnes réponses minimales'),
              _buildChip(
                  Icons.timer,
                  '${level.perQuestionSeconds}s/question (${level.questionCount * level.perQuestionSeconds}s)'),
              _buildChip(Icons.leaderboard, 'Difficulté ${level.difficulty}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(_ArcadeModeStateSummary summary, ThemeData theme) {
    final percent = summary.totalQuestions == 0
        ? 0
        : (summary.correct / summary.totalQuestions * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dernière performance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            '${summary.correct}/${summary.totalQuestions} bonnes réponses '
            '(${percent}%).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text('Temps total : ${_formatDuration(summary.durationSec)}'),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    if (minutes == 0) {
      return '${remainder}s';
    }
    return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
  }
}
