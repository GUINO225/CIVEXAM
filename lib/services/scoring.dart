class ExamScoring {
  final int correct;
  final int wrong;
  final int blank;
  final int coefficient;

  const ExamScoring({
    required this.correct,
    required this.wrong,
    required this.blank,
    this.coefficient = 1,
  });

  int rawScore({required int correctCount, required int wrongCount, required int blankCount}) {
    return (correct * correctCount) + (wrong * wrongCount) + (blank * blankCount);
  }

  int weighted(int raw) => raw * coefficient;

  @override
  String toString() => '+$correct / $blank / $wrong  (coef $coefficient)';
}
