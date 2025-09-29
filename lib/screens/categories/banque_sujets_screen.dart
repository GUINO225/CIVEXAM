import 'package:flutter/material.dart';

import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_menu_list.dart';

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
