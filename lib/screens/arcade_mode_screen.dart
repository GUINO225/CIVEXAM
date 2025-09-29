import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/question_history_store.dart';
import '../services/scoring.dart';
import '../services/leaderboard_hooks.dart';
import '../services/arcade_progress_store.dart';
import 'exam_full_screen.dart';

class ArcadeModeScreen extends StatefulWidget {
  static const String routeName = '/arcade';

  const ArcadeModeScreen({super.key});

  @override
  State<ArcadeModeScreen> createState() => _ArcadeModeScreenState();
}

class _ArcadeLevel {
  final int index;
  final int difficulty;
  final int questionCount;
  final int requiredCorrect;
  final int perQuestionSeconds;

  const _ArcadeLevel({
    required this.index,
    required this.difficulty,
    required this.questionCount,
    required this.requiredCorrect,
    required this.perQuestionSeconds,
  });

  String get title => 'Niveau ${index + 1}';

  String get description {
    final buffer = StringBuffer('Palier de difficulté $difficulty. ')
      ..write('Répondez à $requiredCorrect bonne');
    buffer.write(requiredCorrect > 1 ? 's' : '');
    buffer.write(' sur $questionCount question');
    buffer.write(questionCount > 1 ? 's' : '');
    buffer.write(' pour continuer.');
    return buffer.toString();
  }
}

class _ArcadeModeStateSummary {
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int blank;
  final int durationSec;
  final int levelsCompleted;

  const _ArcadeModeStateSummary({
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.durationSec,
    required this.levelsCompleted,
  });
}

class _ArcadeModeScreenState extends State<ArcadeModeScreen> {
  static const ExamScoring _scoring =
      ExamScoring(correct: 3, wrong: -1, blank: 0, coefficient: 1);

  static const int _previewLevelCount = 12;

