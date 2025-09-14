// lib/services/question_randomizer.dart
// -----------------------------------------------------------------------------
// Outils de tirage/mélange de questions. Préserve tous les champs obligatoires.
// -----------------------------------------------------------------------------
import 'dart:math';
import '../models/question.dart';
import 'question_history_store.dart';

final _rng = Random();

/// Retourne une **copie** de la question avec les choix mélangés
/// et un `answerIndex` recalculé.
Question shuffleChoices(Question q, {Random? rng}) {
  final r = rng ?? _rng;
  // permutation aléatoire des indices
  final order = List.generate(q.choices.length, (i) => i)..shuffle(r);

  final newChoices = <String>[];
  int newAnswer = 0;
  for (int pos = 0; pos < order.length; pos++) {
    final oldIdx = order[pos];
    newChoices.add(q.choices[oldIdx]);
    if (oldIdx == q.answerIndex) newAnswer = pos;
  }

  return Question(
    id: q.id,
    concours: q.concours,
    subject: q.subject,
    chapter: q.chapter,
    question: q.question,
    choices: newChoices,
    answerIndex: newAnswer,
    difficulty: q.difficulty,
    explanation: q.explanation,
  );
}

/// Sélectionne jusqu'à `take` questions **au hasard**, puis mélange l'ordre
/// des questions et des choix.
Future<List<Question>> pickAndShuffle(List<Question> pool, int take, {Random? rng}) async {
  final r = rng ?? _rng;
  if (pool.isEmpty) return const <Question>[];

  // Remove questions already seen according to the history store.
  final history = await QuestionHistoryStore.load();

  // Deduplicate by question id while filtering out history entries.
  final seen = <String>{};
  final filtered = pool
      .where((q) => !history.contains(q.id) && seen.add(q.id))
      .toList();

  final copy = List<Question>.from(filtered)..shuffle(r);
  final n = take <= copy.length ? take : copy.length;
  final selected = copy.take(n).map((q) => shuffleChoices(q, rng: r)).toList();
  return selected;
}
