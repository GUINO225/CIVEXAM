import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ExamHistoryEntry {
  final DateTime date;
  final Map<String, int> correctBySubject;
  final Map<String, int> totalBySubject;
  final Map<String, int> scoresBruts;
  final Map<String, int> scoresPonderes;
  final int totalPondere;
  final bool success;
  final bool abandoned; // NEW

  const ExamHistoryEntry({
    required this.date,
    required this.correctBySubject,
    required this.totalBySubject,
    required this.scoresBruts,
    required this.scoresPonderes,
    required this.totalPondere,
    required this.success,
    this.abandoned = false,
  });

  List<String> weakSubjects({double threshold = 0.5}) {
    final List<String> out = [];
    for (final s in totalBySubject.keys) {
      final tot = totalBySubject[s] ?? 0;
      final ok = correctBySubject[s] ?? 0;
      if (tot > 0 && ok / tot < threshold) out.add(s);
    }
    return out;
  }

  Map<String, dynamic> toJson() => {
        'date': Timestamp.fromDate(date.toUtc()),
        'correctBySubject': correctBySubject,
        'totalBySubject': totalBySubject,
        'scoresBruts': scoresBruts,
        'scoresPonderes': scoresPonderes,
        'totalPondere': totalPondere,
        'success': success,
        'abandoned': abandoned,
      };

  factory ExamHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ExamHistoryEntry(
      date: _parseDate(json['date']),
      correctBySubject: _castToIntMap(json['correctBySubject'] as Map?),
      totalBySubject: _castToIntMap(json['totalBySubject'] as Map?),
      scoresBruts: _castToIntMap(json['scoresBruts'] as Map?),
      scoresPonderes: _castToIntMap(json['scoresPonderes'] as Map?),
      totalPondere: (json['totalPondere'] as num?)?.toInt() ?? 0,
      success: json['success'] as bool? ?? false,
      abandoned: (json['abandoned'] as bool?) ?? false,
    );
  }

  static List<Map<String, dynamic>> encodeList(List<ExamHistoryEntry> items) =>
      items.map((e) => e.toJson()).toList();

  static List<ExamHistoryEntry> decodeList(dynamic data) {
    if (data is String) {
      try {
        final list = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
        return list.map(ExamHistoryEntry.fromJson).toList();
      } catch (_) {
        return <ExamHistoryEntry>[];
      }
    }
    if (data is Iterable) {
      final List<ExamHistoryEntry> entries = [];
      for (final item in data) {
        if (item is Map) {
          try {
            entries.add(
              ExamHistoryEntry.fromJson(
                Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
              ),
            );
          } catch (_) {}
        }
      }
      return entries;
    }
    return <ExamHistoryEntry>[];
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) {
      final value = raw.toDate();
      return value.isUtc ? value.toLocal() : value;
    }
    if (raw is DateTime) {
      return raw.isUtc ? raw.toLocal() : raw;
    }
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    if (raw is num) {
      // Assume milliseconds since epoch in UTC.
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt(), isUtc: true)
          .toLocal();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static Map<String, int> _castToIntMap(Map? raw) {
    if (raw == null) return <String, int>{};
    return raw.map((key, value) =>
        MapEntry(key as String, (value as num?)?.toInt() ?? 0));
  }
}
