CivExam — Diagnose Icon Source Patch
But: vérifier visuellement si chaque tuile charge l'icône du SET (chip 'SET'), du fallback MONO ('MONO') ou de l'embedded ('EMB').
- Fichier: lib/screens/play_screen.dart
- kShowIconSourceChip=true affiche un petit badge en bas à droite.

Si les deux modes (mono et set coloré) ont la même couleur, tu regardes les chips:
- 'SET' => c'est bien l'asset coloré (pas de teinte appliquée)
- 'MONO' => c'est un fallback mono teinté (la même couleur que le set)
  -> Vérifier que les SVG du set existent: assets/icons/sets/<set>/<icon>.svg
- 'EMB' => dernier recours

Après remplacement:
flutter clean && flutter pub get && flutter run
