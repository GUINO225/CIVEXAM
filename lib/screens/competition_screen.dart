import 'dart:async';

import 'package:flutter/material.dart';

import '../models/question.dart';

/// A minimalist competition screen showing a question with a
/// countdown timer and multiple possible answers.
class CompetitionScreen extends StatefulWidget {
  final List<Question> questions;
  final int currentIndex;
  final int correctCount;

  const CompetitionScreen({
    super.key,
    required this.questions,
    this.currentIndex = 0,
    this.correctCount = 0,
  });

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  int _selected = -1;
  int _seconds = 30;
  Timer? _timer;

  Question get _currentQuestion => widget.questions[widget.currentIndex];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
      _timer?.cancel();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0BBE4), Color(0xFF957DAD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.wifi, color: Colors.white),
                    Icon(Icons.battery_full, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'QUESTION ${widget.currentIndex + 1} OF ${widget.questions.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (widget.currentIndex + 1) / widget.questions.length,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                const SizedBox(height: 32),
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pinkAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _seconds.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _currentQuestion.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _onOptionTap(int i) {
    if (_selected >= 0) return;
    setState(() => _selected = i);
    final bool isCorrect = i == _currentQuestion.answerIndex;
    final int totalCorrect =
        widget.correctCount + (isCorrect ? 1 : 0);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (widget.currentIndex + 1 < widget.questions.length) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompetitionScreen(
              questions: widget.questions,
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
              total: widget.questions.length,
              correct: totalCorrect,
            ),
          ),
        );
      }
    });
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

