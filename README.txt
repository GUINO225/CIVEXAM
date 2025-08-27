CivExam — All Icons Contrast Pack (1756195836)

But: Corriger les icônes dont les parties blanches n'étaient pas visibles.
Comment:
- Tous les SVG 'mono' utilisent maintenant fill="currentColor" pour la base
  ET un double tracé (halo noir léger + blanc) pour chaque détail.
- Résistant même si votre code applique un ColorFilter ou SvgTheme.

Contenu:
- assets/icons/mono/*.svg           (play, cap, book, checklist, history, info, subject, exam, train)
- assets/icons/sets/<couleur>/*.svg (amber, teal, cyan, grape, lime, royal)
- assets/icons/logo_civexam.svg

Intégration:
1) Copiez ces dossiers dans votre projet.
2) Ajoutez dans pubspec.yaml :
   dependencies:
     flutter:
       sdk: flutter
     flutter_svg: ^2.0.9

   flutter:
     uses-material-design: true
     assets:
       - assets/icons/logo_civexam.svg
       - assets/icons/mono/
       - assets/icons/sets/amber/
       - assets/icons/sets/teal/
       - assets/icons/sets/cyan/
       - assets/icons/sets/grape/
       - assets/icons/sets/lime/
       - assets/icons/sets/royal/

3) Nettoyez et relancez :
   flutter clean && flutter pub get && flutter run

Remarque:
- Si vous restez en mode 'monochrome', les zones blanches sont préservées
  grâce au halo noir + tracé blanc.
- Si vous utilisez des 'sets' colorés, les détails restent en blanc.
