// lib/screens/arcade_mode_screen.dart
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
import '../widgets/arcade_badge_chip.dart';
import 'exam_full_screen.dart';

class ArcadeModeScreen extends StatefulWidget {
  static const String routeName = '/arcade';

  const ArcadeModeScreen({super.key});

  @override
  State<ArcadeModeScreen> createState() => _ArcadeModeScreenState();
}

/// Palette inspirée de la maquette fournie
class _Brand {
  static const primary = Color(0xFF6C5CE7);       // violet principal
  static const primaryDark = Color(0xFF5B4DE1);   // violet plus sombre
  static const secondary = Color(0xFF7F6AF8);     // accent
  static const surface = Color(0xFFF7F5FF);       // fond global
  static const card = Color(0xFFFFFFFF);          // cartes blanches
  static const chipBg = Color(0xFFEFEAFF);        // chips neutres
  static const text = Color(0xFF1E1E28);          // texte principal
  static const textMuted = Color(0xFF6E6B7A);     // texte secondaire
  static const border = Color(0xFFE6E1F9);        // bordure douce
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

class _PreviewLevelEntry {
  final _ArcadeLevel level;
  final bool isCompleted;
  final bool isCurrent;

  const _PreviewLevelEntry({
    required this.level,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class _ArcadeModeScreenState extends State<ArcadeModeScreen> {
  static const ExamScoring _scoring =
  ExamScoring(correct: 3, wrong: -1, blank: 0, coefficient: 1);

  bool _preparing = false;
  String? _error;
  _ArcadeModeStateSummary? _lastSummary;

  // Progression arcade
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
          _error = 'Aucune question disponible pour lancer le mode arcade.';
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
            duration: Duration(
                seconds: level.questionCount * level.perQuestionSeconds),
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
    final base = Theme.of(context);
    final themed = base.copyWith(
      scaffoldBackgroundColor: _Brand.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _Brand.primary,
        brightness: base.brightness,
      ).copyWith(
        primary: _Brand.primary,
        secondary: _Brand.secondary,
        surface: _Brand.surface,
        background: _Brand.surface,
        onSurface: _Brand.text,
        onPrimary: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _Brand.text,
        displayColor: _Brand.text,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: _Brand.surface,
        foregroundColor: _Brand.text,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _Brand.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: _Brand.text,
        ),
        backgroundColor: _Brand.chipBg,
        selectedColor: _Brand.primary,
        secondarySelectedColor: _Brand.primary,
        showCheckmark: false,
        side: const BorderSide(color: _Brand.border),
      ),
      dividerColor: _Brand.border,
    );

    final resumeIndex = math.max(0, _progressData?.resumeIndex ?? 0);
    final previewLevels = _buildPreviewLevels(resumeIndex);

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mode Arcade'),
          actions: const [
            _AvatarDot(initial: 'M'),
            SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            children: [
              // === EN-TÊTE & "DERNIÈRE SESSION" SUPPRIMÉS ===

              // Bloc violet Featured avec CTA "Lancer la session"
              _FeaturedCard(
                title: 'Défie-toi en mode arcade',
                subtitle:
                'Vitesse, précision et niveaux de plus en plus durs.',
                ctaLabel: _preparing
                    ? 'Préparation…'
                    : _loadingProgress
                    ? 'Chargement…'
                    : 'Lancer la session',
                onTap: _preparing || _loadingProgress ? null : _startArcade,
              ),
              const SizedBox(height: 16),

              // Titre de section façon "Live Quizzes"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Aperçu des niveaux',
                      style: themed.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text('Voir tout',
                      style: themed.textTheme.bodyMedium
                          ?.copyWith(color: _Brand.textMuted)),
                ],
              ),
              const SizedBox(height: 10),

              // Liste style "Live Quizzes" : tuiles blanches bordées
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _Brand.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final entry = previewLevels[index];
                    return _LevelListTile(
                      level: entry.level,
                      isCompleted: entry.isCompleted,
                      isCurrent: entry.isCurrent,
                    );
                  },
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: _Brand.border),
                  itemCount: previewLevels.length,
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 24),
                Text(
                  _error!,
                  style: themed.textTheme.bodyMedium
                      ?.copyWith(color: themed.colorScheme.error),
                ),
              ],

              if (_lastSummary != null) ...[
                const SizedBox(height: 24),
                _SummaryCard(summary: _lastSummary!),
              ],
            ],
          ),
        ),

        // Gros bouton centré (comme le “+” de la maquette)
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: ElevatedButton.icon(
            onPressed: _preparing || _loadingProgress ? null : _startArcade,
            icon: _preparing
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.play_arrow),
            label: Text(_preparing
                ? 'Préparation…'
                : _loadingProgress
                ? 'Chargement…'
                : 'Commencer maintenant'),
          ),
        ),

        // Laisse de la place au CTA si tu as une BottomNav réelle ailleurs
        bottomNavigationBar: const SizedBox(height: 12),
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

  List<_PreviewLevelEntry> _buildPreviewLevels(int resumeIndex) {
    final entries = <_PreviewLevelEntry>[];
    final safeIndex = resumeIndex < 0 ? 0 : resumeIndex;
    for (var i = 0; i < safeIndex; i++) {
      entries.add(
        _PreviewLevelEntry(
          level: _previewLevelAt(i),
          isCompleted: true,
        ),
      );
    }

    entries.add(
      _PreviewLevelEntry(
        level: _previewLevelAt(safeIndex),
        isCurrent: true,
      ),
    );

    return entries;
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

    final requiredCorrect =
    _requiredCorrectForLevel(levelIndex, questionCount);
    final perQuestionSeconds = _perQuestionSecondsForLevel(levelIndex);

    return _ArcadeLevel(
      index: levelIndex,
      difficulty: difficulty,
      questionCount: questionCount,
      requiredCorrect: requiredCorrect,
      perQuestionSeconds: perQuestionSeconds,
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

  // ----- UI helpers (widgets & formatters) -----

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    if (minutes == 0) {
      return '${remainder}s';
    }
    return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
  }
}

