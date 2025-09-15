import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/competition_theme.dart';
import '../services/leaderboard_hooks.dart';

/// Competition quiz screen with a circular countdown and progress tracking.
class CompetitionScreen extends StatefulWidget {
  /// List of questions drawn for the competition.
  final List<Question> questions;

  /// Time allowed for each question (seconds).
  final int timePerQuestion;

  /// Index of the currently displayed question.
  final int currentIndex;

  /// Number of correct answers so far.
  final int correctCount;

  /// Number of wrong answers so far.
  final int wrongCount;

  /// Number of unanswered questions.
  final int blankCount;

  /// Start time of the competition.
  final DateTime startTime;

  /// Visual theme used to style the screen.
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
  /// Currently selected answer index. `-1` means no selection yet.
  int _selected = -1;

  /// Index of the option currently highlighted by a press gesture.
  int _highlighted = -1;

  /// Animation controller driving the countdown timer.
  late final AnimationController _controller;

  /// Convenient getter for the question being displayed.
  Question get _currentQuestion => widget.questions[widget.currentIndex];

  /// Remaining seconds on the countdown clock.
  int get _remainingSeconds =>
      (_controller.value * widget.timePerQuestion).ceil();

  @override
  void initState() {
    super.initState();
    // Initialize the timer controller with the provided duration.
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timePerQuestion),
    )
      // Rebuild the widget tree every tick to update the remaining time.
      ..addListener(() => setState(() {}))
      // When the animation completes (time runs out), move to the next question.
      ..addStatusListener((s) {
        if (s == AnimationStatus.dismissed) _goNext();
      });
    // Start the countdown immediately.
    _controller.reverse(from: 1.0);
  }

  @override
  void dispose() {
    // Always dispose animation controllers to free resources.
    _controller.dispose();
    super.dispose();
  }

  /// Removes any "Question XX:" prefix from the question text.
  String _cleanQuestion(String q) {
    return q.replaceFirst(
        RegExp(r'^Question\s*\d+[:\.\)]?\s*', caseSensitive: false),
        '');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = widget.theme ?? CompetitionTheme.fromTheme(Theme.of(context));
    final TextStyle resolvedChipTextStyle =
        DefaultTextStyle.of(context).style.merge(theme.selectedChipTextStyle);
    final double chipMinHeight =
        (resolvedChipTextStyle.fontSize ?? 16) *
                (resolvedChipTextStyle.height ?? 1.0) +
            16;
    final double topCardHeight =
        (mediaQuery.size.height * 0.3).clamp(240.0, 320.0) as double;
    return Scaffold(
      // Global background color comes from the theme.
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top card displaying the timer, question text and progress bar.
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
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Countdown circle.
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.timerContainerColor,
                            borderRadius: BorderRadius.circular(
                                theme.timerContainerRadius),
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
                                  color: theme.timerColor,
                                ),
                              ),
                              Text(
                                '$_remainingSeconds',
                                style: theme.timerTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Question number within the current session.
                      Text(
                        'Question ${widget.currentIndex + 1}/${widget.questions.length}',
                        style: theme.questionIndexTextStyle,
                      ),
                      const SizedBox(height: 4),
                      // Rubric/subject of the current question.
                      Text(
                        'Rubrique : ${_currentQuestion.subject}',
                        style: theme.questionIndexTextStyle,
                      ),
                      const SizedBox(height: 8),
                      // Actual question text.
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
                      const SizedBox(height: 12),
                      // Progress bar for overall quiz progression.
                      LinearProgressIndicator(
                        value:
                            (widget.currentIndex + 1) / widget.questions.length,
                        color: theme.progressBarColor,
                        backgroundColor:
                            theme.progressBarColor.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Chip displaying the selected answer when user taps an option.
              SizedBox(
                height: chipMinHeight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(curved),
                        child: ScaleTransition(
                          scale:
                              Tween<double>(begin: 0.92, end: 1).animate(curved),
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: theme.selectedChipBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                theme.selectedChipRadius,
                              ),
                            ),
                            constraints:
                                BoxConstraints(minHeight: chipMinHeight),
                            child: Text(
                              _currentQuestion.choices[_selected],
                              style: theme.selectedChipTextStyle,
                            ),
                          ),
                        )
                      : SizedBox(height: chipMinHeight),
                ),
              ),
              const SizedBox(height: 24),
              // Answer options list.
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
                        theme.optionSelectedBorderColor.withOpacity(0.06);
                    final Color selectedOverlay =
                        theme.optionSelectedBorderColor.withOpacity(0.12);
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
                              splashColor: theme.optionSelectedBorderColor
                                  .withOpacity(0.08),
                              highlightColor: theme.optionSelectedBorderColor
                                  .withOpacity(0.04),
                              onHighlightChanged: (value) {
                                if (_selected >= 0) return;
                                setState(() {
                                  _highlighted = value ? i : -1;
                                });
                              },
                              onTap: _selected >= 0
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
                                      .copyWith(fontSize: 18),
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

  void _onOptionTap(int i) {
    // Prevent selecting multiple answers.
    if (_selected >= 0) return;
    setState(() {
      _selected = i;
      _highlighted = -1;
    });
    // Pause the timer and move to next question shortly after.
    _controller.stop();
    Future.delayed(const Duration(milliseconds: 300), () => _goNext(i));
  }

  void _goNext([int? selected]) {
    // Determine whether the chosen option (if any) is correct, wrong or blank.
    final bool isBlank = selected == null;
    final bool isCorrect =
        selected != null && selected == _currentQuestion.answerIndex;
    final bool isWrong = selected != null && selected != _currentQuestion.answerIndex;

    final int totalCorrect =
        widget.correctCount + (isCorrect ? 1 : 0);
    final int totalWrong = widget.wrongCount + (isWrong ? 1 : 0);
    final int totalBlank = widget.blankCount + (isBlank ? 1 : 0);

    if (widget.currentIndex + 1 < widget.questions.length) {
      // Continue to the next question by replacing the current screen.
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
      // All questions answered: show result screen.
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
  /// Total number of questions answered.
  final int total;

  /// Number of correct answers.
  final int correct;

  /// Number of wrong answers.
  final int wrong;

  /// Number of unanswered questions.
  final int blank;

  /// Total duration of the competition (in seconds).
  final int durationSec;

  /// Theme used to style the result screen.
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
  State<CompetitionResultScreen> createState() => _CompetitionResultScreenState();
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
            // Title of the result screen.
            Text(
              'Résultat',
              style: theme.questionTextStyle,
            ),
            const SizedBox(height: 16),
            // Display final score.
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

