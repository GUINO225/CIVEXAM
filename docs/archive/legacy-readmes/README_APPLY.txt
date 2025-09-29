
Patch d'intégration automatique — Leaderboard
Fichiers à remplacer dans votre projet :
- lib/screens/training_quick_start.dart
- lib/screens/multi_exam_flow.dart
+ lib/services/leaderboard_hooks.dart (ajouté si absent)

Changements :
- Ajoute l'import des hooks
- Entraînement : enregistre le score (succès ET abandon) juste après l'historique
- Concours : enregistre le score global après l'historique

Après copie :
- Flutter clean (si besoin), puis hot restart.