/// ---- Widgets réutilisables (nets des blocs retirés) ----

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onTap;
  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: _Brand.primaryDark,
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FEATURED',
              style: tt.labelSmall
                  ?.copyWith(color: Colors.white70, letterSpacing: .6)),
          const SizedBox(height: 6),
          Text(title,
              style: tt.titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: tt.bodyMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onTap,
              icon:
              const Icon(Icons.play_arrow, color: _Brand.primaryDark),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _Brand.primaryDark,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                shape: const StadiumBorder(),
              ),
              label: Text(ctaLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelListTile extends StatelessWidget {
  final _ArcadeLevel level;
  final bool isCompleted;
  final bool isCurrent;

  const _LevelListTile({
    required this.level,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: null, // aperçu non cliquable (la session démarre via les CTA)
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            // Bloc icône gauche (carré violet)
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _Brand.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flag_rounded, color: _Brand.primary),
            ),
            const SizedBox(width: 12),

            // Titre + sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ArcadeBadgeChip(label: level.title, compact: true),
                      const SizedBox(width: 8),
                      if (isCompleted)
                        _StatusPill(
                            icon: Icons.check_circle_rounded,
                            label: 'Validé')
                      else if (isCurrent)
                        _StatusPill(
                            icon: Icons.play_circle_fill_rounded,
                            label: 'À venir'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dif. ${level.difficulty} · ${level.questionCount} Q · '
                        '${level.perQuestionSeconds}s/Q · ${level.requiredCorrect} bonnes requises',
                    style: tt.bodySmall?.copyWith(color: _Brand.textMuted),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: _Brand.textMuted),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: _Brand.chipBg,
      side: const BorderSide(color: _Brand.border),
      shape: const StadiumBorder(),
      labelStyle: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontWeight: FontWeight.w600),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _ArcadeModeStateSummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final percent = summary.totalQuestions == 0
        ? 0
        : (summary.correct / summary.totalQuestions * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Brand.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Brand.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dernière performance',
              style: tt.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            '${summary.correct}/${summary.totalQuestions} bonnes réponses (${percent}%).',
            style: tt.bodyMedium?.copyWith(color: _Brand.text),
          ),
          const SizedBox(height: 8),
          Text('Niveaux complétés : ${summary.levelsCompleted}',
              style:
              tt.bodyMedium?.copyWith(color: _Brand.textMuted)),
          const SizedBox(height: 4),
          Text('Temps total : ${_formatDuration(summary.durationSec)}',
              style:
              tt.bodyMedium?.copyWith(color: _Brand.textMuted)),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    if (minutes == 0) return '${remainder}s';
    return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
  }
}

class _AvatarDot extends StatelessWidget {
  final String initial;
  const _AvatarDot({required this.initial});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: _Brand.chipBg,
      child: Text(
        initial,
        style: const TextStyle(
          color: _Brand.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
