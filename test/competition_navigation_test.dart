import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civexam_pro/models/question.dart';
import 'package:civexam_pro/screens/competition_screen.dart';

void main() {
  testWidgets('CompetitionScreen navigates through all questions',
      (tester) async {
    final questions = List.generate(
      3,
      (i) => Question(
        id: 'q$i',
        concours: 'ENA',
        subject: 'Sujet',
        chapter: 'Chap',
        difficulty: 1,
        question: 'Question $i',
        choices: const ['A', 'B'],
        answerIndex: 0,
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: CompetitionScreen(
        questions: questions,
        timePerQuestion: 5,
        startTime: DateTime.now(),
      ),
    ));

    for (var i = 0; i < questions.length; i++) {
      expect(
        find.text('Question ${i + 1}/${questions.length}'),
        findsOneWidget,
      );

      if (i < questions.length - 1) {
        await tester.tap(find.text('A'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
    }
  });
}

