import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/models/question.dart';
import 'package:civexam_app/services/question_loader.dart';
import 'package:civexam_app/screens/chapter_list_screen.dart';
import 'package:flutter/material.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Utility to simulate asset loading
  ByteData _stringToByteData(String value) {
    final list = utf8.encode(value);
    final buffer = Uint8List.fromList(list).buffer;
    return ByteData.view(buffer);
  }

  void mockAssets(Map<String, String> assets) {
    binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        final asset = assets[key];
        if (asset == null) return null;
        return _stringToByteData(asset);
      },
    );
  }

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
  });

  test('filterBy handles accents and aliases for subject/chapter', () {
    const q1 = Question(
      id: 'Q1',
      concours: 'ENA',
      subject: 'Culture Générale',
      chapter: 'Côte d’Ivoire',
      difficulty: 1,
      question: 'Q1?',
      choices: ['A'],
      answerIndex: 0,
    );
    const q2 = Question(
      id: 'Q2',
      concours: 'ENA',
      subject: 'Culture Générale',
      chapter: 'Geographie de la CI',
      difficulty: 1,
      question: 'Q2?',
      choices: ['A'],
      answerIndex: 0,
    );
    const q3 = Question(
      id: 'Q3',
      concours: 'ENA',
      subject: 'Droit Constitutionnel',
      chapter: 'Institutions & principes',
      difficulty: 1,
      question: 'Q3?',
      choices: ['A'],
      answerIndex: 0,
    );
    const q4 = Question(
      id: 'Q4',
      concours: 'ENA',
      subject: 'Droit (OHADA)',
      chapter: 'Institutions',
      difficulty: 1,
      question: 'Q4?',
      choices: ['A'],
      answerIndex: 0,
    );
    const q5 = Question(
      id: 'Q5',
      concours: 'ENA',
      subject: 'Organisation & Logique',
      chapter: 'Classements & déductions',
      difficulty: 1,
      question: 'Q5?',
      choices: ['A'],
      answerIndex: 0,
    );
    const q6 = Question(
      id: 'Q6',
      concours: 'ENA',
      subject: 'Logique',
      chapter: 'Classements & déductions',
      difficulty: 1,
      question: 'Q6?',
      choices: ['A'],
      answerIndex: 0,
    );

    final all = [q1, q2, q3, q4, q5, q6];

    final cg = QuestionLoader.filterBy(
      all,
      '',
      subject: 'Culture Generale',
      chapter: 'Cote dIvoire',
    );
    expect(cg.map((q) => q.id), ['Q1', 'Q2']);

    final droit = QuestionLoader.filterBy(
      all,
      '',
      subject: 'Droit Constitutionnel',
      chapter: 'Institutions & principes',
    );
    expect(droit.map((q) => q.id), ['Q3', 'Q4']);

    final logique = QuestionLoader.filterBy(
      all,
      '',
      subject: 'Organisation & Logique',
      chapter: 'Classements & déductions',
    );
    expect(logique.map((q) => q.id), ['Q5', 'Q6']);
  });

  testWidgets('ChapterListScreen filters questions for requested module', (tester) async {
    final questionsJson = jsonEncode([
      {
        'id': 'Q3',
        'concours': 'ENA',
        'subject': 'Droit Constitutionnel',
        'chapter': 'Institutions & principes',
        'difficulty': 1,
        'question': 'Q3?',
        'choices': ['A', 'B'],
        'answerIndex': 0,
      },
      {
        'id': 'Q4',
        'concours': 'ENA',
        'subject': 'Droit (OHADA)',
        'chapter': 'Institutions',
        'difficulty': 1,
        'question': 'Q4?',
        'choices': ['A', 'B'],
        'answerIndex': 0,
      },
    ]);

    mockAssets({
      'assets/questions/civexam_questions_ena_core.json': questionsJson,
    });

    await tester.pumpWidget(const MaterialApp(
      home: ChapterListScreen(
        subjectName: 'Droit Constitutionnel',
        chapterName: 'Institutions & principes',
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Questions dispo pour ce module : 2'), findsOneWidget);
  });
}

