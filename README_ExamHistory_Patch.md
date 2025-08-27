# Patch — Historique des examens (CivExam)

## Fichiers ajoutés
- `lib/models/exam_history_entry.dart`
- `lib/services/history_store.dart`
- `lib/screens/exam_history_screen.dart`

## Fichiers modifiés
- `lib/screens/multi_exam_flow.dart` : enregistre automatiquement le résultat d’un parcours.
- `lib/screens/play_screen.dart` : ajoute le bouton "Historique des examens".

### Dépendances
- `shared_preferences` (déjà présent dans ton `pubspec.yaml`). Aucune autre dépendance.

## Installation
1) Copie ces fichiers dans ton projet (remplace `multi_exam_flow.dart` et `play_screen.dart`).
2) Build :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
