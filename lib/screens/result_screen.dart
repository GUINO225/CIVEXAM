import 'package:flutter/material.dart';
import '../models/question.dart';
import 'leaderboard_screen.dart';

class ResultScreen extends StatelessWidget {
  final List<Question> questions;
  final List<int?> selectedAnswers;
  final int score;
  const ResultScreen({super.key, required this.questions, required this.selectedAnswers, required this.score});

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final pct = (score / total * 100).toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(title: const Text('Résultats détaillés')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Text('Score: $score / $total', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('$pct % de réussite'),
                const SizedBox(height: 16),
                const Divider(),
              ],
            ),
          ),
          for (int i = 0; i < questions.length; i++)
            _ResultTile(q: questions[i], selected: selectedAnswers[i], index: i + 1),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
            icon: const Icon(Icons.emoji_events),
            label: const Text('Voir le classement'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.home),
            label: const Text('Retour'),
          )
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final Question q;
  final int? selected;
  final int index;
  const _ResultTile({required this.q, required this.selected, required this.index});

  @override
  Widget build(BuildContext context) {
    final correct = q.answerIndex;
    Color badge = selected == correct ? Colors.green : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: badge, child: Text('$index')),
                const SizedBox(width: 8),
                Expanded(child: Text(q.question, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 8),
            Text('Votre réponse : ${selected != null ? q.choices[selected!] : '— (non répondu)'}'),
            Text('Bonne réponse : ${q.choices[correct]}'),
            if (q.explanation != null) ...[
              const SizedBox(height: 6),
              Text('Explication : ${q.explanation!}'),
            ]
          ],
        ),
      ),
    );
  }
}
