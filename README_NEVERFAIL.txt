CivExam — Icon Sets NEVER-FAIL Patch
Contenu:
- Tous les sets colorés: amber, teal, cyan, grape, lime, white
- Set mono (recolorable)
- logo_civexam.svg
- lib/screens/play_screen.dart avec chargeur SVG 'never-fail' :
  primary (set choisi) -> fallback (mono teinté) -> embedded (teinté)

À vérifier dans pubspec.yaml :
dependencies:
  flutter_svg: ^2.0.10
flutter:
  uses-material-design: true
  assets:
    - assets/icons/

Commandes:
flutter clean && flutter pub get && flutter run
