import 'package:flutter/material.dart';

import '../../widgets/play_themed_scaffold.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_tiles_view.dart';

class AideThemesScreen extends StatelessWidget {
  final CategoryDefinition definition;

  const AideThemesScreen({
    super.key,
    required this.definition,
  });

  Future<void> _handleTap(BuildContext context, int itemIndex) {
    switch (itemIndex) {
      case 4:
        return showComingSoonDialog(
          context,
          'Comment ça marche ?',
          message: 'Fiches d’utilisation et tutoriels arrivent.',
        );
      default:
        return showComingSoonDialog(context, 'Bientôt disponible');
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
        onItemSelected: (index) => _handleTap(context, index),
      ),
    );
  }
}
