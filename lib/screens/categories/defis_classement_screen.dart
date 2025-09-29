import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/competition_quiz_launcher.dart';
import '../../widgets/play_themed_scaffold.dart';
import '../leaderboard_screen.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_tiles_view.dart';

class DefisClassementScreen extends StatefulWidget {
  final CategoryDefinition definition;

  const DefisClassementScreen({
    super.key,
    required this.definition,
  });

  @override
  State<DefisClassementScreen> createState() => _DefisClassementScreenState();
}

class _DefisClassementScreenState extends State<DefisClassementScreen> {
  Future<void> _handleTap(int itemIndex) async {
    switch (itemIndex) {
      case 5:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
        );
        break;
      case 6:
        await CompetitionQuizLauncher.launch(context);
        break;
      default:
        await showComingSoonDialog(context, 'Défi à venir');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final definition = widget.definition;
    return PlayThemedScaffold(
      appBar: AppBar(title: Text(definition.title)),
      bodyMode: PlayThemedScaffoldBodyMode.panel,
      safeAreaTop: true,
      bodyPadding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 24),
      body: CategoryTilesView(
        definition: definition,
        availableItemIndexes: const {5, 6},
        onItemSelected: _handleTap,
      ),
    );
  }
}
