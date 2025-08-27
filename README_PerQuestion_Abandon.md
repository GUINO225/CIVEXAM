# Patch — Timer par question (5s à 60s) + statut "Abandonné"

## Nouveautés
- **Timer par question (5s–60s)** : temps total = (secondes/question) × (nombre de questions).
  - Entraînement : sélecteur secondes/question (5, 10, 15, 20, 30, 45, 60).
  - Simulation ENA : temps plafonné à **60s/question** par défaut (modifiable dans `PER_QUESTION_SECONDS_OVERRIDE`).
- **Abandon du concours** : si l’utilisateur quitte le parcours, l’état est **Abandonné** (et non "Réussi").
  - Sauvegardé dans l’historique, affiché avec un chip orange.

## Fichiers
- `lib/models/exam_history_entry.dart` (ajout de `abandoned` + rétrocompatibilité)
- `lib/screens/exam_history_screen.dart` (affiche Abandonné)
- `lib/screens/exam_full_screen.dart` (param `overridePerQuestionSeconds`)
- `lib/screens/multi_exam_flow.dart` (timer/question + marque l’abandon)
- `lib/screens/training_quick_start.dart` (UI secondes/question)

## Intégration
1) Remplace/Ajoute ces fichiers.
2) Build :
```
flutter clean
flutter pub get
flutter run
```
