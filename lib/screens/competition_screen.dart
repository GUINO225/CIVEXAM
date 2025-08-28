import 'package:flutter/material.dart';

import '../models/question.dart';

/// Competition quiz screen with a circular countdown and progress tracking.
class CompetitionScreen extends StatefulWidget {
  final List<Question> questions;
  final Map<String, int> indexMap;
  final int poolSize;
  final int drawCount;
  final int timePerQuestion;
  final int currentIndex;
  final int correctCount;

  const CompetitionScreen({
    super.key,
    required this.questions,
    required this.indexMap,
    this.poolSize = 500,
    this.drawCount = 50,
    this.timePerQuestion = 5,
    this.currentIndex = 0,
    this.correctCount = 0,
  });

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen>
    with SingleTickerProviderStateMixin {
  int _selected = -1;
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
        if (s == AnimationStatus.dismissed) _goNext();
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
        '');
  }

  @override
  Widget build(BuildContext context) {
    final questionIndex = widget.indexMap[_currentQuestion.id] ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: _controller.value,
                                strokeWidth: 6,
                              ),
                            ),
                            Text(
                              '$_remainingSeconds',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Question $questionIndex/${widget.poolSize}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cleanQuestion(_currentQuestion.question),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (widget.currentIndex + 1) / widget.drawCount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_selected >= 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentQuestion.choices[_selected],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: isSelected
                            ? Border.all(
                                color: Colors.pinkAccent,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Text(
                        _currentQuestion.choices[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
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
    if (_selected >= 0) return;
    setState(() => _selected = i);
    _controller.stop();
    Future.delayed(const Duration(milliseconds: 300), () => _goNext(i));
  }

  void _goNext([int? selected]) {
    final isCorrect = selected != null &&
        selected == _currentQuestion.answerIndex;
    final int totalCorrect =
        widget.correctCount + (isCorrect ? 1 : 0);
    if (widget.currentIndex + 1 < widget.drawCount) {
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
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionResultScreen(
            total: widget.drawCount,
            correct: totalCorrect,
          ),
        ),
      );
    }
  }
}

class CompetitionResultScreen extends StatelessWidget {
  final int total;
  final int correct;

  const CompetitionResultScreen({super.key, required this.total, required this.correct});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Résultat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Score: $correct / $total'),
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

