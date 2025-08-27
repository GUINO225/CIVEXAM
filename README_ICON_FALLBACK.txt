CivExam — Patch icônes (fallback intelligent) + assets minimaux

Ce patch corrige le problème d'icônes invisibles :
- PlayScreen charge les SVG avec un **fallback** automatique :
  1) chemin selon vos réglages (mono set OU set coloré)
  2) sinon, fallback inverse (amber ou mono)
  3) sinon, icône Material par défaut (pas de crash)
- Fournit des **assets minimaux** :
  - assets/icons/logo_civexam.svg
  - assets/icons/mono/*.svg  (recolorisables)
  - assets/icons/sets/amber/*.svg (set coloré)

Vérifiez votre pubspec.yaml :
dependencies:
  flutter_svg: ^2.0.10
flutter:
  uses-material-design: true
  assets:
    - assets/icons/

Ensuite : flutter clean && flutter pub get && flutter run
