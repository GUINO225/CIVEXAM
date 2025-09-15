// lib/screens/play_screen.dart — Live design via DesignBus + centrage tuiles + taille icône
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/auth_service.dart';
import '../utils/palette_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_tile.dart';
import '../widgets/adaptive_text.dart';

import 'training_quick_start.dart';
import 'official_intro_screen.dart';
import 'subject_list_screen.dart';
import 'training_history_screen.dart';
import 'exam_history_screen.dart';
import 'leaderboard_screen.dart';
import 'design_settings_screen.dart';
import 'competition_screen.dart';
import 'login_screen.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/question_history_store.dart';
import '../models/question.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final _auth = AuthService();
  bool _signingOut = false;
  late final List<_MenuItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      _MenuItem("S'entraîner", Icons.play_circle_fill_rounded, 'mintTurquoise', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingQuickStartScreen()));
      }),
      _MenuItem('Concours ENA', Icons.school_rounded, 'violetRose', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OfficialIntroScreen()));
      }),
      _MenuItem('Par matière', Icons.menu_book_rounded, 'sereneBlue', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectListScreen()));
      }),
      _MenuItem('Historique examens', Icons.fact_check_rounded, 'lightGreen', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamHistoryScreen()));
      }),
      _MenuItem("Historique entraînement", Icons.history_rounded, 'softYellow', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()));
      }),
      _MenuItem('Comment ça marche ?', Icons.info_rounded, 'powderPink', () {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Comment ça marche ?'),
            content: Text('• Entraînement : 5–10 s par question.\n• Concours ENA : difficulté = timing.\n• Par matière : révise par modules.\n• Historique : suis tes progrès.'),
          ),
        );
      }),
      _MenuItem('Compétition', Icons.sports_kabaddi, 'forestGreen', () {
        _startCompetition();
      }),
      _MenuItem('Classement', Icons.emoji_events_outlined, 'royalViolet', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
      }),
    ];
  }

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
        final badgeColors = playIconColors(cfg.bgPaletteName);
        final bgColor =
            pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode).first;

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
                onPressed: _signingOut
                    ? null
                    : () async {
                        setState(() => _signingOut = true);
                        try {
                          await _auth.signOut();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          final message =
                              e is AuthException ? e.message : 'Déconnexion échouée';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        } finally {
                          if (mounted) setState(() => _signingOut = false);
                        }
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
                      GlassCard(
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
                                gradientColors: badgeColors,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AdaptiveText(
                                  welcomeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  backgroundColor: bgColor,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
                        final iconColors = playIconColors(item.palette);
                        return GlassTile(
                          title: item.title,
                          icon: item.icon,
                          gradientColors: iconColors,
                          blur: cfg.glassBlur,
                          bgOpacity: cfg.glassBgOpacity,
                          borderOpacity: cfg.glassBorderOpacity,
                          iconSize: cfg.tileIconSize,
                          centerContent: cfg.tileCenter,
                          useMono: cfg.useMono,
                          monoColor: cfg.monoColor,
                          textColor: textColor,
                          onTap: item.onTap,
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

  Future<void> _startCompetition() async {
    try {
      const int desiredCount = 60;
      final all = await QuestionLoader.loadENA();
      final selected = await pickAndShuffle(
        all,
        desiredCount,
        dedupeByQuestion: true,
      );

      final proceed = await _handleShortDraw(selected, desiredCount);
      if (!proceed) {
        return;
      }

      await QuestionHistoryStore.addAll(selected.map((q) => q.id));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionScreen(
            questions: selected,
            timePerQuestion: 5,
            startTime: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load question bank: $e'),
        ),
      );
    }
  }

  Future<bool> _handleShortDraw(List<Question> selected, int requested) async {
    if (selected.length >= requested) {
      return true;
    }
    if (!mounted) {
      return false;
    }
    if (selected.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Historique épuisé'),
          content: const Text(
              'Toutes les questions ont déjà été vues. Réinitialiser l\'historique pour recommencer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(_, null),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                QuestionHistoryStore.clear();
                Navigator.pop(_, null);
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        ),
      );
      return false;
    }
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Commencer ?'),
        content: Text('Vous avez déjà vu la plupart des questions — '
            '${selected.length}/$requested disponibles.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              QuestionHistoryStore.clear();
              Navigator.pop(_, false);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    return proceed == true;
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    this.size = 52,
    required this.useMono,
    required this.monoColor,
    required this.gradientColors,
  });
  final IconData icon;
  final double size;
  final bool useMono;
  final Color monoColor;
   final List<Color> gradientColors;
  @override
  Widget build(BuildContext context) {
    final colors = useMono
        ? [monoColor.withOpacity(0.15), monoColor.withOpacity(0.35)]
        : gradientColors;
    final iconColor = useMono ? monoColor : Colors.white;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Icon(icon, size: size * 0.58, color: iconColor),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String palette;
  final VoidCallback onTap;
  const _MenuItem(this.title, this.icon, this.palette, this.onTap);
}
