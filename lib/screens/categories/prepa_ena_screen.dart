import 'package:flutter/material.dart';

import '../official_intro_screen.dart';
import '../subject_list_screen.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_menu_list.dart';

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
