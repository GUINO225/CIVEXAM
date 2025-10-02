import 'dart:ui' show clampDouble; // pour clampDouble
import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/competition_theme.dart';
import '../services/leaderboard_hooks.dart';
import '../utils/responsive_utils.dart';

/// Competition quiz screen with a circular countdown and progress tracking.
class CompetitionScreen extends StatefulWidget {
  final List<Question> questions;
  final int timePerQuestion;
  final int currentIndex;
  final int correctCount;
  final int wrongCount;
  final int blankCount;
  final DateTime startTime;
  final CompetitionTheme? theme;

  CompetitionScreen({
    super.key,
    required this.questions,
    this.timePerQuestion = 5,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.blankCount = 0,
    required this.startTime,
    this.theme,
  });

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen>
    with SingleTickerProviderStateMixin {
  int _selected = -1;
  int _highlighted = -1;
  bool _advanced = false; // garde-fou pour éviter double avance (tap + timer)

  late final AnimationController _controller;

  Question get _currentQuestion => widget.questions[widget.currentIndex];
  int get _remainingSeconds =>
      (_controller.value * widget.timePerQuestion).ceil();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timePerQuestion),
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) {
        if (s == AnimationStatus.dismissed && !_advanced) {
          _advanced = true;
          _goNext(); // temps écoulé => réponse blanche
        }
      });
    _controller.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _cleanQuestion(String q) {
    return q.replaceFirst(
      RegExp(r'^Question\s*\d+[:\.\)]?\s*', caseSensitive: false),
      '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = computeScaleFactor(mediaQuery);
    final textScaler = MediaQuery.textScalerOf(context);
    final theme =
        (widget.theme ?? CompetitionTheme.fromTheme(Theme.of(context)))
            .scaled(scale, textScaler);

    final TextStyle resolvedChipTextStyle =
        DefaultTextStyle.of(context).style.merge(theme.selectedChipTextStyle);

    final double optionFontSize = scaledFontSize(
      base: 18,
      scale: scale,
      textScaler: textScaler,
      min: 15,
      max: 26,
    );

    final double chipMinHeight =
        (resolvedChipTextStyle.fontSize ?? 16) *
            (resolvedChipTextStyle.height ?? 1.0) +
            16;

    final double topCardHeight = clampDouble(
      mediaQuery.size.height * 0.30,
      240.0,
      320.0,
    );

    // Couleur + icône spécifiques à la matière courante
    final Color subjectFg =
        _colorForSubject(_currentQuestion.subject, theme.timerColor);
    final Color subjectBg = subjectFg.withOpacity(0.10);
    final IconData subjectIcon = _iconForSubject(_currentQuestion.subject);

    final String appBarTitle = (_currentQuestion.subject.isEmpty)
        ? 'Quiz'
        : '${_currentQuestion.subject} Quiz';

    return Scaffold(
      backgroundColor: theme.backgroundColor,

      // ---------- AppBar violette ----------
      appBar: AppBar(
        backgroundColor: theme.appBarBackgroundColor,
        foregroundColor: theme.appBarForegroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(appBarTitle),
        actions: [
          _TopInfoPill(
            icon: Icons.person_outline_rounded,
            value: '1',
            theme: theme,
          ),
          const SizedBox(width: 8),
          _TopInfoPill(
            icon: Icons.emoji_events_outlined,
            value: '1',
            theme: theme,
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 3,
                value: widget.questions.isEmpty
                    ? 0
                    : (widget.currentIndex) / widget.questions.length,
                backgroundColor: theme.appBarProgressBackgroundColor,
                color: theme.appBarProgressColor,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ---------- Carte du haut ----------
              SizedBox(
                width: double.infinity,
                height: topCardHeight,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.questionCardColor,
                    borderRadius:
                    BorderRadius.circular(theme.questionCardRadius),
                    boxShadow: theme.questionCardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Compte à rebours (en violet 6C5CE7)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.timerColor
                                .withOpacity(0.08), // “partie grise” -> violet
                            borderRadius:
                                BorderRadius.circular(theme.timerContainerRadius),
                            boxShadow: theme.timerContainerShadow,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: theme.timerSize,
                                height: theme.timerSize,
                            child: CircularProgressIndicator(
                              value: _controller.value,
                              strokeWidth: theme.timerStrokeWidth,
                              color: theme.timerColor, // couleur du timer
                              backgroundColor: theme.timerColor
                                  .withOpacity(0.18), // anneau de fond
                            ),
                          ),
                          Text(
                            '$_remainingSeconds',
                            style: theme.timerTextStyle.copyWith(
                              color: theme.timerColor, // texte du timer en violet
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Question ${widget.currentIndex + 1}/${widget.questions.length}',
                        style: theme.questionIndexTextStyle,
                      ),
                      const SizedBox(height: 6),

                      // Rubrique + icône matière (fond violet doux)
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: subjectBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(subjectIcon, color: subjectFg, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _currentQuestion.subject,
                              style: theme.questionIndexTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            _cleanQuestion(_currentQuestion.question),
                            style: theme.questionTextStyle,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---------- Chip "réponse sélectionnée" ----------
              SizedBox(
                height: chipMinHeight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  // courbes sans overshoot
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    // pas de CurvedAnimation supplémentaire ici
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(animation),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _selected >= 0
                      ? AnimatedAlign(
                          key: ValueKey<int>(_selected),
                          alignment: Alignment.center,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color:
                                  theme.selectedChipBackgroundColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(theme.selectedChipRadius),
                            ),
                            constraints: BoxConstraints(minHeight: chipMinHeight),
                            child: Text(
                              _currentQuestion.choices[_selected],
                              style: theme.selectedChipTextStyle
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        )
                      : SizedBox(height: chipMinHeight),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Options ----------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(_currentQuestion.choices.length, (i) {
                    final bool isSelected = _selected == i;
                    final bool isHighlighted = _highlighted == i;
                    final borderRadius =
                    BorderRadius.circular(theme.optionCardRadius);
                    final Color baseColor = theme.optionCardColor;
                    final Color highlightOverlay =
                        theme.selectedChipBackgroundColor.withOpacity(0.06);
                    final Color selectedOverlay =
                        theme.selectedChipBackgroundColor.withOpacity(0.12);
                    final Color resolvedColor = isSelected
                        ? Color.alphaBlend(selectedOverlay, baseColor)
                        : isHighlighted
                            ? Color.alphaBlend(highlightOverlay, baseColor)
                            : baseColor;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: AnimatedScale(
                          scale: isHighlighted ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: borderRadius,
                            child: InkWell(
                              borderRadius: borderRadius,
                              splashColor:
                                  theme.selectedChipBackgroundColor.withOpacity(0.08),
                              highlightColor:
                                  theme.selectedChipBackgroundColor.withOpacity(0.04),
                              onHighlightChanged: (value) {
                                if (_selected >= 0 || _advanced) return;
                                setState(() {
                                  _highlighted = value ? i : -1;
                                });
                              },
                              onTap: (_selected >= 0 || _advanced)
                                  ? null
                                  : () => _onOptionTap(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                width: double.infinity,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: resolvedColor,
                                  borderRadius: borderRadius,
                                  boxShadow: theme.optionCardShadow,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.optionSelectedBorderColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _currentQuestion.choices[i],
                                  textAlign: TextAlign.center,
                                  style: theme.optionTextStyle
                                      .copyWith(fontSize: optionFontSize),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // tap : on NE stoppe PAS le timer et on avance de suite
  void _onOptionTap(int i) {
    if (_selected >= 0 || _advanced) return;
    setState(() {
      _selected = i;
      _highlighted = -1;
    });
    Future.microtask(() {
      if (!_advanced) {
        _advanced = true;
        _goNext(i);
      }
    });
  }

  void _goNext([int? selected]) {
    if (!mounted) return;

    final bool isBlank = selected == null;
    final bool isCorrect =
        selected != null && selected == _currentQuestion.answerIndex;
    final bool isWrong =
        selected != null && selected != _currentQuestion.answerIndex;

    final int totalCorrect = widget.correctCount + (isCorrect ? 1 : 0);
    final int totalWrong = widget.wrongCount + (isWrong ? 1 : 0);
    final int totalBlank = widget.blankCount + (isBlank ? 1 : 0);

    if (widget.currentIndex + 1 < widget.questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionScreen(
            questions: widget.questions,
            timePerQuestion: widget.timePerQuestion,
            currentIndex: widget.currentIndex + 1,
            correctCount: totalCorrect,
            wrongCount: totalWrong,
            blankCount: totalBlank,
            startTime: widget.startTime,
            theme: widget.theme,
          ),
        ),
      );
    } else {
      final durationSec =
          DateTime.now().difference(widget.startTime).inSeconds;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionResultScreen(
            total: widget.questions.length,
            correct: totalCorrect,
            wrong: totalWrong,
            blank: totalBlank,
            durationSec: durationSec,
            theme: widget.theme,
          ),
        ),
      );
    }
  }
}

class CompetitionResultScreen extends StatefulWidget {
  final int total;
  final int correct;
  final int wrong;
  final int blank;
  final int durationSec;
  final CompetitionTheme? theme;

  const CompetitionResultScreen({
    super.key,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.durationSec,
    this.theme,
  });

  @override
  State<CompetitionResultScreen> createState() =>
      _CompetitionResultScreenState();
}

class _CompetitionResultScreenState extends State<CompetitionResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LeaderboardHooks.saveCompetition(
        context: context,
        total: widget.total,
        correct: widget.correct,
        wrong: widget.wrong,
        blank: widget.blank,
        durationSec: widget.durationSec,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? CompetitionTheme.fromTheme(Theme.of(context));
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Résultat', style: theme.questionTextStyle),
            const SizedBox(height: 16),
            Text('Score: ${widget.correct} / ${widget.total}',
                style: theme.optionTextStyle),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Helpers: choix d’icône/couleur par matière ----------
String _normalize(String s) {
  final lower = s.toLowerCase();
  return lower
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c');
}

IconData _iconForSubject(String name) {
  final n = _normalize(name);
  if (n.contains('droit')) return Icons.gavel_rounded;
  if (n.contains('culture') || n.contains('generale')) return Icons.public_rounded;
  if (n.contains('communication')) return Icons.forum_rounded;
  if (n.contains('administrat')) return Icons.admin_panel_settings_rounded;
  if (n.contains('economie') || n.contains('economi')) return Icons.trending_up_rounded;
  if (n.contains('finance')) return Icons.account_balance_rounded;
  if (n.contains('statist')) return Icons.stacked_line_chart_rounded;
  if (n.contains('math')) return Icons.calculate_rounded;
  if (n.contains('informatique') || n.contains('tic')) return Icons.computer_rounded;
  if (n.contains('science')) return Icons.biotech_rounded;
  if (n.contains('geograph')) return Icons.map_rounded;
  if (n.contains('histoire')) return Icons.history_edu_rounded;
  if (n.contains('anglais') || n.contains('francais') || n.contains('français')) {
    return Icons.translate_rounded;
  }
  if (n.contains('logique') || n.contains('raisonnement') || n.contains('aptitude')) {
    return Icons.psychology_rounded;
  }
  return Icons.menu_book_rounded;
}

Color _colorForSubject(String name, Color fallbackColor) {
  final n = _normalize(name);
  if (n.contains('droit')) return const Color(0xFF3949AB); // indigo
  if (n.contains('culture') || n.contains('generale')) return const Color(0xFF6A1B9A); // purple
  if (n.contains('communication')) return const Color(0xFF00897B); // teal
  if (n.contains('administrat')) return const Color(0xFF5C6BC0); // indigo lighten
  if (n.contains('economie') || n.contains('economi')) return const Color(0xFFF57C00); // orange
  if (n.contains('finance')) return const Color(0xFF2E7D32); // green
  if (n.contains('statist')) return const Color(0xFF0277BD); // blue
  if (n.contains('math')) return const Color(0xFF1565C0); // blue darker
  if (n.contains('informatique') || n.contains('tic')) return const Color(0xFF546E7A); // blueGrey
  if (n.contains('science')) return const Color(0xFF512DA8); // deep purple
  if (n.contains('geograph')) return const Color(0xFF2E7D32); // green
  if (n.contains('histoire')) return const Color(0xFF6D4C41); // brown
  if (n.contains('anglais') || n.contains('francais') || n.contains('français')) {
    return const Color(0xFFAD1457); // pink
  }
  if (n.contains('logique') || n.contains('raisonnement') || n.contains('aptitude')) {
    return const Color(0xFF00838F); // cyan dark
  }
  return fallbackColor; // fallback basé sur le thème
}

/// Petite pastille pour l’AppBar (icône + valeur)
class _TopInfoPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final CompetitionTheme theme;
  const _TopInfoPill({
    required this.icon,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.topPillBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.topPillForegroundColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: theme.topPillForegroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
