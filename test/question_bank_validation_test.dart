import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/data/ena_taxonomy.dart';

void main() {
  test('all questions have valid subject and chapter', () async {
    final file = File('assets/questions/civexam_questions_ena_core.json');
    final raw = await file.readAsString();
    final data = json.decode(raw);
    expect(data, isA<List>(), reason: 'JSON root should be a list');

    // Build a map from subject to allowed chapters
    final subjectChapters = {
      for (final s in subjectsENA) s.name: s.chapters.map((c) => c.name).toSet(),
    };

    final errors = <String>[];

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final subject = item['subject']?.toString() ?? '';
        final chapter = item['chapter']?.toString() ?? '';
        if (!subjectChapters.containsKey(subject)) {
          errors.add('Unknown subject "$subject" (id: ${item['id']})');
        } else if (!subjectChapters[subject]!.contains(chapter)) {
          errors.add('Unknown chapter "$chapter" for subject "$subject" (id: ${item['id']})');
        }
      } else {
        errors.add('Invalid question entry: $item');
      }
    }

    expect(errors, isEmpty, reason: errors.join('; '));
  });
}
