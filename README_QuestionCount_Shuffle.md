# Patch — Nombre de questions ENA + Mélange des réponses

## Ce que fait ce patch
- **Fix "bonnes réponses toujours en 1ère position"** : chaque question mélange ses **choix** et met à jour `answerIndex`.
- **Nombre de questions identique au format ENA (60 total)** : configuration centrale (`ExamBlueprint`) avec **15 par épreuve** (4 épreuves = 60).
  - Ajustable facilement (ex. 20 par épreuve => 80 total).
- Mélange **aléatoire** de l'ordre des questions **et** des choix à chaque session.

## Fichiers
- `lib/services/exam_blueprint.dart` — paramètres du nombre de questions.
- `lib/services/question_randomizer.dart` — mélange des choix + sélection aléatoire.
- `lib/screens/multi_exam_flow.dart` — utilise le blueprint et le randomizer.

## Installation
1) Copie ces fichiers dans ton projet (remplace `multi_exam_flow.dart` par celui du patch).
2) Build :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Notes
- Si la banque ne contient pas assez de questions pour une matière, l’épreuve prendra **autant que possible** (sans planter).
- Tu peux régler le seuil de réussite dans `MultiExamFlowScreen` via `PASS_MIN_WEIGHTED`.
