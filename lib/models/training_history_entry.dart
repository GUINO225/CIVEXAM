class TrainingHistoryEntry {
  final DateTime date;
  final String subject;
  final String chapter;
  final int durationMinutes;
  final int correct;
  final int total;
  final int rawScore;
  final int weightedScore;
  final bool success;   // NEW
  final bool abandoned; // NEW

  const TrainingHistoryEntry({
    required this.date,
    required this.subject,
    required this.chapter,
    required this.durationMinutes,
    required this.correct,
    required this.total,
    required this.rawScore,
    required this.weightedScore,
    this.success = false,
    this.abandoned = false,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'subject': subject,
    'chapter': chapter,
    'durationMinutes': durationMinutes,
    'correct': correct,
    'total': total,
    'rawScore': rawScore,
    'weightedScore': weightedScore,
    'success': success,
    'abandoned': abandoned,
  };

  factory TrainingHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TrainingHistoryEntry(
      date: DateTime.parse(json['date'] as String),
      subject: (json['subject'] as String?) ?? 'Entraînement',
      chapter: (json['chapter'] as String?) ?? '',
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      correct: (json['correct'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      rawScore: (json['rawScore'] as num).toInt(),
      weightedScore: (json['weightedScore'] as num).toInt(),
      success: (json['success'] as bool?) ?? false,
      abandoned: (json['abandoned'] as bool?) ?? false,
    );
  }
}
