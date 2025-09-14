# Banque de questions CivExam — ENA

Ce fichier contient une banque de **150 QCM** (25 par matière) couvrant les 6 modules ENA :
- Culture Générale (Côte d’Ivoire)
- Droit Constitutionnel (Institutions & principes)
- Problèmes Économiques & Sociaux (Notions clés)
- Aptitude Numérique (Bases & proportionnalité)
- Aptitude Verbale (Vocabulaire & règles)
- Organisation & Logique (Classements & déductions)

## Emplacement
Copiez `assets/questions/civexam_questions_ena_core.json` dans votre projet.

Vérifiez que `pubspec.yaml` contient bien :

```yaml
flutter:
  assets:
    - assets/questions/civexam_questions_ena_core.json
```

## Utilisation
L’application charge ce fichier automatiquement via `QuestionLoader.loadENA()`.
