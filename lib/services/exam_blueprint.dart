/// Exam blueprint for ENA-like preselection
/// Frequently observed public info indicates 4 QCM tests, 60 minutes each
/// (Culture Générale, Aptitude Verbale, Organisation & Logique, Aptitude Numérique).
/// Nombre de questions : le concours officiel comporte **100 questions au total**.
/// On répartit donc 25 questions *par épreuve* (4 × 25 = 100).
/// Ajuste facilement ci-dessous si besoin.
class ExamBlueprint {
  // 25 questions par épreuve (4 épreuves)
  static const int perSection = 25;

  // total visé (4 x 25 = 100)
  static const int totalTarget = perSection * 4;

  // Si tu veux un autre format, modifie ici.
  static const int cultureGenerale = perSection;
  static const int aptitudeVerbale = perSection;
  static const int organisationLogique = perSection;
  static const int aptitudeNumerique = perSection;
}
