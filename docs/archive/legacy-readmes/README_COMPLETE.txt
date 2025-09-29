CivExam — Icons Complete FixPack
• Fournit MONO (recolorable) + 6 sets colorés (amber/teal/cyan/grape/lime/white) avec couleurs codées en dur (pas de currentColor).
• Remplace lib/screens/play_screen.dart pour:
  - Ne JAMAIS teinter l'asset du set coloré (couleur native du SVG)
  - Teinter uniquement le fallback MONO si un set coloré est sélectionné mais manquant
  - Embedded minimal en dernier recours

À vérifier dans pubspec.yaml :
dependencies:
  flutter_svg: ^2.0.10
flutter:
  uses-material-design: true
  assets:
    - assets/icons/

Étapes :
1) Dézipper à la racine du projet (accepter l'écrasement de play_screen.dart)
2) flutter clean && flutter pub get && flutter run
3) Dans l'app: Réglages → Icônes
   - Pour MONO: Icônes monochromes = ON (couleur contrôlée par réglage)
   - Pour SET coloré: Icônes monochromes = OFF, Set = teal (ou autre)
