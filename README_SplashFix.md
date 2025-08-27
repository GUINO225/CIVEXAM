# Patch — Splash logo non rogné (Android 12+)
Ce patch ajoute une version **paddée** de votre logo (`logo_splash.png`) pour éviter le recadrage circulaire sur Android 12+
et fournit un extrait `pubspec_splash_patch.yaml` pour configurer `flutter_native_splash`.

## Fichiers
- assets/images/logo_splash.png         (logo avec marges transparentes)
- assets/images/logo_original.png       (votre logo d'origine, pour référence)
- pubspec_splash_patch.yaml             (extrait de config à coller dans votre pubspec.yaml)

## Étapes d'installation
1. Copiez le dossier `assets/images/` dans votre projet (conservez également votre `assets/images/logo.png` si vous l'utilisez ailleurs).
2. Ouvrez votre `pubspec.yaml` et **remplacez** la section `flutter_native_splash` par le contenu de `pubspec_splash_patch.yaml` (ou fusionnez si nécessaire).
3. Assurez-vous que l'asset est déclaré (si vous ne l'avez pas déjà) :
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/questions/ena_sample.json
       - assets/images/logo.png
       - assets/images/logo_splash.png
   ```
4. Regénérez le splash natif :
   ```bash
   flutter pub get
   dart run flutter_native_splash:create
   flutter run
   ```

## Astuce
- Si l'icône d'app est aussi rognée, générez une version **icône** avec marges (ex: `logo_icon.png`) et utilisez-la avec `flutter_launcher_icons` :
  ```yaml
  flutter_icons:
    android: "launcher_icon"
    image_path: "assets/images/logo_icon.png"
    adaptive_icon_background: "#37478F"
    adaptive_icon_foreground: "assets/images/logo_icon.png"
  ```
  Puis :
  ```bash
  dart run flutter_launcher_icons
  ```
