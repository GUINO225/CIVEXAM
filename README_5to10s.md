# Patch — Limite 5–10 secondes par question (concours + entraînement)

- `exam_full_screen.dart` : applique `overridePerQuestionSeconds` avec **clamp 5..10s**.
- `multi_exam_flow.dart` : concours ENA avec **10s/question** max.
- `training_quick_start.dart` : options 5,6,7,8,9,10 secondes par question.

Intégration :
1) Copiez ces 3 fichiers dans `lib/screens/`.
2) `flutter clean && flutter pub get && flutter run`.

Astuce : si vous souhaitez 5s/question en concours, mettez :
```dart
static const int PER_QUESTION_SECONDS_OVERRIDE = 5;
```
dans `MultiExamFlowScreen`.
