import 'package:flutter/material.dart';

import '../../widgets/play_themed_scaffold.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_tiles_view.dart';

class RessourcesOfficiellesScreen extends StatelessWidget {
  final CategoryDefinition definition;

  const RessourcesOfficiellesScreen({
    super.key,
    required this.definition,
  });

  Future<void> _handleTap(BuildContext context, int itemIndex) {
    switch (itemIndex) {
      case 23:
        return showComingSoonDialog(context, 'Constitution & textes clés');
      case 24:
        return showComingSoonDialog(context, 'Programme officiel (PDF)');
      case 25:
        return showComingSoonDialog(context, 'Calendrier des concours');
      case 26:
        return showComingSoonDialog(context, 'Textes ENA / Arrêtés / Guides');
      default:
        return showComingSoonDialog(context, 'Ressource en préparation');
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
