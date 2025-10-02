import 'dart:async';
import 'package:flutter/material.dart';

import '../models/design_config.dart';
import '../models/question.dart';
import '../models/training_history_entry.dart';
import '../services/design_bus.dart';
import '../services/ongoing_quiz_store.dart';
import '../services/question_history_store.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/scoring.dart';
import '../services/training_history_store.dart';
import '../utils/palette_utils.dart';
import '../widgets/chip_selector.dart';
import 'exam_full_screen.dart';

class TrainingQuickStartScreen extends StatefulWidget {
  const TrainingQuickStartScreen({super.key});

  @override
  State<TrainingQuickStartScreen> createState() => _TrainingQuickStartScreenState();
}

class _TrainingQuickStartScreenState extends State<TrainingQuickStartScreen> {
  int _perQuestionSeconds = 10; // 5..10 s/question via l’UI
  int _questionCount = 10;      // nombre de questions
  bool _loading = false;

  final List<int> _secondOptions = const [5, 6, 7, 8, 9, 10];
  final List<int> _countOptions  = const [5, 10, 15, 20];

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      final List<Question> all = await QuestionLoader.loadENA();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final List<Question> selected = await pickAndShuffle(
        all,
        _questionCount,
        dedupeByQuestion: true,
      );

      if (mounted) Navigator.pop(context);

      final proceed = await _handleShortDraw(selected, _questionCount);
      if (!proceed) return;

      unawaited(
        QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError((Object _, __) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l’enregistrement de l’historique des questions.')),
          );
        }),
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

      final res = await Navigator.push<ExamResult?>(
        context,
        MaterialPageRoute(
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
                  quickState.copyWith(remainingSeconds: remaining, answers: answers),
                ),
              );
            },
            onStateCleared: () {
              unawaited(OngoingQuickQuizStore.clear());
            },
          ),
        ),
      );

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
        final bool success = res.total > 0 && (res.correctCount / res.total) >= 0.5; // ≥ 50%
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Tentative enregistrée — Validé.' : 'Tentative enregistrée — Échoué.')),
        );
      } else {
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
      if (mounted) {
        // ferme toute modale éventuelle
        Navigator.popUntil(context, (route) => route.isFirst || route is! PopupRoute);
      }
      unawaited(OngoingQuickQuizStore.clear());
      unawaited(OngoingQuickQuizStore.clearLastResult());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du lancement de l’entraînement : $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
          content: const Text('Toutes les questions ont déjà été vues. Réinitialiser l’historique pour recommencer.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(_, null), child: const Text('Fermer')),
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
        content: Text('Vous avez déjà vu la plupart des questions — ${selected.length}/$requested disponibles.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              QuestionHistoryStore.clear();
              Navigator.pop(_, false);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(onPressed: () => Navigator.pop(_, true), child: const Text('Continuer')),
        ],
      ),
    );
    return proceed == true;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final base = Theme.of(context);
        final palette = _QuickStartPalette.fromConfig(cfg);

        final themed = base.copyWith(
          scaffoldBackgroundColor: palette.surface,
          colorScheme: ColorScheme.fromSeed(
            seedColor: palette.primary,
            brightness: base.brightness,
          ).copyWith(
            primary: palette.primary,
            secondary: palette.secondary,
            surface: palette.card,
            background: palette.surface,
            onSurface: palette.text,
            onPrimary: palette.onPrimary,
            outline: palette.border,
          ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
          chipTheme: base.chipTheme.copyWith(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            labelStyle: base.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
            backgroundColor: palette.chip,
            selectedColor: palette.primary,
            secondarySelectedColor: palette.primary,
            showCheckmark: false,
            side: BorderSide(color: palette.border),
          ),
          dividerColor: palette.border,
        );

        final total = Duration(seconds: _perQuestionSeconds * _questionCount);
        String two(int x) => x.toString().padLeft(2, '0');
        final totalLabel = '${two(total.inMinutes)}:${two(total.inSeconds % 60)}';

        return Theme(
          data: themed,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Entraînement'),
              // actions supprimées (avatar "M" retiré)
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  // Header en dégradé (avatar "M" retiré)
                  _GradientHeader(
                    title: 'Bonjour 👋',
                    subtitle: 'Prêt(e) pour un rapide entraînement ?',
                    palette: palette,
                  ),
                  const SizedBox(height: 16),

                  // --- Blocs "Réglages rapides" et "Featured" SUPPRIMÉS ---

                  // Section chips : Temps par question
                  _SectionCard(
                    title: 'Temps par question',
                    icon: Icons.timer_outlined,
                    palette: palette,
                    child: ChipSelector<int>(
                      options: _secondOptions,
                      selected: _perQuestionSeconds,
                      onSelected: (s) => setState(() => _perQuestionSeconds = s),
                      spacing: 10,
                      runSpacing: 10,
                      labelBuilder: (s) => '${s}s',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section chips : Nombre de questions
                  _SectionCard(
                    title: 'Nombre de questions',
                    icon: Icons.confirmation_number_outlined,
                    palette: palette,
                    child: ChipSelector<int>(
                      options: _countOptions,
                      selected: _questionCount,
                      onSelected: (n) => setState(() => _questionCount = n),
                      spacing: 10,
                      runSpacing: 10,
                      labelBuilder: (n) => '$n',
                    ),
                  ),
                  const SizedBox(height: 12),

                  _InfoTile(
                    icon: Icons.schedule,
                    label: 'Temps total estimé',
                    value: totalLabel,
                    palette: palette,
                  ),
                ],
              ),
            ),

            // Bouton d’action centré
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _start,
                icon: _loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(palette.onPrimary),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_loading ? 'Chargement…' : 'Commencer maintenant'),
              ),
            ),

            // Nav bar fantôme pour laisser respirer le CTA
            bottomNavigationBar: const SizedBox(height: 12),
          ),
        );
      },
    );
  }
}

