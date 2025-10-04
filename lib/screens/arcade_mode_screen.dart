// lib/screens/arcade_mode_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/design_config.dart';
import '../models/question.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/question_history_store.dart';
import '../services/scoring.dart';
import '../services/leaderboard_hooks.dart';
import '../services/arcade_progress_store.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import '../widgets/arcade_badge_chip.dart';
import '../widgets/play_bottom_nav_bar.dart';
import 'exam_full_screen.dart';
import 'play_screen.dart';

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

class _ArcadePalette {
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color surface;
  final Color surfaceAlt;
  final Color card;
  final Color chip;
  final Color chipStrong;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color onPrimary;
  final Color onSecondary;
  final Color onChip;
  final Color onChipStrong;
  final Color buttonOverlay;
  final Color buttonDisabled;
  final Color buttonDisabledForeground;
  final Color ctaBackground;
  final Color ctaForeground;

  const _ArcadePalette({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.surface,
    required this.surfaceAlt,
    required this.card,
    required this.chip,
    required this.chipStrong,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.onPrimary,
    required this.onSecondary,
    required this.onChip,
    required this.onChipStrong,
    required this.buttonOverlay,
    required this.buttonDisabled,
    required this.buttonDisabledForeground,
    required this.ctaBackground,
    required this.ctaForeground,
  });

  Color get primaryContainer => chip;
  Color get onPrimaryContainer => onChip;
  Color get secondaryContainer => chipStrong;
  Color get onSecondaryContainer => onChipStrong;

  factory _ArcadePalette.fromConfig(DesignConfig cfg) {
    final gradient = playIconColors(cfg.bgPaletteName);
    const fallbackPrimary = Color(0xFF6C5CE7);
    final Color primary = gradient.isNotEmpty ? gradient.last : fallbackPrimary;
    final Color primaryDark =
        gradient.length > 1 ? gradient.first : darken(primary, 0.12);
    final Color secondary = complementaryColor(cfg.bgPaletteName);
    final surfaces = pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode);
    final Color surface =
        surfaces.isNotEmpty ? surfaces.last : const Color(0xFFF7F5FF);
    final Color surfaceAlt = surfaces.length > 1 ? surfaces.first : surface;
    final overlayBase = cfg.darkMode ? Colors.white : Colors.black;
    final Color card = Color.alphaBlend(
      overlayBase.withOpacity(cfg.darkMode ? 0.12 : 0.05),
      surface,
    );
    final Color chip = Color.alphaBlend(
      primary.withOpacity(cfg.darkMode ? 0.32 : 0.14),
      surfaceAlt,
    );
    final Color chipStrong = Color.alphaBlend(
      secondary.withOpacity(cfg.darkMode ? 0.26 : 0.12),
      surfaceAlt,
    );
    final Color text =
        textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
    final Color textMuted = Color.alphaBlend(
      text.withOpacity(cfg.darkMode ? 0.45 : 0.55),
      surfaceAlt,
    );
    final Color border = Color.alphaBlend(
      text.withOpacity(cfg.darkMode ? 0.35 : 0.16),
      surfaceAlt,
    );
    final Color onPrimary =
        ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final Color onSecondary =
        ThemeData.estimateBrightnessForColor(secondary) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final Color onChip =
        ThemeData.estimateBrightnessForColor(chip) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final Color onChipStrong =
        ThemeData.estimateBrightnessForColor(chipStrong) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final Color buttonOverlay =
        onPrimary.withOpacity(cfg.darkMode ? 0.22 : 0.12);
    final Color buttonDisabled = Color.alphaBlend(
      text.withOpacity(cfg.darkMode ? 0.32 : 0.18),
      surface,
    );
    final Color buttonDisabledForeground =
        onPrimary.withOpacity(cfg.darkMode ? 0.5 : 0.4);
    final Color ctaBackground = Color.alphaBlend(
      onPrimary.withOpacity(cfg.darkMode ? 0.18 : 0.82),
      surface,
    );
    final Color ctaForeground =
        ThemeData.estimateBrightnessForColor(ctaBackground) == Brightness.dark
            ? Colors.white
            : primaryDark;

