import 'package:flutter/material.dart';
import '../data/ena_taxonomy.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import '../widgets/glass_tile.dart';
import 'chapter_list_screen.dart';

/// Liste des matières ENA
class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final textColor =
            textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: textColor,
            title: const Text('Modules ENA'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                itemCount: subjectsENA.length,
                itemBuilder: (context, index) {
                  final subject = subjectsENA[index];
                  final item = _subjectItems[index];
                  return GlassTile(
                    title: subject.name,
                    icon: item.icon,
                    gradientColors: item.gradientColors,
                    blur: cfg.glassBlur,
                    bgOpacity: cfg.glassBgOpacity,
                    borderOpacity: cfg.glassBorderOpacity,
                    iconSize: cfg.tileIconSize,
                    centerContent: cfg.tileCenter,
                    useMono: cfg.useMono,
                    monoColor: cfg.monoColor,
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterListScreen(
                            subjectName: subject.name,
                            chapterName: subject.chapters.isNotEmpty
                                ? subject.chapters.first.name
                                : '',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubjectItem {
  final IconData icon;
  final List<Color> gradientColors;
  const _SubjectItem(this.icon, this.gradientColors);
}

const _subjectItems = <_SubjectItem>[
  _SubjectItem(Icons.public, [Color(0xFFFFB25E), Color(0xFFFF7A00)]),
  _SubjectItem(Icons.gavel, [Color(0xFF42A5F5), Color(0xFF1E88E5)]),
  _SubjectItem(Icons.bar_chart, [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
  _SubjectItem(Icons.functions, [Color(0xFFAB47BC), Color(0xFF8E24AA)]),
  _SubjectItem(Icons.menu_book, [Color(0xFFFF7043), Color(0xFFD84315)]),
  _SubjectItem(Icons.extension, [Color(0xFF26C6DA), Color(0xFF00ACC1)]),
];
