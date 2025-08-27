# Patch Étape 3 — Splash + Icône avec votre logo CivExam

Ce patch intègre **votre logo personnalisé** dans :
- Le **splash screen Android** (flutter_native_splash)
- L’**icône d’application Android** (flutter_launcher_icons)
- Les assets du projet

## Installation
1. Copiez/collez le contenu de ce patch dans votre projet Flutter (remplacez `pubspec.yaml`, ajoutez `assets/images/logo.png`).

2. Dans le terminal :
   ```bash
   flutter pub get
   dart run flutter_native_splash:create
   dart run flutter_launcher_icons
   flutter run
   ```

## Notes
- Le logo utilisé est celui que vous avez fourni.
- La couleur de fond est #37478F (modifiable dans `pubspec.yaml`).
- Pour changer le logo, remplacez `assets/images/logo.png` et relancez les commandes ci-dessus.
