import 'package:flutter/material.dart';

import '../../widgets/play_themed_scaffold.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_tiles_view.dart';

class BanqueSujetsScreen extends StatelessWidget {
  final CategoryDefinition definition;

  const BanqueSujetsScreen({
    super.key,
    required this.definition,
  });

  Future<void> _handleTap(BuildContext context, int itemIndex) {
    switch (itemIndex) {
      case 20:
        return showComingSoonDialog(context, 'Banque de sujets ENA CI');
      case 21:
        return showComingSoonDialog(context, 'Corrigés détaillés');
      case 22:
        return showComingSoonDialog(context, 'Sujets par filière (A/B/C)');
      default:
        return showComingSoonDialog(context, 'Contenu à venir');
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
