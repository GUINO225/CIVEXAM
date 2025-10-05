import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civexam_pro/models/question.dart';
import 'package:civexam_pro/screens/competition_screen.dart';
import 'package:civexam_pro/widgets/play_bottom_nav_bar.dart';

void main() {
  testWidgets('Selecting an option automatically advances to next question',
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

    await tester.pump();

    expect(find.text('Question 1/3'), findsOneWidget);

    await tester.tap(find.text('A').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Question 2/3'), findsOneWidget);

    await tester.tap(find.text('A').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Question 3/3'), findsOneWidget);

    await tester.tap(find.text('A').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Résultat'), findsOneWidget);
  });

  testWidgets('Competition screen shows play bottom navigation without Next button',
      (tester) async {
    final questions = [
      Question(
        id: 'q0',
        concours: 'ENA',
        subject: 'Sujet',
        chapter: 'Chap',
        difficulty: 1,
        question: 'Question',
        choices: const ['Option 1', 'Option 2'],
        answerIndex: 0,
      ),
    ];

    await tester.pumpWidget(MaterialApp(
      home: CompetitionScreen(
        questions: questions,
        timePerQuestion: 5,
        startTime: DateTime.now(),
      ),
    ));

    expect(find.byType(PlayBottomNavBar), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });
}

