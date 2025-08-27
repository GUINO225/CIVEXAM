import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/models/question.dart';

void main() {
  test('Question parsing works', () {
    const raw = '''
    {
      "id": "Q-TEST-001",
      "concours": "ENA",
      "subject": "CG",
      "chapter": "Institutions",
      "difficulty": 2,
      "question": "Exemple ?",
      "choices": ["A","B","C","D"],
      "answerIndex": 1,
      "explanation": "ok"
    }
    ''';
    final map = json.decode(raw) as Map<String, dynamic>;
    final q = Question.fromMap(map);
    expect(q.id, "Q-TEST-001");
    expect(q.choices.length, 4);
    expect(q.answerIndex, 1);
  });
}
