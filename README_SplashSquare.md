# Patch — Splash carré (logo non rogné)

Ce patch force l'affichage **carré** de votre logo sur le splash, sans recadrage circulaire Android 12+.

## Fichiers
- `assets/images/logo_splash_square.png` : logo paddé carré pour le splash
- `pubspec_splash_square.yaml` : config `flutter_native_splash` **sans** bloc `android_12` (recommandé)
- `pubspec_splash_square_alt.yaml` : config alternative **avec** bloc `android_12` mais sans masque circulaire
- `assets/images/logo_original.png` : votre logo d'origine (référence)

## Installation (recommandé)
1. Copiez `assets/images/logo_splash_square.png` dans votre projet.
2. Dans `pubspec.yaml`, remplacez la section `flutter_native_splash` par **`pubspec_splash_square.yaml`**.
3. Vérifiez que l'asset est déclaré :
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/images/logo_splash_square.png
   ```
4. Nettoyez et regénérez :
   ```bash
   flutter clean
   flutter pub get
   dart run flutter_native_splash:create
   flutter run
   ```

## Si vous préférez garder le bloc Android 12
- Utilisez `pubspec_splash_square_alt.yaml` (garde l'implémentation Android 12, mais **désactive le cercle**).

## Astuces
- Si l’icône **launcher** est aussi rognée, créez une version paddée dédiée (ex: `logo_icon_square.png`) et regénérez via `flutter_launcher_icons`.
- Après chaque modification du logo/couleur de fond, relancez `dart run flutter_native_splash:create`.
