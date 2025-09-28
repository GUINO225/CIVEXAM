import 'dart:async';

import 'package:flutter/material.dart';

import '../leaderboard_screen.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_menu_list.dart';
import '../../services/competition_quiz_launcher.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(definition.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              definition.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: CategoryMenuList(
              definition: definition,
              onItemSelected: _handleTap,
            ),
          ),
        ],
      ),
    );
  }
}
