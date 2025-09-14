import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/models/question.dart';
import 'package:civexam_app/services/question_loader.dart';
import 'package:civexam_app/services/question_randomizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  ByteData _stringToByteData(String value) {
    final list = utf8.encode(value);
    final buffer = Uint8List.fromList(list).buffer;
    return ByteData.view(buffer);
  }

  void mockAssets(Map<String, String> assets) {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      final asset = assets[key];
      if (asset == null) return null;
      return _stringToByteData(asset);
    });
  }

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
  });

  test('parses new schema correctly', () async {
    mockAssets({
      'assets/questions/civexam_questions_ena_core.json': '[{"id":"Q1","concours":"ENA","subject":"CG","chapter":"Intro","difficulty":3,"question":"Nouvelle?","choices":["A","B"],"answerIndex":1}]'
    });

    final questions = await QuestionLoader.loadENA();
    expect(questions, hasLength(1));
    final q = questions.first;
    expect(q.id, 'Q1');
    expect(q.concours, 'ENA');
    expect(q.difficulty, 3);
    expect(q.answerIndex, 1);
  });

  test('parses legacy schema correctly', () async {
    mockAssets({
      'assets/questions/civexam_questions_ena_core.json': '[{"subject":"CG","chapter":"Intro","difficulty":"moyen","question":"Legacy?","choices":["A","B"],"answerIndex":"0"}]'
    });

    final questions = await QuestionLoader.loadENA();
    expect(questions, hasLength(1));
    final q = questions.first;
    expect(q.id, 'CG-INTRO-1');
    expect(q.concours, 'ENA');
    expect(q.difficulty, 2);
    expect(q.answerIndex, 0);
  });

  test('throws when assets missing', () async {
    mockAssets({});

    await expectLater(QuestionLoader.loadENA(), throwsException);
  });

  test('pickAndShuffle is deterministic with injected Random', () async {
    SharedPreferences.setMockInitialValues({});
    final pool = [
      const Question(
        id: 'Q1',
        concours: 'ENA',
        subject: 'S',
        chapter: 'C',
        difficulty: 1,
        question: '1?',
        choices: ['A', 'B'],
        answerIndex: 0,
      ),
      const Question(
        id: 'Q2',
        concours: 'ENA',
        subject: 'S',
        chapter: 'C',
        difficulty: 1,
        question: '2?',
        choices: ['C', 'D'],
        answerIndex: 1,
      ),
      const Question(
        id: 'Q3',
        concours: 'ENA',
        subject: 'S',
        chapter: 'C',
        difficulty: 1,
        question: '3?',
        choices: ['E', 'F'],
        answerIndex: 0,
      ),
    ];

    final r1 = Random(1);
    final r2 = Random(1);

    final res1 = await pickAndShuffle(pool, 3, rng: r1);
    final res2 = await pickAndShuffle(pool, 3, rng: r2);

    expect(res1.map((q) => q.id).toList(), res2.map((q) => q.id).toList());
    expect(res1.first.choices, res2.first.choices);
  });
}
