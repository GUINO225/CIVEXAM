import 'package:flutter/material.dart';

import '../../widgets/play_themed_scaffold.dart';
import '../courses/communication_administrative_screen.dart';
import '../courses/culture_generale_screen.dart';
import '../courses/droit_public_screen.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_tiles_view.dart';

class CoursEnaScreen extends StatelessWidget {
  final CategoryDefinition definition;

  const CoursEnaScreen({
    super.key,
    required this.definition,
  });

  Future<void> _handleTap(BuildContext context, int itemIndex) async {
    switch (itemIndex) {
      case 7:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CultureGeneraleScreen()),
        );
        break;
      case 16:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CommunicationAdministrativeScreen(),
          ),
        );
        break;
      case 8:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DroitPublicScreen()),
        );
        break;
      case 17:
        await showComingSoonDialog(context, 'TIC & Bureautique');
        break;
      case 9:
        await showComingSoonDialog(context, 'Finances publiques (CI)');
        break;
      case 10:
        await showComingSoonDialog(context, 'Économie & gestion');
        break;
      case 18:
        await showComingSoonDialog(context, 'Comptabilité publique');
        break;
      case 11:
        await showComingSoonDialog(context, 'Relations internationales & UE');
        break;
      case 12:
        await showComingSoonDialog(context, 'Institutions de la Côte d’Ivoire');
        break;
      case 13:
        await showComingSoonDialog(context, 'Note de synthèse');
        break;
      case 14:
        await showComingSoonDialog(context, 'Méthodologie QRC / QCM');
        break;
      case 19:
        await showComingSoonDialog(context, 'Anglais (option)');
        break;
      default:
        await showComingSoonDialog(context, 'Module en préparation');
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
        availableItemIndexes: const {7, 16, 8},
        onItemSelected: (index) => _handleTap(context, index),
      ),
    );
  }
}
