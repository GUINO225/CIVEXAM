CivExam — Color set fix
- Teinte automatiquement le fallback MONO quand tu utilises un set coloré (si l'asset coloré manque).
- Ajoute des logs console pour savoir quel chemin a été chargé: primary ou fallback.
Fichier à remplacer: lib/screens/play_screen.dart

Après patch:
flutter clean && flutter pub get && flutter run

Dans la console, vérifie:
[SVG] primary OK: assets/icons/sets/teal/play.svg
ou
[SVG] using FALLBACK: assets/icons/mono/play.svg
