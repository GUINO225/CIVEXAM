import 'package:flutter/material.dart';

import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_menu_list.dart';

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
