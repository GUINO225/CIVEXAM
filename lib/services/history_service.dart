import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Attempt {
  final String subject;
  final String chapter;
  final int score;
  final int total;
  final int durationSeconds;
  final DateTime timestamp;

  const Attempt({
    required this.subject,
    required this.chapter,
    required this.score,
    required this.total,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'subject': subject,
    'chapter': chapter,
    'score': score,
    'total': total,
    'durationSeconds': durationSeconds,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  factory Attempt.fromMap(Map<String, dynamic> m) => Attempt(
    subject: m['subject'] as String,
    chapter: m['chapter'] as String,
    score: (m['score'] as num).toInt(),
    total: (m['total'] as num).toInt(),
    durationSeconds: (m['durationSeconds'] as num).toInt(),
    timestamp: DateTime.parse(m['timestamp'] as String).toUtc(),
  );
}

class HistoryService {
  static const _key = 'attempts_v1';
  static const int _maxAttempts = 100;

  static Future<void> addAttempt({
    required String subject,
    required String chapter,
    required int score,
    required int total,
    required int durationSeconds,
    required DateTime timestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    final a = Attempt(
      subject: subject,
      chapter: chapter,
      score: score,
      total: total,
      durationSeconds: durationSeconds,
      timestamp: timestamp,
    );
    list.add(jsonEncode(a.toMap()));
    if (list.length > _maxAttempts) list.removeAt(0);
    await prefs.setStringList(_key, list);
  }

  static Future<List<Attempt>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    final valid = <String>[];
    final attempts = <Attempt>[];
    for (final s in list) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        attempts.add(Attempt.fromMap(m));
        valid.add(s);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Ignoring corrupted attempt entry: $e');
        }
      }
    }
    if (valid.length != list.length) {
      await prefs.setStringList(_key, valid);
    }
    return attempts;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
