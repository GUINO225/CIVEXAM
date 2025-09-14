/// Exam blueprint for ENA-like preselection
/// Frequently observed public info indicates 4 QCM tests, 60 minutes each
/// (Culture Générale, Aptitude Verbale, Organisation & Logique, Aptitude Numérique).
/// Nombre de questions : certains formats mentionnent **60 questions au total**.
/// On répartit par défaut 15 questions *par épreuve* (4 x 15 = 60).
/// Ajuste facilement ci-dessous si besoin.
class ExamBlueprint {
  // 15 questions par épreuve (4 épreuves)
  static const int perSection = 15;

  // total visé (4 x 15 = 60)
  static const int totalTarget = perSection * 4;

  // Si tu veux un autre format (ex: 20 par section => 80 total), modifie ici.
  static const int cultureGenerale = perSection;
  static const int aptitudeVerbale = perSection;
  static const int organisationLogique = perSection;
  static const int aptitudeNumerique = perSection;
}
