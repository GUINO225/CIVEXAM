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
///
/// Lorsque [dedupeByQuestion] est `true`, les doublons basés sur le texte de la
/// question sont éliminés, y compris ceux déjà rencontrés lors de sessions
/// précédentes.
Future<List<Question>> pickAndShuffle(
  List<Question> pool,
  int take, {
  Random? rng,
  bool dedupeByQuestion = false,
}) async {
  final r = rng ?? _rng;
  if (pool.isEmpty) return const <Question>[];

  // Remove questions already seen according to the history store.
  final history = await QuestionHistoryStore.load();

  // When dedupeByQuestion is enabled, compute the set of question texts that
  // have already been seen in previous sessions.
  final historyTexts = dedupeByQuestion
      ? pool
          .where((q) => history.contains(q.id))
          .map((q) => q.question)
          .toSet()
      : <String>{};

  // Deduplicate by question id (and optionally by question text) while
  // filtering out history entries.
  final seenIds = <String>{};
  final seenQuestions = <String>{};
  final filtered = <Question>[];
  for (final q in pool) {
    if (history.contains(q.id)) continue;
    if (!seenIds.add(q.id)) continue;
    if (dedupeByQuestion) {
      if (historyTexts.contains(q.question)) continue;
      if (!seenQuestions.add(q.question)) continue;
    }
    filtered.add(q);
  }

  final copy = List<Question>.from(filtered)..shuffle(r);
  final n = take <= copy.length ? take : copy.length;
  final selected = copy.take(n).map((q) => shuffleChoices(q, rng: r)).toList();
  return selected;
}
