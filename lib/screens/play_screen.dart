// lib/screens/play_screen.dart — Live design via DesignBus + centrage tuiles + taille icône
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';

import 'training_quick_start.dart';
import 'multi_exam_flow.dart';
import 'subject_list_screen.dart';
import 'training_history_screen.dart';
import 'exam_history_screen.dart';
import 'leaderboard_screen.dart';
import 'design_settings_screen.dart';
import 'competition_screen.dart';
import 'login_screen.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final user = FirebaseAuth.instance.currentUser;
        final name = user?.displayName ?? user?.email;
        final welcomeText = name != null && name.isNotEmpty
            ? 'Bienvenue $name 👋  •  Choisis un mode'
            : 'Bienvenue 👋  •  Choisis un mode';
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
            title: const Text('CivExam'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Déconnexion',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.emoji_events_outlined),
                tooltip: 'Classement',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Choisir un thème',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DesignSettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      _GlassCard(
                        blur: cfg.glassBlur,
                        backgroundOpacity: cfg.glassBgOpacity,
                        borderOpacity: cfg.glassBorderOpacity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              _IconBadge(
                                icon: Icons.grid_view_rounded,
                                size: cfg.tileIconSize,
                                useMono: cfg.useMono,
                                monoColor: cfg.monoColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  welcomeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return _GlassTile(
                          title: item.title,
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
                          onTap: () => _navigate(context, i),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigate(BuildContext context, int index) async {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingQuickStartScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MultiExamFlowScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectListScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamHistoryScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()));
        break;
      case 5:
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Comment ça marche ?'),
            content: Text('• Entraînement : 5–10 s par question.\n• Concours ENA : difficulté = timing.\n• Par matière : révise par modules.\n• Historique : suis tes progrès.'),
          ),
        );
        break;
      case 6:
        final all = await QuestionLoader.loadENA();
        final selected = pickAndShuffle(all, 20);
        final indexMap = <String, int>{
          for (int i = 0; i < all.length; i++) all[i].id: i + 1
        };
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompetitionScreen(
              questions: selected,
              indexMap: indexMap,
              poolSize: all.length,
              drawCount: selected.length,
              timePerQuestion: 5,
              startTime: DateTime.now(),
            ),
          ),
        );
        break;
      case 7:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
        break;
      default:
        assert(false, 'Unexpected index: $index');
        break;
    }
  }
}

// ---- Widgets “glass” ----
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
            border: Border.all(color: Colors.white.withOpacity(borderOpacity), width: 1.2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    this.size = 52,
    required this.useMono,
    required this.monoColor,
  });
  final IconData icon;
  final double size;
  final bool useMono;
  final Color monoColor;
  @override
  Widget build(BuildContext context) {
    final gradientColors = useMono
        ? [monoColor.withOpacity(0.15), monoColor.withOpacity(0.35)]
        : const [Color(0xFFFFB25E), Color(0xFFFF7A00)];
    final iconColor = useMono ? monoColor : Colors.white;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Icon(icon, size: size * 0.58, color: iconColor),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  const _MenuItem(this.title, this.icon, this.gradientColors);
}

const _items = <_MenuItem>[
  _MenuItem("S'entraîner", Icons.play_circle_fill_rounded,
      [Color(0xFFFFB25E), Color(0xFFFF7A00)]),
  _MenuItem('Concours ENA', Icons.school_rounded,
      [Color(0xFF42A5F5), Color(0xFF1E88E5)]),
  _MenuItem('Par matière', Icons.menu_book_rounded,
      [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
  _MenuItem('Historique examens', Icons.fact_check_rounded,
      [Color(0xFFAB47BC), Color(0xFF8E24AA)]),
  _MenuItem("Historique entraînement", Icons.history_rounded,
      [Color(0xFFFF7043), Color(0xFFD84315)]),
  _MenuItem('Comment ça marche ?', Icons.info_rounded,
      [Color(0xFF26C6DA), Color(0xFF00ACC1)]),
  _MenuItem('Compétition', Icons.sports_kabaddi,
      [Color(0xFFFFEE58), Color(0xFFFDD835)]),
  _MenuItem('Classement', Icons.emoji_events_outlined,
      [Color(0xFFEC407A), Color(0xFFD81B60)]),
];
