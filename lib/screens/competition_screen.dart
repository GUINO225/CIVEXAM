import 'dart:async';

import 'package:flutter/material.dart';

/// Concours ENA question UI with gradient background, timer and answers.
class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  static const _totalQuestions = 10;
  static const _currentQuestion = 3;
  int _seconds = 30;
  String? _selected;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
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
            colors: [Color(0xffd1c4e9), Color(0xffb39ddb)],
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
                    Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    Icon(Icons.more_horiz, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'QUESTION $_currentQuestion OF $_totalQuestions',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _currentQuestion / _totalQuestions,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pinkAccent,
                    ),
                    child: Center(
                      child: Text(
                        '$_seconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Which player is from Senegal?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                if (_selected != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selected!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _answerButton('Sadio Mane'),
                const SizedBox(height: 12),
                _answerButton('Harry Kane'),
                const SizedBox(height: 12),
                _answerButton('Christian Benteke'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerButton(String text) {
    final bool selected = _selected == text;
    return GestureDetector(
      onTap: () => setState(() => _selected = text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: selected
              ? Border.all(color: Colors.pinkAccent, width: 2)
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

