import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import 'result_screen.dart';
import '../services/history_service.dart';

class ExamScreen extends StatefulWidget {
  final List<Question> questions;
  final int totalSeconds;
  const ExamScreen({super.key, required this.questions, required this.totalSeconds});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int index = 0;
  int score = 0;
  int? selected;
  late int remaining;
  Timer? timer;
  final answers = <int?>[];

  @override
  void initState() {
    super.initState();
    remaining = widget.totalSeconds;
    answers.addAll(List<int?>.filled(widget.questions.length, null));
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (remaining <= 0) {
        _finish();
      } else {
        setState(() => remaining--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _select(int i) {
    if (selected != null) return;
    setState(() {
      selected = i;
      answers[index] = i;
      if (i == widget.questions[index].answerIndex) score++;
    });
  }

  void _next() {
    if (index < widget.questions.length - 1) {
      setState(() {
        index++;
        selected = answers[index];
      });
    } else {
      _finish();
    }
  }

  void _finish() async {
    timer?.cancel();
    final q = widget.questions;
    await HistoryService.addAttempt(
      subject: q.first.subject,
      chapter: q.first.chapter,
      score: score,
      total: q.length,
      durationSeconds: widget.totalSeconds - remaining,
      timestamp: DateTime.now(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(
        questions: widget.questions,
        selectedAnswers: answers,
        score: score,
      )),
    );
  }

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final q = widget.questions[index];
        final cs = Theme.of(context).colorScheme;
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Examen ${index + 1}/${widget.questions.length}'),
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Chip(
                    label: Text(_formatTime(remaining),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: cs.errorContainer,
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(q.question,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: q.choices.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final isSelected = selected == i;
                          return InkWell(
                            onTap: () => _select(i),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primaryContainer
                                    : cs.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cs.outline),
                              ),
                              child: Text(q.choices[i]),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _next,
                      icon: Icon(index < widget.questions.length - 1
                          ? Icons.arrow_forward
                          : Icons.flag),
                      label: Text(index < widget.questions.length - 1
                          ? 'Suivant'
                          : 'Terminer'),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
