# Étape 3 — Thème complet + Splash natif + Logo

Ce patch ajoute :
- ✅ Splash screen natif (flutter_native_splash)
- ✅ Logo effet glassmorphism
- ✅ Thème complet (textes, boutons, inputs, cartes)
- (Optionnel) Icône d’app (flutter_launcher_icons)

## Installation
1. Copiez le contenu de ce patch dans votre projet (remplacez `pubspec.yaml`, `lib/app/theme.dart`, et ajoutez `assets/images/logo.png`).
2. Commandes :
   ```bash
   flutter pub get
   dart run flutter_native_splash:create
   # Optionnel pour l’icône d’app
   dart run flutter_launcher_icons
   flutter run
   ```

## Dépannage
- Si Android NDK est demandé : gardez `ndkVersion = "27.0.12077973"` dans `android/app/build.gradle.kts`.
- Pour changer l’image/couleur du splash : modifiez la section `flutter_native_splash` puis relancez la commande de génération.
