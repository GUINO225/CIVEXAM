// lib/models/leaderboard_entry.dart
class LeaderboardEntry {
  final String name, mode, subject, chapter, dateIso;
  final int total, correct, wrong, blank, durationSec;
  final double percent;
  const LeaderboardEntry({
    required this.name, required this.mode, required this.subject, required this.chapter,
    required this.total, required this.correct, required this.wrong, required this.blank,
    required this.durationSec, required this.percent, required this.dateIso,
  });
  Map<String, dynamic> toJson() => {
    'name': name,'mode': mode,'subject': subject,'chapter': chapter,'total': total,
    'correct': correct,'wrong': wrong,'blank': blank,'durationSec': durationSec,
    'percent': percent,'dateIso': dateIso,
  };
  factory LeaderboardEntry.fromJson(Map<String, dynamic> m) => LeaderboardEntry(
    name: (m['name'] ?? '') as String,
    mode: (m['mode'] ?? 'training') as String,
    subject: (m['subject'] ?? '') as String,
    chapter: (m['chapter'] ?? '') as String,
    total: (m['total'] ?? 0) as int,
    correct: (m['correct'] ?? 0) as int,
    wrong: (m['wrong'] ?? 0) as int,
    blank: (m['blank'] ?? 0) as int,
    durationSec: (m['durationSec'] ?? 0) as int,
    percent: ((m['percent'] ?? 0.0) as num).toDouble(),
    dateIso: (m['dateIso'] ?? '') as String,
  );
}
