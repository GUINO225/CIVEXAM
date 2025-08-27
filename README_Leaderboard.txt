CivExam — Leaderboard FULL Patch

Fichiers à copier dans votre projet :
- lib/models/leaderboard_entry.dart
- lib/services/leaderboard_store.dart
- lib/widgets/leaderboard_save_dialog.dart
- lib/screens/leaderboard_screen.dart

Étapes :
1) pubspec.yaml -> vérifier 'shared_preferences' dans dependencies.
2) PlayScreen : ajouter le bouton 'Classement' dans l'AppBar :
   import 'package:civexam_app/screens/leaderboard_screen.dart';
   actions: [
     IconButton(
       icon: const Icon(Icons.emoji_events_outlined),
       tooltip: 'Classement',
       onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
     ),
   ]
3) À la fin d’un quiz : enregistrer le score
   import 'package:civexam_app/widgets/leaderboard_save_dialog.dart';
   await showSaveScoreDialog(context: context, mode: 'training', total: ..., correct: ..., wrong: ..., blank: ..., durationSec: ..., percent: ...);
