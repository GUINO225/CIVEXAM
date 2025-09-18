// lib/services/question_randomizer.dart
// -----------------------------------------------------------------------------
// Outils de tirage/mélange de questions. Préserve tous les champs obligatoires.
// -----------------------------------------------------------------------------
import 'dart:math';
import 'package:flutter/foundation.dart';
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
///
/// > **Remarque** : si la déduplication aboutit à une liste vide alors que
/// > `pool` contient encore des éléments, l'historique est effacé et la
/// > fonction est rappelée avec `dedupeByQuestion: false`. Les modes
/// > consommateurs doivent donc prévoir qu'un réemploi de questions peut
/// > intervenir.
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

  // Prepare data for the isolate.
  final args = _PickAndShuffleArgs(
    pool: pool.map((q) => q.toMap()).toList(),
    history: history,
    take: take,
    dedupeByQuestion: dedupeByQuestion,
    rngSeed: r.nextInt(1 << 32),
  );

  final argsMap = args.toMap();

  Map<String, dynamic> result;
  if (kIsWeb) {
    result = _pickAndShuffleIsolate(argsMap);
  } else {
    try {
      result = await compute(_pickAndShuffleIsolate, argsMap);
    } on UnsupportedError {
      result = _pickAndShuffleIsolate(argsMap);
    }
  }

  final selectedMaps = List<Map<String, dynamic>>.from(
      (result['selected'] as List).map((e) => Map<String, dynamic>.from(e)));
  final selected =
      selectedMaps.map((m) => Question.fromMap(m)).toList(growable: false);
  final needsRetry = result['needsRetry'] as bool;

  if (needsRetry) {
    await QuestionHistoryStore.clear();
    final retry =
        await pickAndShuffle(pool, take, rng: r, dedupeByQuestion: false);
    return retry.take(take).toList();
  }

  return selected;
}

class _PickAndShuffleArgs {
  final List<Map<String, dynamic>> pool;
  final Iterable<String> history;
  final int take;
  final bool dedupeByQuestion;
  final int rngSeed;

  const _PickAndShuffleArgs({
    required this.pool,
    required this.history,
    required this.take,
    required this.dedupeByQuestion,
    required this.rngSeed,
  });

  Map<String, dynamic> toMap() => {
        'pool': pool,
        'history': history.toList(),
        'take': take,
        'dedupeByQuestion': dedupeByQuestion,
        'rngSeed': rngSeed,
      };

  factory _PickAndShuffleArgs.fromMap(Map<String, dynamic> map) {
    return _PickAndShuffleArgs(
      pool: List<Map<String, dynamic>>.from(
          (map['pool'] as List).map((e) => Map<String, dynamic>.from(e))),
      history: List<String>.from(map['history'] as List),
      take: map['take'] as int,
      dedupeByQuestion: map['dedupeByQuestion'] as bool,
      rngSeed: map['rngSeed'] as int,
    );
  }
}

Map<String, dynamic> _pickAndShuffleIsolate(Map<String, dynamic> argsMap) {
  final args = _PickAndShuffleArgs.fromMap(argsMap);
  final pool =
      args.pool.map((m) => Question.fromMap(m)).toList(growable: false);
  final history = args.history.toSet();

  final r = Random(args.rngSeed);

  final historyTexts = args.dedupeByQuestion
      ? pool
          .where((q) => history.contains(q.id))
          .map((q) => q.question)
          .toSet()
      : <String>{};

  final seenIds = <String>{};
  final seenQuestions = <String>{};
  final filtered = <Question>[];
  for (final q in pool) {
    if (history.contains(q.id)) continue;
    if (!seenIds.add(q.id)) continue;
    if (args.dedupeByQuestion) {
      if (historyTexts.contains(q.question)) continue;
      if (!seenQuestions.add(q.question)) continue;
    }
    filtered.add(q);
  }

  var needsRetry = false;
  if (filtered.length < args.take && pool.length > filtered.length) {
    if (history.isNotEmpty || args.dedupeByQuestion) {
      needsRetry = true;
    }
  }

  final copy = List<Question>.from(filtered)..shuffle(r);
  final n = args.take <= copy.length ? args.take : copy.length;
  final selected = copy.take(n).map((q) => shuffleChoices(q, rng: r)).toList();

  if (args.dedupeByQuestion && selected.length < args.take) {
    needsRetry = true;
  }

  return {
    'selected': selected.map((q) => q.toMap()).toList(),
    'needsRetry': needsRetry,
  };
}
