import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civexam_app/services/history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load skips invalid entries and purges them', () async {
    final attempt = Attempt(
      subject: 'Math',
      chapter: '1',
      score: 5,
      total: 10,
      durationSeconds: 60,
      timestamp: DateTime.utc(2024, 1, 1),
    );
    final valid = jsonEncode(attempt.toMap());
    const invalid = 'not-json';
    SharedPreferences.setMockInitialValues({
      'attempts_v1': [valid, invalid],
    });

    final attempts = await HistoryService.load();
    expect(attempts.length, 1);
    expect(attempts.first.subject, 'Math');
    expect(attempts.first.timestamp.isUtc, true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('attempts_v1'), [valid]);
  });
}
