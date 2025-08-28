import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/competition_theme.dart';

/// Competition quiz screen with a circular countdown and progress tracking.
class CompetitionScreen extends StatefulWidget {
  /// List of questions drawn for the competition.
  final List<Question> questions;

  /// Maps question IDs to their global index. Used for display.
  final Map<String, int> indexMap;

  /// Total size of the question pool.
  final int poolSize;

  /// Number of questions in this session.
  final int drawCount;

  /// Time allowed for each question (seconds).
  final int timePerQuestion;

  /// Index of the currently displayed question.
  final int currentIndex;

  /// Number of correct answers so far.
  final int correctCount;

  /// Visual theme used to style the screen.
  final CompetitionTheme theme;

  const CompetitionScreen({
    super.key,
    required this.questions,
    required this.indexMap,
    this.poolSize = 500,
    this.drawCount = 50,
    this.timePerQuestion = 5,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.theme = kDefaultCompetitionTheme,
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
    final questionIndex = widget.indexMap[_currentQuestion.id] ?? 0;
    return Scaffold(
      // Global background color comes from the theme.
      backgroundColor: widget.theme.backgroundColor,
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
                  color: widget.theme.questionCardColor,
                  borderRadius:
                      BorderRadius.circular(widget.theme.questionCardRadius),
                  boxShadow: widget.theme.questionCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Countdown circle.
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.theme.timerContainerColor,
                          borderRadius: BorderRadius.circular(
                              widget.theme.timerContainerRadius),
                          boxShadow: widget.theme.timerContainerShadow,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: widget.theme.timerSize,
                              height: widget.theme.timerSize,
                              child: CircularProgressIndicator(
                                value: _controller.value,
                                strokeWidth: widget.theme.timerStrokeWidth,
                                color: widget.theme.timerColor,
                              ),
                            ),
                            Text(
                              '$_remainingSeconds',
                              style: widget.theme.timerTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Question number within the pool.
                    Text(
                      'Question $questionIndex/${widget.poolSize}',
                      style: widget.theme.questionIndexTextStyle,
                    ),
                    const SizedBox(height: 8),
                    // Actual question text.
                    Text(
                      _cleanQuestion(_currentQuestion.question),
                      style: widget.theme.questionTextStyle,
                    ),
                    const SizedBox(height: 12),
                    // Progress bar for overall quiz progression.
                    LinearProgressIndicator(
                      value: (widget.currentIndex + 1) / widget.drawCount,
                      color: widget.theme.progressBarColor,
                      backgroundColor:
                          widget.theme.progressBarColor.withOpacity(0.3),
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
                    color: widget.theme.selectedChipBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(widget.theme.selectedChipRadius),
                  ),
                  child: Text(
                    _currentQuestion.choices[_selected],
                    style: widget.theme.selectedChipTextStyle,
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
                        color: widget.theme.optionCardColor,
                        borderRadius: BorderRadius.circular(
                            widget.theme.optionCardRadius),
                        boxShadow: widget.theme.optionCardShadow,
                        border: isSelected
                            ? Border.all(
                                color: widget.theme.optionSelectedBorderColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Text(
                        _currentQuestion.choices[i],
                        textAlign: TextAlign.center,
                        style: widget.theme.optionTextStyle,
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
    // Determine whether the chosen option (if any) is correct.
    final isCorrect = selected != null &&
        selected == _currentQuestion.answerIndex;
    final int totalCorrect =
        widget.correctCount + (isCorrect ? 1 : 0);
    if (widget.currentIndex + 1 < widget.drawCount) {
      // Continue to the next question by replacing the current screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionScreen(
            questions: widget.questions,
            indexMap: widget.indexMap,
            poolSize: widget.poolSize,
            drawCount: widget.drawCount,
            timePerQuestion: widget.timePerQuestion,
            currentIndex: widget.currentIndex + 1,
            correctCount: totalCorrect,
            theme: widget.theme,
          ),
        ),
      );
    } else {
      // All questions answered: show result screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionResultScreen(
            total: widget.drawCount,
            correct: totalCorrect,
            theme: widget.theme,
          ),
        ),
      );
    }
  }
}

class CompetitionResultScreen extends StatelessWidget {
  /// Total number of questions answered.
  final int total;

  /// Number of correct answers.
  final int correct;

  /// Theme used to style the result screen.
  final CompetitionTheme theme;

  const CompetitionResultScreen({
    super.key,
    required this.total,
    required this.correct,
    this.theme = kDefaultCompetitionTheme,
  });

  @override
  Widget build(BuildContext context) {
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
            Text('Score: $correct / $total', style: theme.optionTextStyle),
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

