import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/competition_theme.dart';
import '../services/leaderboard_hooks.dart';

/// Competition quiz screen with a circular countdown and progress tracking.
class CompetitionScreen extends StatefulWidget {
  /// List of questions drawn for the competition.
  final List<Question> questions;

  /// Number of questions in this session.
  final int drawCount;

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
    this.drawCount = 20,
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
    final theme = widget.theme ?? CompetitionTheme.fromTheme(Theme.of(context));
    return Scaffold(
      // Global background color comes from the theme.
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top card displaying the timer, question text and progress bar.
              Container(
                width: double.infinity,
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
                    // Countdown circle.
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.timerContainerColor,
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
                      'Question ${widget.currentIndex + 1}/${widget.drawCount}',
                      style: theme.questionIndexTextStyle,
                    ),
                    const SizedBox(height: 8),
                    // Actual question text.
                    Text(
                      _cleanQuestion(_currentQuestion.question),
                      style: theme.questionTextStyle,
                    ),
                    const SizedBox(height: 12),
                    // Progress bar for overall quiz progression.
                    LinearProgressIndicator(
                      value: (widget.currentIndex + 1) / widget.drawCount,
                      color: theme.progressBarColor,
                      backgroundColor:
                          theme.progressBarColor.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Chip displaying the selected answer when user taps an option.
              if (_selected >= 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.selectedChipBackgroundColor,
                    borderRadius: BorderRadius.circular(theme.selectedChipRadius),
                  ),
                  child: Text(
                    _currentQuestion.choices[_selected],
                    style: theme.selectedChipTextStyle,
                  ),
                ),
              const SizedBox(height: 24),
              // Answer options list.
              ...List.generate(_currentQuestion.choices.length, (i) {
                final bool isSelected = _selected == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: () => _onOptionTap(i),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.optionCardColor,
                        borderRadius:
                            BorderRadius.circular(theme.optionCardRadius),
                        boxShadow: theme.optionCardShadow,
                        border: isSelected
                            ? Border.all(
                                color: theme.optionSelectedBorderColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Text(
                        _currentQuestion.choices[i],
                        textAlign: TextAlign.center,
                        style: theme.optionTextStyle,
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _onOptionTap(int i) {
    // Prevent selecting multiple answers.
    if (_selected >= 0) return;
    setState(() => _selected = i);
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

    if (widget.currentIndex + 1 < widget.drawCount) {
      // Continue to the next question by replacing the current screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionScreen(
            questions: widget.questions,
            drawCount: widget.drawCount,
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
            total: widget.drawCount,
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

