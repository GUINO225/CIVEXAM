import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civexam_app/models/question.dart';
import 'package:civexam_app/services/question_randomizer.dart';
import 'package:civexam_app/services/question_history_store.dart';

void main() {
  test('dedupeByQuestion avoids duplicates across sessions', () async {
    SharedPreferences.setMockInitialValues({});

    const q1 = Question(
      id: 'Q1',
      concours: 'ENA',
      subject: 'S',
      chapter: 'C',
      difficulty: 1,
      question: 'Dup?',
      choices: ['A', 'B'],
      answerIndex: 0,
    );
    const q2 = Question(
      id: 'Q2',
      concours: 'ENA',
      subject: 'S',
      chapter: 'C',
      difficulty: 1,
      question: 'Dup?',
      choices: ['A', 'B'],
      answerIndex: 0,
    );
    const q3 = Question(
      id: 'Q3',
      concours: 'ENA',
      subject: 'S',
      chapter: 'C',
      difficulty: 1,
      question: 'Unique?',
      choices: ['A', 'B'],
      answerIndex: 0,
    );

    final pool = [q1, q2, q3];

    final first = await pickAndShuffle(pool, 1,
        rng: Random(1), dedupeByQuestion: true);
    await QuestionHistoryStore.addAll(first.map((q) => q.id));

    final second = await pickAndShuffle(pool, 1,
        rng: Random(2), dedupeByQuestion: true);
    await QuestionHistoryStore.addAll(second.map((q) => q.id));

    expect(first.first.question, isNot(second.first.question));

    final third =
        await pickAndShuffle(pool, 1, rng: Random(3), dedupeByQuestion: true);
    expect(third, isEmpty);
  });
}
