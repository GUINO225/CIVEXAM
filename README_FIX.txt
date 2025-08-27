Patch FIX (_SmartSvg → _SmartSvgTwoToneAware pour le logo)
- Remplace l'appel qui cassait la compilation.
- Compatible avec le patch TwoTone: le logo utilise aussi la logique two‑tone si le fichier logo est manquant.
Fichier à remplacer: lib/screens/play_screen.dart

Étapes:
1) Copie ce fichier dans lib/screens/play_screen.dart
2) flutter clean && flutter pub get && flutter run
