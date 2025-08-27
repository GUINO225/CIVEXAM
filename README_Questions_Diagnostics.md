
# Patch — Diagnostics Questions/Assets

Ce patch aide à comprendre pourquoi les anciennes questions persistent.

## Fichiers
- lib/services/question_loader.dart (trace console + fallback + dump manifest)
- lib/debug/asset_diagnostics.dart (écran pour visualiser manifest et tests PRIMARY/FALLBACK)

## Utilisation
1) Copiez ces fichiers dans votre projet.
2) Dans pubspec.yaml, assurez-vous d'avoir :
```
flutter:
  assets:
    - assets/questions/civexam_questions_ena_core.json
```
3) Dans main.dart, TEMPORAIREMENT :
```
import 'debug/asset_diagnostics.dart';
...
home: const AssetDiagnosticsScreen(),
```
4) Lancez :
```
flutter clean
flutter pub get
flutter run
```

Regardez la console et l'écran pour savoir quel fichier est vraiment packagé et lu.
