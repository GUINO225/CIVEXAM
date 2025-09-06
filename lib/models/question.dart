class Question {
  final String id;
  final String concours;
  final String subject;
  final String chapter;
  final int difficulty;
  final String question;
  final List<String> choices;
  final int answerIndex;
  final String? explanation;

  const Question({
    required this.id,
    required this.concours,
    required this.subject,
    required this.chapter,
    required this.difficulty,
    required this.question,
    required this.choices,
    required this.answerIndex,
    this.explanation,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    final rawChoices = map['choices'];
    final choices = rawChoices is List
        ? rawChoices.map((e) => e.toString()).toList(growable: false)
        : const <String>[];
    return Question(
      id: map['id']?.toString() ?? '',
      concours: map['concours']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      chapter: map['chapter']?.toString() ?? '',
      difficulty: (map['difficulty'] as num?)?.toInt() ?? 1,
      question: map['question']?.toString() ?? '',
      choices: choices,
      answerIndex: (map['answerIndex'] as num?)?.toInt() ?? 0,
      explanation: map['explanation']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'concours': concours,
    'subject': subject,
    'chapter': chapter,
    'difficulty': difficulty,
    'question': question,
    'choices': choices,
    'answerIndex': answerIndex,
    'explanation': explanation,
  };
}
