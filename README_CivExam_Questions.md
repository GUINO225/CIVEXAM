# Banque de questions CivExam — ENA

Ce fichier contient une banque de **6 000 QCM** couvrant les modules ENA, dont :
- 1 182 questions de Culture Générale (Côte d’Ivoire, Afrique et Union africaine)
- 4 818 questions réparties sur les autres matières (Droit constitutionnel, Problèmes économiques & sociaux, Aptitudes numériq
ues et verbales, Organisation & logique)

Les 1 000 nouvelles questions de culture générale Afrique – Côte d’Ivoire – Union africaine ont été générées via `tool/generat
e_culture_general_africa.py` et ajoutées à `assets/questions/civexam_questions_ena_core.json`.

Répartition initiale (150 QCM d’entraînement historique) :
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
