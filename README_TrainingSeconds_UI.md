# Patch UI — Entraînement 5–10s

Ce patch remplace l’ancien écran d’entraînement “en minutes” par une version **5–10s/question**.

## Fichiers
- `lib/screens/training_quick_start.dart` — sélecteur 5..10 secondes par question
- `lib/screens/play_screen.dart` — bouton qui ouvre ce nouvel écran

## Intégration
1) Copiez ces 2 fichiers dans votre projet (remplacez votre `play_screen.dart` si vous voulez aller au plus simple).
2) Démarrez l’app : la page d’accueil propose **S’entraîner (5–10s/question)**.
3) Si vous préférez garder votre `play_screen.dart` existant, importez simplement le nouvel écran et ajoutez un bouton :
   ```dart
   import 'training_quick_start.dart';
   // ...
   Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingQuickStartScreen()));
   ```
