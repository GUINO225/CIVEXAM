import 'dart:async';
import 'package:flutter/material.dart';

import '../leaderboard_screen.dart';
import 'category_definitions.dart';
import 'category_helpers.dart';
import 'widgets/category_menu_list.dart';
import '../../services/competition_quiz_launcher.dart';

/// Palette cohérente avec les autres écrans (violet + surface claire).
class _Brand {
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFF5B4DE1);
  static const secondary = Color(0xFF7F6AF8);
  static const surface = Color(0xFFF7F5FF);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF1E1E28);
  static const textMuted = Color(0xFF6E6B7A);
  static const border = Color(0xFFE6E1F9);
  static const chipBg = Color(0xFFEFEAFF);
}

class DefisClassementScreen extends StatefulWidget {
  final CategoryDefinition definition;

  const DefisClassementScreen({
    super.key,
    required this.definition,
  });

  @override
  State<DefisClassementScreen> createState() => _DefisClassementScreenState();
}

class _DefisClassementScreenState extends State<DefisClassementScreen> {
  Future<void> _handleTap(int itemIndex) async {
    switch (itemIndex) {
      case 5:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
        );
        break;
      case 6:
        await CompetitionQuizLauncher.launch(context);
        break;
      default:
        await showComingSoonDialog(context, 'Défi à venir');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final themed = base.copyWith(
      scaffoldBackgroundColor: _Brand.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _Brand.primary,
        brightness: base.brightness,
      ).copyWith(
        primary: _Brand.primary,
        surface: _Brand.surface,
        background: _Brand.surface,
        onSurface: _Brand.text,
        onPrimary: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _Brand.text,
        displayColor: _Brand.text,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: _Brand.surface,
        foregroundColor: _Brand.text,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: _Brand.border,
      cardTheme: base.cardTheme.copyWith(
        color: _Brand.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _Brand.border),
        ),
        elevation: 0,
      ),
    );

    final definition = widget.definition;

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(title: Text(definition.title)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Petite carte description pour rester cohérent avec les autres écrans
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _Brand.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _Brand.border), // ✅ fix
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _Brand.chipBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: _Brand.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.definition.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: CategoryMenuList(
                definition: definition,
                onItemSelected: _handleTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
