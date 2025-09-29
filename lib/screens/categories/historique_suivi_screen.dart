import 'package:flutter/material.dart';

import '../../widgets/play_themed_scaffold.dart';
import '../exam_history_screen.dart';
import '../training_history_screen.dart';
import 'category_definitions.dart';
import 'widgets/category_tiles_view.dart';

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
    return PlayThemedScaffold(
      appBar: AppBar(title: Text(definition.title)),
      bodyMode: PlayThemedScaffoldBodyMode.panel,
      safeAreaTop: true,
      bodyPadding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 24),
      body: CategoryTilesView(
        definition: definition,
        availableItemIndexes: const {2, 3},
        onItemSelected: (index) => _handleTap(context, index),
      ),
    );
  }
}
