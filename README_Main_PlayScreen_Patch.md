# Patch — Démarrer sur PlayScreen (désactive Diagnostics)

Ce patch remplace `lib/main.dart` pour démarrer **directement** sur `PlayScreen` et éviter que
l'écran `AssetDiagnosticsScreen` s'affiche encore.

## Installation
1) Copiez `lib/main.dart` de ce patch dans votre projet (remplacez l'existant).
2) Ouvrez votre projet et **vérifiez** les points suivants :
   - Il ne doit **pas** rester ces imports dans `main.dart` :
     ```dart
     import 'debug/asset_diagnostics.dart';
     ```
   - Il ne doit **pas** y avoir de :
     ```dart
     initialRoute: '/diagnostics'
     ```
     ni de `routes: { '/diagnostics': (ctx) => const AssetDiagnosticsScreen(), }`
   - Aucun `home: const AssetDiagnosticsScreen()` ailleurs.
3) Faites un build propre :
   ```bash
   flutter clean
   flutter pub get
   # recommandation: désinstallez l'app pour vider le cache
   adb uninstall com.example.civexam_app   # sinon désinstallez manuellement
   flutter run
   ```

## Dépannage
- Si l'écran de diagnostics réapparaît encore, faites une recherche globale dans le projet :
  - `AssetDiagnosticsScreen`
  - `asset_diagnostics.dart`
  - `initialRoute`
  - `home:`
  et supprimez toute référence restante.
