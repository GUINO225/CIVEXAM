// lib/models/leaderboard_entry.dart
class LeaderboardEntry {
  final String userId, name, mode, subject, chapter, dateIso;
  final int total, correct, wrong, blank, durationSec;
  final double percent;
  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.mode,
    required this.subject,
    required this.chapter,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.durationSec,
    required this.percent,
    required this.dateIso,
  });
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'mode': mode,
    'subject': subject,
    'chapter': chapter,
    'total': total,
    'correct': correct,
    'wrong': wrong,
    'blank': blank,
    'durationSec': durationSec,
    'percent': percent,
    'dateIso': dateIso,
  };
  factory LeaderboardEntry.fromJson(Map<String, dynamic> m) => LeaderboardEntry(
    userId: (m['userId'] ?? '') as String,
    name: (m['name'] ?? '') as String,
    mode: (m['mode'] ?? 'training') as String,
    subject: (m['subject'] ?? '') as String,
    chapter: (m['chapter'] ?? '') as String,
    total: (m['total'] as num?)?.toInt() ?? 0,
    correct: (m['correct'] as num?)?.toInt() ?? 0,
    wrong: (m['wrong'] as num?)?.toInt() ?? 0,
    blank: (m['blank'] as num?)?.toInt() ?? 0,
    durationSec: (m['durationSec'] as num?)?.toInt() ?? 0,
    percent: (m['percent'] as num?)?.toDouble() ?? 0.0,
    dateIso: (m['dateIso'] ?? '') as String,
  );
}
