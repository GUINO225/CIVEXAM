import 'package:flutter_test/flutter_test.dart';

import 'package:civexam_pro/screens/multi_exam_flow.dart';

void main() {
  group('secondsPerQuestion', () {
    test('returns 216 seconds for facile (+50%)', () {
      expect(secondsPerQuestion(ExamDifficulty.facile), 216);
    });

    test('returns null for normal (default pacing)', () {
      expect(secondsPerQuestion(ExamDifficulty.normal), isNull);
    });

    test('returns 108 seconds for difficile (-25%)', () {
      expect(secondsPerQuestion(ExamDifficulty.difficile), 108);
    });

    test('returns 72 seconds for expert (-50%)', () {
      expect(secondsPerQuestion(ExamDifficulty.expert), 72);
    });
  });
}
