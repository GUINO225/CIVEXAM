import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int index = 0;
  int score = 0;
  int? selected;

  void _select(int i) {
    if (selected != null) return;
    setState(() {
      selected = i;
      if (i == widget.questions[index].answerIndex) score++;
    });
  }

  void _next() {
    if (index < widget.questions.length - 1) {
      setState(() {
        index++;
        selected = null;
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => _ResultScreen(score: score, total: widget.questions.length)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final q = widget.questions[index];
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              title: Text('Question ${index + 1}/${widget.questions.length}')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(q.question,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          for (int i = 0; i < q.choices.length; i++) ...[
                            _ChoiceTile(
                              text: q.choices[i],
                              state: selected == null
                                  ? ChoiceState.neutral
                                  : (i == q.answerIndex
                                      ? ChoiceState.correct
                                      : (i == selected
                                          ? ChoiceState.wrong
                                          : ChoiceState.neutral)),
                              onTap: () => _select(i),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (selected != null && q.explanation != null) ...[
                            const SizedBox(height: 12),
                            Text('Explication: ${q.explanation!}'),
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: selected == null ? null : _next,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(index < widget.questions.length - 1
                        ? 'Suivant'
                        : 'Terminer'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum ChoiceState { neutral, correct, wrong }

class _ChoiceTile extends StatelessWidget {
  final String text;
  final ChoiceState state;
  final VoidCallback? onTap;
  const _ChoiceTile({required this.text, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    switch (state) {
      case ChoiceState.correct:
        bg = cs.primaryContainer;
        break;
      case ChoiceState.wrong:
        bg = cs.errorContainer;
        break;
      default:
        bg = cs.surfaceVariant;
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Text(text),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  const _ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (score / total * 100).toStringAsFixed(0);
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Résultats')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Score: $score / $total',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('$pct % de réussite'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.replay),
                  label: const Text('Rejouer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
