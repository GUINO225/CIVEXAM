import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civexam_app/models/question.dart';
import 'package:civexam_app/services/question_randomizer.dart';
import 'package:civexam_app/services/question_history_store.dart';

void main() {
  test('returns at least 10 questions when pool has enough items', () async {
    SharedPreferences.setMockInitialValues({});

    final pool = List<Question>.generate(
      20,
      (i) => Question(
        id: 'Q\${i + 1}',
        concours: 'ENA',
        subject: 'S',
        chapter: 'C',
        difficulty: 1,
        question: 'Question \${i + 1}?',
        choices: ['A', 'B'],
        answerIndex: 0,
      ),
    );

    await QuestionHistoryStore.addAll(pool.take(15).map((q) => q.id));

    final selected = await pickAndShuffle(pool, 10, rng: Random(42));
    expect(selected.length, greaterThanOrEqualTo(10));
  });
}
