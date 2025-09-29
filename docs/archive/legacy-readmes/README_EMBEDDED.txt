PATCH — Icônes SVG visibles à coup sûr (fallback embarqué)
- Remplace seulement: lib/screens/play_screen.dart
- Ajoute un fallback **embarqué** (SVG inline) pour chaque icône: play, cap, book, checklist, history, info, logo.
- Ordre de chargement: asset primaire -> asset fallback -> **embedded** -> icône Material.

Important:
- Garde `flutter_svg` dans pubspec.
- Si tu veux revenir à tes assets, copie-les dans assets/icons/... et vérifie `flutter: assets: - assets/icons/`

Commandes:
flutter clean && flutter pub get && flutter run