/// ----- Petits widgets inspirés du design -----

class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final _QuickStartPalette palette;
  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primaryDark, palette.primary],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: tt.bodyMedium!.copyWith(color: palette.onPrimary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall!.copyWith(
                      color: palette.onPrimary.withOpacity(0.7),
                      letterSpacing: .3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: tt.titleLarge!.copyWith(
                      color: palette.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Avatar "M" retiré
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final _QuickStartPalette palette;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.circle, size: 8, color: palette.primary),
            const SizedBox(width: 8),
            Icon(icon, color: palette.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final _QuickStartPalette palette;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: palette.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(color: palette.textMuted),
            ),
          ),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartPalette {
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color surface;
  final Color card;
  final Color chip;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color onPrimary;

  const _QuickStartPalette({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.surface,
    required this.card,
    required this.chip,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.onPrimary,
  });

  factory _QuickStartPalette.fromConfig(DesignConfig cfg) {
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
    final Color card = Color.alphaBlend(
      (cfg.darkMode ? Colors.white : Colors.black)
          .withOpacity(cfg.darkMode ? 0.12 : 0.03),
      surface,
    );
    final Color chip =
        Color.alphaBlend(primary.withOpacity(cfg.darkMode ? 0.24 : 0.1), surface);
    final Color text =
        textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
    final Color textMuted =
        Color.alphaBlend(text.withOpacity(cfg.darkMode ? 0.4 : 0.5), surfaceAlt);
    final Color border =
        Color.alphaBlend(text.withOpacity(cfg.darkMode ? 0.3 : 0.12), surfaceAlt);
    final Color onPrimary =
        ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return _QuickStartPalette(
      primary: primary,
      primaryDark: primaryDark,
      secondary: secondary,
      surface: surface,
      card: card,
      chip: chip,
      text: text,
      textMuted: textMuted,
      border: border,
      onPrimary: onPrimary,
    );
  }
}