  bool _preparing = false;
  String? _error;
  _ArcadeModeStateSummary? _lastSummary;
  final ArcadeProgressStore _progressStore = ArcadeProgressStore();
  ArcadeProgressData? _progressData;
  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProgress());
  }

  Future<void> _loadProgress() async {
    final progress = await _progressStore.load();
    if (!mounted) return;
    setState(() {
      _progressData = progress;
      _loadingProgress = false;
    });
  }

  Future<void> _startArcade() async {
    if (_preparing || _loadingProgress) return;
    setState(() {
      _preparing = true;
      _error = null;
    });

    try {
      final pool = await QuestionLoader.loadENA();
      if (!mounted) return;

      final totalByDifficulty = _countByDifficulty(pool);
      final maxDifficulty = _computeMaxUsableDifficulty(totalByDifficulty);
      if (maxDifficulty == 0) {
        setState(() {
          _error =
              'Aucune question disponible pour lancer le mode arcade.';
          _preparing = false;
        });
        return;
      }

      final consumedByDifficulty = <int, int>{};
      final sessionUsedIds = <String>{};
      final sessionStart = DateTime.now();
      int totalCorrect = 0;
      int totalWrong = 0;
      int totalBlank = 0;
      int totalQuestions = 0;
      int levelsCompleted = 0;
      int levelIndex = _progressData?.resumeIndex ?? 0;
      bool aborted = false;
      bool shortage = false;

      while (true) {
        final level = _levelForIndex(
          levelIndex,
          maxDifficulty: maxDifficulty,
          totalByDifficulty: totalByDifficulty,
          consumedByDifficulty: consumedByDifficulty,
        );

        if (level == null) {
          shortage = true;
          break;
        }

        final success = await _runLevel(
          level: level,
          pool: pool,
          sessionUsedIds: sessionUsedIds,
          onResult: (result) {
            totalCorrect += result.correctCount;
            totalWrong += result.wrongCount;
            totalBlank += result.blankCount;
            totalQuestions += result.total;
          },
          onQuestionsUsed: (count) {
            consumedByDifficulty[level.difficulty] =
                (consumedByDifficulty[level.difficulty] ?? 0) + count;
          },
        );

        if (!success) {
          aborted = true;
          break;
        }

        await _handleLevelValidated(level);
        levelsCompleted += 1;
        levelIndex += 1;
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

      if (shortage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Banque de questions insuffisante pour poursuivre les niveaux.',
            ),
          ),
        );
      }

      final elapsed = DateTime.now().difference(sessionStart).inSeconds;
      final summary = _ArcadeModeStateSummary(
        totalQuestions: totalQuestions,
        correct: totalCorrect,
        wrong: totalWrong,
        blank: totalBlank,
        durationSec: elapsed,
        levelsCompleted: levelsCompleted,
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
        arcadeLevel: _progressData?.levelLabel,
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
    required Set<String> sessionUsedIds,
    required void Function(ExamResult result) onResult,
    required void Function(int usedCount) onQuestionsUsed,
  }) async {
    List<Question>? pending;

    while (true) {
      final questions = pending ??
          await _fetchQuestionsForLevel(
            level: level,
            pool: pool,
            excludeIds: sessionUsedIds,
          );
      pending = null;
      if (questions == null || questions.length < level.questionCount) {
        return false;
      }

      final result = await Navigator.of(context).push<ExamResult?>(
        MaterialPageRoute(
          builder: (_) => ExamFullScreen(
            questions: questions,
            duration:
                Duration(seconds: level.questionCount * level.perQuestionSeconds),
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
      onQuestionsUsed(questions.length);
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

      pending = await _fetchQuestionsForLevel(
        level: level,
        pool: pool,
        excludeIds: sessionUsedIds,
      );
    }
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
    final resumeIndex = _progressData?.resumeIndex ?? 0;
    final previewLevels = List.generate(
      _previewLevelCount,
      (i) => _previewLevelAt(resumeIndex + i),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Arcade'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Enchaînez des paliers de difficulté croissante. '
                    'Chaque niveau adapte automatiquement la cadence et '
                    'les exigences pour maintenir le défi.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemBuilder: (context, index) {
                          final level = previewLevels[index];
                          return _buildLevelCard(level, theme);
                        },
                        itemCount: previewLevels.length,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Les niveaux au-delà de ${previewLevels.last.title} '
                    'poursuivent l\'augmentation de la difficulté jusqu\'à '
                    'épuisement de la banque de questions.',
                    style: theme.textTheme.bodySmall,
                  ),
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
                  label: Text(
                    _preparing
                        ? 'Préparation…'
                        : _loadingProgress
                            ? 'Chargement…'
                            : 'Lancer la session',
                  ),
                  onPressed:
                      _preparing || _loadingProgress ? null : _startArcade,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLevelValidated(_ArcadeLevel level) async {
    final nextLabel = 'Niveau ${level.index + 2}';
    final updated = await _progressStore.save(
      levelLabel: nextLabel,
      baseProfile: _progressData?.profile,
    );
    if (!mounted) return;
    setState(() {
      _progressData = updated;
    });
  }

  Widget _buildLevelCard(_ArcadeLevel level, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                '${level.requiredCorrect} bonne${level.requiredCorrect > 1 ? 's' : ''} requise${level.requiredCorrect > 1 ? 's' : ''}',
              ),
              _buildChip(
                Icons.timer,
                '${level.perQuestionSeconds}s/question (${level.questionCount * level.perQuestionSeconds}s)',
              ),
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
          Text('Niveaux complétés : ${summary.levelsCompleted}'),
          const SizedBox(height: 4),
          Text('Temps total : ${_formatDuration(summary.durationSec)}'),
        ],
      ),
    );
  }

  _ArcadeLevel? _levelForIndex(
    int levelIndex, {
    required int maxDifficulty,
    required Map<int, int> totalByDifficulty,
    required Map<int, int> consumedByDifficulty,
  }) {
    final difficulty = _difficultyForLevel(levelIndex, maxDifficulty);
    final available = (totalByDifficulty[difficulty] ?? 0) -
        (consumedByDifficulty[difficulty] ?? 0);
    if (available <= 0) {
      return null;
    }

    final targetCount = _questionCountForLevel(levelIndex);
    final minRequired = math.min(3, available);
    var questionCount = math.min(targetCount, available);
    if (questionCount < minRequired) {
      questionCount = minRequired;
    }
    if (questionCount <= 0) {
      return null;
    }

    final requiredCorrect = _requiredCorrectForLevel(levelIndex, questionCount);
    final perQuestionSeconds = _perQuestionSecondsForLevel(levelIndex);

    return _ArcadeLevel(
      index: levelIndex,
      difficulty: difficulty,
      questionCount: questionCount,
      requiredCorrect: requiredCorrect,
      perQuestionSeconds: perQuestionSeconds,
    );
  }

  Map<int, int> _countByDifficulty(List<Question> pool) {
    final counts = <int, int>{};
    for (final q in pool) {
      counts[q.difficulty] = (counts[q.difficulty] ?? 0) + 1;
    }
    return counts;
  }

  int _computeMaxUsableDifficulty(Map<int, int> counts) {
    if (counts.isEmpty) return 0;
    final entries = counts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    int max = 0;
    for (final entry in entries) {
      if (entry.value >= 3) {
        max = entry.key > max ? entry.key : max;
      }
    }
    if (max == 0) {
      // Autorise au moins la difficulté la plus basse disponible.
      final minKey = entries.first.key;
      return minKey;
    }
    return max;
  }

  _ArcadeLevel _previewLevelAt(int index) {
    final baseCount = math.max(3, _questionCountForLevel(index));
    return _ArcadeLevel(
      index: index,
      difficulty: _difficultyForLevel(index, 3),
      questionCount: baseCount,
      requiredCorrect: _requiredCorrectForLevel(index, baseCount),
      perQuestionSeconds: _perQuestionSecondsForLevel(index),
    );
  }

  int _difficultyForLevel(int index, int maxDifficulty) {
    return math.min(1 + (index ~/ 3), maxDifficulty);
  }

  int _questionCountForLevel(int index) {
    return 5 + (index ~/ 2);
  }

  double _successRatioForLevel(int index) {
    return math.min(0.85, 0.6 + index * 0.025);
  }

  int _requiredCorrectForLevel(int index, int questionCount) {
    final ratio = _successRatioForLevel(index);
    final required = (questionCount * ratio).ceil();
    if (required < 1) {
      return 1;
    }
    if (required > questionCount) {
      return questionCount;
    }
    return required;
  }

  int _perQuestionSecondsForLevel(int index) {
    return math.max(6, 14 - index);
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
