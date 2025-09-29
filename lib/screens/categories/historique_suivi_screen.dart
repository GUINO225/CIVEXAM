import 'package:flutter/material.dart';

import '../exam_history_screen.dart';
import '../training_history_screen.dart';
import 'category_definitions.dart';
import 'widgets/category_menu_list.dart';

class HistoriqueSuiviScreen extends StatelessWidget {
  final CategoryDefinition definition;

  const HistoriqueSuiviScreen({
    super.key,
    required this.definition,
  });

  Future<void> _handleTap(BuildContext context, int itemIndex) async {
    switch (itemIndex) {
      case 2:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExamHistoryScreen()),
        );
        break;
      case 3:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onItemSelected: (index) => _handleTap(context, index),
            ),
          ),
        ],
      ),
    );
  }
}
