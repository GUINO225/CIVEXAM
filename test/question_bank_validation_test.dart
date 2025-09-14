import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/data/ena_taxonomy.dart';

void main() {
  test('all questions have valid subject/chapter and no duplicates', () async {
    final file = File('assets/questions/civexam_questions_ena_core.json');
    final raw = await file.readAsString();
    final data = json.decode(raw);
    expect(data, isA<List>(), reason: 'JSON root should be a list');

    // Build a map from subject to allowed chapters
    final subjectChapters = {
      for (final s in subjectsENA) s.name: s.chapters.map((c) => c.name).toSet(),
    };

    final errors = <String>[];
    final seenIds = <String>{};
    final seenQuestions = <String>{};

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final id = item['id']?.toString() ?? '';
        final subject = item['subject']?.toString() ?? '';
        final chapter = item['chapter']?.toString() ?? '';
        final question = item['question']?.toString() ?? '';

        if (!seenIds.add(id)) {
          errors.add('Duplicate id "$id"');
        }

        if (!seenQuestions.add(question)) {
          errors.add('Duplicate question "$question"');
        }

        if (!subjectChapters.containsKey(subject)) {
          errors.add('Unknown subject "$subject" (id: $id)');
        } else if (!subjectChapters[subject]!.contains(chapter)) {
          errors.add('Unknown chapter "$chapter" for subject "$subject" (id: $id)');
        }
      } else {
        errors.add('Invalid question entry: $item');
      }
    }

    expect(errors, isEmpty, reason: errors.join('; '));
  });
}
