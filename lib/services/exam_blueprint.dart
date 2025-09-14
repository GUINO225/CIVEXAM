/// Exam blueprint for ENA-like preselection.
/// Observed formats indicate 6 QCM tests, 60 minutes each:
/// Culture Générale, Droit Constitutionnel, Problèmes Économiques & Sociaux,
/// Aptitude Numérique, Aptitude Verbale et Organisation & Logique.
/// Avec 25 questions par épreuve cela donne un total de 150 questions.
/// Ajuste facilement ci-dessous si besoin.
class ExamBlueprint {
  // 25 questions par épreuve (6 épreuves)
  static const int perSection = 25;

  // total visé (6 x 25 = 150)
  static const int totalTarget = perSection * 6;

  // Si tu veux un autre format, modifie ici.
  static const int cultureGenerale = perSection;
  static const int droitConstitutionnel = perSection;
  static const int problemesEconomiquesSociaux = perSection;
  static const int aptitudeNumerique = perSection;
  static const int aptitudeVerbale = perSection;
  static const int organisationLogique = perSection;
}
