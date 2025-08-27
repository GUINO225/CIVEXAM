# Patch — Fix chrono entraînement (applique la durée choisie partout)

## Ce que fait ce patch
- Sauvegarde la durée choisie (`TrainingPrefs.saveDurationMinutes`) et
- `ExamFullScreen` peut **préférer** cette durée en mode entraînement (`preferSavedTrainingDuration: true`),
  même si un ancien écran passait encore `Duration(minutes: 30)`.

## Fichiers
- `lib/services/training_prefs.dart`
- `lib/screens/exam_full_screen.dart` (mis à jour)
- `lib/screens/training_quick_start.dart` (sauvegarde la durée + passe `preferSavedTrainingDuration: true`)

## Intégration
1) Remplace/ajoute ces fichiers.
2) Lance l’entraînement via `TrainingQuickStartScreen` (ou, si tu as d’autres écrans d’entraînement,
   passe `preferSavedTrainingDuration: true` lors de l’appel à `ExamFullScreen`).

## Build
```
flutter clean
flutter pub get
flutter run
```
