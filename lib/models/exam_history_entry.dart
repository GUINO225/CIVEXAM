import 'dart:convert';

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
        'date': date.toIso8601String(),
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
      date: DateTime.parse(json['date'] as String),
      correctBySubject: Map<String, int>.from(json['correctBySubject'] as Map),
      totalBySubject: Map<String, int>.from(json['totalBySubject'] as Map),
      scoresBruts: Map<String, int>.from(json['scoresBruts'] as Map),
      scoresPonderes: Map<String, int>.from(json['scoresPonderes'] as Map),
      totalPondere: json['totalPondere'] as int,
      success: json['success'] as bool,
      abandoned: (json['abandoned'] as bool?) ?? false,
    );
  }

  static String encodeList(List<ExamHistoryEntry> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<ExamHistoryEntry> decodeList(String s) {
    final list = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
    return list.map(ExamHistoryEntry.fromJson).toList();
  }
}
