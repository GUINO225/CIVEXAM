import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../data/ena_taxonomy.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import 'chapter_list_screen.dart';

/// Liste des matières ENA
/// Ajout : [subjectIndex] optionnel pour compatibilité avec les anciens appels
/// (ex: SubjectListScreen(subjectIndex: index)).
class SubjectListScreen extends StatelessWidget {
  final int? subjectIndex;
  const SubjectListScreen({super.key, this.subjectIndex});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final textColor = textColorForPalette(cfg.bgPaletteName);
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
                  return _GlassTile(
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
  _SubjectItem(Icons.public, [Color(0xFF5C6BB7), Color(0xFF6C7BD0)]),
  _SubjectItem(Icons.gavel, [Color(0xFF4A90E2), Color(0xFF5A9AE5)]),
  _SubjectItem(Icons.bar_chart, [Color(0xFF5FBF72), Color(0xFF66BB6A)]),
  _SubjectItem(Icons.functions, [Color(0xFF9D3FB2), Color(0xFFA84ABD)]),
  _SubjectItem(Icons.menu_book, [Color(0xFF5E8CD1), Color(0xFF6B99D5)]),
  _SubjectItem(Icons.extension, [Color(0xFF1FB5C6), Color(0xFF26C6DA)]),
];

class _GlassTile extends StatefulWidget {
  const _GlassTile({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    required this.blur,
    required this.bgOpacity,
    required this.borderOpacity,
    required this.iconSize,
    required this.centerContent,
    required this.useMono,
    required this.monoColor,
    required this.textColor,
  });
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final double blur;
  final double bgOpacity;
  final double borderOpacity;
  final double iconSize;
  final bool centerContent;
  final bool useMono;
  final Color monoColor;
  final Color textColor;

  @override
  State<_GlassTile> createState() => _GlassTileState();
}

class _GlassTileState extends State<_GlassTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.useMono
        ? [
            widget.monoColor.withOpacity(0.15),
            widget.monoColor.withOpacity(0.35)
          ]
        : widget.gradientColors;

    final iconColor = widget.useMono ? widget.monoColor : Colors.white;

    final iconBadge = Container(
      height: widget.iconSize,
      width: widget.iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(widget.icon, size: widget.iconSize * 0.58, color: iconColor),
    );

    final title = Text(
      widget.title,
      textAlign: widget.centerContent ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontSize: 20,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: widget.textColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        scale: _pressed ? 0.98 : 1.0,
        child: _GlassCard(
          blur: widget.blur,
          backgroundOpacity: widget.bgOpacity,
          borderOpacity: widget.borderOpacity,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: widget.centerContent
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      iconBadge,
                      const SizedBox(height: 12),
                      title,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(alignment: Alignment.topLeft, child: iconBadge),
                      const Spacer(),
                      title,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.blur = 16,
    this.backgroundOpacity = 0.16,
    this.borderOpacity = 0.22,
  });
  final Widget child;
  final double blur;
  final double backgroundOpacity;
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(backgroundOpacity + 0.05),
                Colors.white.withOpacity(backgroundOpacity),
              ],
            ),
            border: Border.all(
                color: Colors.white.withOpacity(borderOpacity), width: 1.2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: child,
        ),
      ),
    );
  }
}
