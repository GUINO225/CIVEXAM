import 'package:flutter/material.dart';

import '../../widgets/play_themed_scaffold.dart';
import '../official_intro_screen.dart';
import '../subject_list_screen.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_tiles_view.dart';

class PrepaEnaScreen extends StatelessWidget {
  final CategoryDefinition definition;

  const PrepaEnaScreen({
    super.key,
    required this.definition,
  });

  Future<void> _handleTap(BuildContext context, int itemIndex) async {
    switch (itemIndex) {
      case 0:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OfficialIntroScreen()),
        );
        break;
      case 1:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubjectListScreen()),
        );
        break;
      case 15:
        await showComingSoonDialog(
          context,
          'Examens blancs ENA',
          message:
              'Programmez des sessions complètes (durées, barèmes, corrigés).',
        );
        break;
      default:
        await showComingSoonDialog(context, 'Fonctionnalité à venir');
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
        availableItemIndexes: const {0, 1},
        onItemSelected: (index) => _handleTap(context, index),
      ),
    );
  }
}
