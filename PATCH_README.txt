PATCH — Écran Réglages design + PlayScreen dynamique
Fichiers:
- lib/models/design_config.dart
- lib/services/design_prefs.dart
- lib/screens/design_settings_screen.dart
- lib/screens/play_screen.dart

pubspec.yaml (extraits):
dependencies:
  shared_preferences: ^2.2.2
  flutter_svg: ^2.0.10
flutter:
  assets:
    - assets/icons/

Usage:
- AppBar (icône 'tune') -> Réglages design -> Enregistrer -> retour PlayScreen (rechargé).
