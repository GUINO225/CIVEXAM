import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:civexam_pro/services/question_loader.dart';
import 'package:civexam_pro/services/question_randomizer.dart';
import 'package:civexam_pro/services/question_history_store.dart';
import 'package:civexam_pro/services/exam_blueprint.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  ByteData _stringToByteData(String value) {
    final list = utf8.encode(value);
    final buffer = Uint8List.fromList(list).buffer;
    return ByteData.view(buffer);
  }

  void mockAssets(Map<String, String> assets) {
    binding.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      final asset = assets[key];
      if (asset == null) return null;
      return _stringToByteData(asset);
    });
  }

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
  });

  test('Concours ENA draws at least perSection questions per subject', () async {
    SharedPreferences.setMockInitialValues({});

    // Build a synthetic bank with more than enough questions for each subject.
    final subjects = [
      'Culture Générale',
      'Aptitude Verbale',
      'Organisation & Logique',
      'Aptitude Numérique',
    ];

    final data = <Map<String, dynamic>>[];
    for (final s in subjects) {
      for (int i = 0; i < ExamBlueprint.perSection + 5; i++) {
        data.add({
          'id': '${s.substring(0, 2)}$i',
          'concours': 'ENA',
          'subject': s,
          'chapter': 'Chap',
          'difficulty': 1,
          'question': 'Q$s$i?',
          'choices': ['A', 'B'],
          'answerIndex': 0,
        });
      }
    }

    final jsonBank = jsonEncode(data);
    mockAssets({'assets/questions/civexam_questions_ena_core.json': jsonBank});

    final all = await QuestionLoader.loadENA();
    expect(all.length, greaterThanOrEqualTo(ExamBlueprint.totalTarget));

    await QuestionHistoryStore.clear();
    for (final subject in subjects) {
      final pool = all.where((q) => q.subject == subject).toList();
      final qs = await pickAndShuffle(
        pool,
        ExamBlueprint.perSection,
        rng: Random(1),
        dedupeByQuestion: true,
      );
      expect(qs.length, ExamBlueprint.perSection);
      await QuestionHistoryStore.addAll(qs.map((q) => q.id));
    }
  });
}

