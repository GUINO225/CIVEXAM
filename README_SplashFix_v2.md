# Patch v2 — Splash Android 12 (logo non rogné, padding renforcé)

Ce patch fournit une version **très paddée** du logo (`logo_splash_padded.png`) pour éviter tout recadrage circulaire
sur Android 12+, et une config `pubspec` adaptée.

## Fichiers
- assets/images/logo_splash_padded.png
- pubspec_splash_patch_v2.yaml

## Étapes d'installation
1. Copiez `assets/images/logo_splash_padded.png` dans votre projet.
2. Dans `pubspec.yaml`, remplacez la section `flutter_native_splash` par le contenu de `pubspec_splash_patch_v2.yaml`.
3. Assurez-vous que les assets contiennent la ligne :
   ```yaml
   flutter:
     assets:
       - assets/images/logo_splash_padded.png
   ```
4. **Nettoyez et regénérez** (important pour invalider d’anciens drawables Android) :
   ```bash
   flutter clean
   # Supprimez si nécessaire les anciens fichiers générés par le splash (facultatif mais utile) :
   # rm -rf android/app/src/main/res/drawable* android/app/src/main/res/mipmap-anydpi-v26
   flutter pub get
   dart run flutter_native_splash:create
   flutter run
   ```

## Remarques
- Sur Android 12+, l’API système du splash applique des contraintes ; avec ce padding renforcé, le logo reste entièrement visible.
- Si vous voyez toujours une coupe, vérifiez que le splash a bien été **régénéré** et que vous n’avez pas de caches obsolètes.
