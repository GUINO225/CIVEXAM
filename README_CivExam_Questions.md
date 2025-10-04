# Banque de questions CivExam — ENA

La banque principale `assets/questions/civexam_questions_ena_core.json` regroupe désormais **2 001 QCM** couvrant l’ensemble des modules ENA.

## Répartition par matière et chapitre

- **Culture Générale** — 999 questions
  - Côte d’Ivoire : 41
  - Afrique : 944
  - Union africaine : 14
- **Droit Constitutionnel** — 200 questions
  - Institutions & principes : 50
  - Organisation des pouvoirs : 50
  - Droits & libertés : 50
  - Justice constitutionnelle : 50
- **Problèmes Économiques & Sociaux** — 200 questions
  - Macroéconomie : 50
  - Microéconomie : 50
  - Politiques publiques : 50
  - Développement & société : 50
- **Aptitude Numérique** — 200 questions
  - Calcul mental : 50
  - Pourcentages & ratios : 50
  - Suites & séries : 50
  - Problèmes pratiques : 50
- **Aptitude Verbale** — 202 questions
  - Synonymes & antonymes : 52
  - Compréhension de texte : 50
  - Orthographe & grammaire : 50
  - Expression écrite : 50
- **Organisation & Logique** — 200 questions
  - Classements & déductions : 200

## Génération des fichiers

- Les lots de culture générale Afrique – Côte d’Ivoire – Union africaine proviennent du script `tool/generate_culture_general_africa.py`.
- Les modules manquants (Droit constitutionnel, Problèmes économiques & sociaux, Aptitude numérique, Aptitude verbale, Organisation & logique) sont générés par `tool/generate_additional_ena_questions.py` qui fusionne les questions existantes puis réécrit `assets/questions/civexam_questions_ena_core.json` au format JSON propre (`ensure_ascii=False`, `indent=2`).

## Emplacement

Copiez `assets/questions/civexam_questions_ena_core.json` dans votre projet et vérifiez que `pubspec.yaml` référence bien le fichier :

```yaml
flutter:
  assets:
    - assets/questions/civexam_questions_ena_core.json
```

## Utilisation

L’application charge ce fichier automatiquement via `QuestionLoader.loadENA()`.