    return _ArcadePalette(
      primary: primary,
      primaryDark: primaryDark,
      secondary: secondary,
      surface: surface,
      surfaceAlt: surfaceAlt,
      card: card,
      chip: chip,
      chipStrong: chipStrong,
      text: text,
      textMuted: textMuted,
      border: border,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onChip: onChip,
      onChipStrong: onChipStrong,
      buttonOverlay: buttonOverlay,
      buttonDisabled: buttonDisabled,
      buttonDisabledForeground: buttonDisabledForeground,
      ctaBackground: ctaBackground,
      ctaForeground: ctaForeground,
    );
  }
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
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final base = Theme.of(context);
        final palette = _ArcadePalette.fromConfig(cfg);
        final colorScheme = ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: base.brightness,
        ).copyWith(
          primary: palette.primary,
          onPrimary: palette.onPrimary,
          primaryContainer: palette.primaryContainer,
          onPrimaryContainer: palette.onPrimaryContainer,
          secondary: palette.secondary,
          onSecondary: palette.onSecondary,
          secondaryContainer: palette.secondaryContainer,
          onSecondaryContainer: palette.onSecondaryContainer,
          surface: palette.surface,
          surfaceTint: palette.primary,
          background: palette.surface,
          surfaceVariant: palette.card,
          onSurface: palette.text,
          onSurfaceVariant: palette.textMuted,
          outline: palette.border,
          outlineVariant: Color.alphaBlend(
            palette.border.withOpacity(0.5),
            palette.surfaceAlt,
          ),
        );
        final themed = base.copyWith(
          colorScheme: colorScheme,
          scaffoldBackgroundColor: palette.surface,
          cardColor: palette.card,
          dividerColor: palette.border,
          textTheme: base.textTheme.apply(
            bodyColor: palette.text,
            displayColor: palette.text,
          ),
          appBarTheme: base.appBarTheme.copyWith(
            backgroundColor: palette.surface,
            foregroundColor: palette.text,
            elevation: 0,
            centerTitle: false,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.disabled)) {
                  return palette.buttonDisabled;
                }
                return palette.primary;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.disabled)) {
                  return palette.buttonDisabledForeground;
                }
                return palette.onPrimary;
              }),
              overlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed) ||
                    states.contains(MaterialState.hovered) ||
                    states.contains(MaterialState.focused)) {
                  return palette.buttonOverlay;
                }
                return null;
              }),
              minimumSize: const MaterialStatePropertyAll(Size.fromHeight(56)),
              shape: const MaterialStatePropertyAll(StadiumBorder()),
              elevation: const MaterialStatePropertyAll(0),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.disabled)) {
                  return palette.buttonDisabled;
                }
                return palette.secondary;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.disabled)) {
                  return palette.buttonDisabledForeground;
                }
                return palette.onSecondary;
              }),
              overlayColor: MaterialStatePropertyAll(
                palette.onSecondary.withOpacity(0.12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(palette.primary),
              overlayColor: MaterialStatePropertyAll(
                palette.primary.withOpacity(0.12),
              ),
            ),
          ),
          chipTheme: base.chipTheme.copyWith(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            labelStyle: base.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.onPrimaryContainer,
            ),
            backgroundColor: palette.primaryContainer,
            selectedColor: palette.primary,
            secondarySelectedColor: palette.primaryDark,
            showCheckmark: false,
            side: BorderSide(color: palette.border),
          ),
          dividerTheme: base.dividerTheme.copyWith(
            color: palette.border,
            thickness: 1,
          ),
        );

        final resumeIndex = math.max(0, _progressData?.resumeIndex ?? 0);
        final previewLevels = _buildPreviewLevels(resumeIndex);
        final bool isDark = base.brightness == Brightness.dark;
        final Color navHighlight =
            palette.secondary.withOpacity(isDark ? 0.32 : 0.20);

        return Theme(
          data: themed,
          child: Scaffold(
            extendBody: true,
            appBar: AppBar(
              title: const Text('Mode Arcade'),
              actions: [
                if (_loadingProgress)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Chip(
                      label: Text(_progressData?.levelLabel ?? 'Niveau 1'),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  // Bloc violet Featured avec CTA "Lancer la session"
                  _FeaturedCard(
                    palette: palette,
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
                          style: themed.textTheme.bodyMedium?.copyWith(
                              color: themed.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Liste style "Live Quizzes" : tuiles bordées
                  Container(
                    decoration: BoxDecoration(
                      color: themed.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: themed.colorScheme.outline),
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
                          onTap: entry.isCurrent
                              ? (_preparing || _loadingProgress
                                  ? null
                                  : _startArcade)
                              : null,
                        );
                      },
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: themed.dividerColor,
                      ),
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
                onPressed:
                    _preparing || _loadingProgress ? null : _startArcade,
                icon: _preparing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: themed.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_preparing
                    ? 'Préparation…'
                    : _loadingProgress
                        ? 'Chargement…'
                        : 'Commencer maintenant'),
              ),
            ),

            // BottomNav CIVEXAM
            bottomNavigationBar: PlayBottomNavBar(
              destinations: playNavDestinations,
              selectedIndex: 2,
              backgroundColor: palette.primary,
              highlightColor: navHighlight,
              foregroundColor: palette.onPrimary,
              onDestinationSelected: (index) {
                if (index == 2) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayScreen(initialIndex: index),
                  ),
                );
              },
            ),
          ),
        );
      },
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
  final _ArcadePalette palette;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onTap;
  const _FeaturedCard({
    required this.palette,
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
        color: palette.primaryDark,
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FEATURED',
              style: tt.labelSmall?.copyWith(
                  color: palette.onPrimary.withOpacity(0.7),
                  letterSpacing: .6)),
          const SizedBox(height: 6),
          Text(title,
              style: tt.titleMedium
                  ?.copyWith(color: palette.onPrimary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: tt.bodyMedium
                  ?.copyWith(color: palette.onPrimary.withOpacity(0.72))),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: palette.ctaBackground,
                foregroundColor: palette.ctaForeground,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: const StadiumBorder(),
                overlayColor: palette.primary.withOpacity(0.12),
              ),
              label: const Text('Lancer la session',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              icon: const Icon(Icons.play_arrow),
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
  final VoidCallback? onTap;

  const _LevelListTile({
    required this.level,
    required this.isCompleted,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final highlightCurrent = isCurrent;
    final brightness = Theme.of(context).brightness;

    final Color tileBackground = highlightCurrent
        ? Color.alphaBlend(
            scheme.primary
                .withOpacity(brightness == Brightness.dark ? 0.26 : 0.14),
            scheme.surface,
          )
        : Colors.transparent;
    final Color leftContainerColor =
        highlightCurrent ? scheme.primary : scheme.primaryContainer;
    final Color leftIconColor =
        highlightCurrent ? scheme.onPrimary : scheme.primary;
    final Color detailTextColor = highlightCurrent
        ? scheme.onPrimary
            .withOpacity(brightness == Brightness.dark ? 0.92 : 0.88)
        : scheme.onSurfaceVariant;
    final Color trailingIconColor =
        highlightCurrent ? scheme.onPrimary : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: tileBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Bloc icône gauche (carré violet)
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: leftContainerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.flag_rounded, color: leftIconColor),
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
                        const _StatusPill(
                            icon: Icons.check_circle_rounded, label: 'Validé')
                      else if (isCurrent)
                        const _StatusPill(
                            icon: Icons.play_circle_fill_rounded,
                            label: 'À venir'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dif. ${level.difficulty} · ${level.questionCount} Q · '
                    '${level.perQuestionSeconds}s/Q · ${level.requiredCorrect} bonnes requises',
                    style: tt.bodySmall?.copyWith(color: detailTextColor),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: trailingIconColor),
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
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label),
      backgroundColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outline),
      shape: const StadiumBorder(),
      labelStyle: tt.bodySmall?.copyWith(
          fontWeight: FontWeight.w600, color: scheme.onPrimaryContainer),
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
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final scheme = theme.colorScheme;
    final percent = summary.totalQuestions == 0
        ? 0
        : (summary.correct / summary.totalQuestions * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dernière performance',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            '${summary.correct}/${summary.totalQuestions} bonnes réponses (${percent}%).',
            style: tt.bodyMedium?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text('Niveaux complétés : ${summary.levelsCompleted}',
              style:
                  tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('Temps total : ${_formatDuration(summary.durationSec)}',
              style:
                  tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
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
