import 'package:flutter/material.dart';

import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_menu_list.dart';

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
