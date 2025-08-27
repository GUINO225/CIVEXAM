CivExam — Mono Tint Fix
Problème: en mode 'Icônes monochromes', les icônes restaient blanches → le PRIMARY mono n'était pas teinté.
Solution: on applique aussi un ColorFilter (BlendMode.srcIn) sur le PRIMARY quand useMono==true.

Fichier: lib/screens/play_screen.dart
Étapes:
1) Remplacer le fichier.
2) flutter clean && flutter pub get && flutter run
3) Dans l'app: activer 'Icônes monochromes' et choisir la couleur.
