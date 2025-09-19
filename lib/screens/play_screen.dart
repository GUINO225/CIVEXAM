// lib/screens/play_screen.dart — Live design via DesignBus + centrage tuiles + taille icône
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/auth_service.dart';
import '../utils/palette_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_tile.dart';
import '../widgets/adaptive_text.dart';
import '../utils/responsive_utils.dart';

import 'official_intro_screen.dart';
import 'subject_list_screen.dart';
import 'training_history_screen.dart';
import 'exam_history_screen.dart';
import 'leaderboard_screen.dart';
import 'dashboard_screen.dart';
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
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final user = FirebaseAuth.instance.currentUser;
        final name = user?.displayName ?? user?.email;
        final welcomeText = name != null && name.isNotEmpty
            ? 'Bienvenue $name 👋'
            : 'Bienvenue 👋';
        final textColor =
            textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
        final badgeColors = playIconColors(cfg.bgPaletteName);
        final bgColor =
            pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode).first;

        final mediaQuery = MediaQuery.of(context);
        final scale = computeScaleFactor(mediaQuery);
        final textScaler = MediaQuery.textScalerOf(context);
        final welcomeFontSize = scaledFontSize(
          base: 22,
          scale: scale,
          textScaler: textScaler,
          min: 18,
          max: 28,
        );
        final logoHeight = scaledDimension(
          base: 100,
          scale: scale,
          min: 100,
          max: 100,
        );

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: textColor,
            toolbarHeight: 0,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, -2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFF0D47A1)),
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
                                final message = e is AuthException
                                    ? e.message
                                    : 'Déconnexion échouée';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              } finally {
                                if (mounted) setState(() => _signingOut = false);
                              }
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline, color: Color(0xFF0D47A1)),
                      tooltip: 'Tableau de bord',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DashboardScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_events_outlined, color: Color(0xFF0D47A1)),
                      tooltip: 'Classement',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LeaderboardScreen()));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.palette_outlined, color: Color(0xFF0D47A1)),
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
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            minimum: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo_splash.png',
                        height: logoHeight,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        welcomeText,
                        style: TextStyle(
                          color: textColor,
                          fontSize: welcomeFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.75,
                      widthFactor: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
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
                              scaleFactor: scale,
                              centerContent: cfg.tileCenter,
                              useMono: cfg.useMono,
                              monoColor: cfg.monoColor,
                              textColor: textColor,
                              onTap: () => _navigate(context, i),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigate(BuildContext context, int index) async {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OfficialIntroScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectListScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamHistoryScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()));
        break;
      case 4:
        await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Comment ça marche ?'),
            content: Text('• Entraînement : 5–10 s par question.\n• Concours ENA : difficulté = timing.\n• Entraînement par matière : révise par modules.\n• Historique : suis tes progrès.'),
          ),
        );
        break;
      case 5:
        bool progressShown = false;
        try {
          const int desiredCount = 60;
          final all = await QuestionLoader.loadENA();
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          progressShown = true;
          final selected = await pickAndShuffle(
            all,
            desiredCount,
            dedupeByQuestion: true,
          );
          if (progressShown && mounted) Navigator.pop(context);

          final proceed = await _handleShortDraw(selected, desiredCount);
          if (!proceed) {
            return;
          }

          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          unawaited(
            QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError(
              (Object error, _) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Échec de l’enregistrement de l’historique des questions.'),
                  ),
                );
              },
            ),
          );
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
          if (progressShown && mounted) Navigator.pop(context);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to load question bank: $e'),
            ),
          );
        }
        break;
      case 6:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
        break;
      default:
        assert(false, 'Unexpected index: $index');
        break;
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
    final mediaQuery = MediaQuery.of(context);
    final scale = computeScaleFactor(mediaQuery);
    final badgeSize = scaledDimension(
      base: size,
      scale: scale,
      min: 40,
      max: 96,
    );
    final colors = useMono
        ? [monoColor.withOpacity(0.15), monoColor.withOpacity(0.35)]
        : gradientColors;
    final iconColor = useMono ? monoColor : Colors.white;
    return Container(
      height: badgeSize,
      width: badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Icon(icon, size: badgeSize * 0.58, color: iconColor),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String palette;
  const _MenuItem(this.title, this.icon, this.palette);
}

const _items = <_MenuItem>[
  _MenuItem('Simulation concours ENA', Icons.school_rounded, 'violetRose'),
  _MenuItem('Entraînement par matière', Icons.menu_book_rounded, 'sereneBlue'),
  _MenuItem('Historique examens', Icons.fact_check_rounded, 'lightGreen'),
  _MenuItem("Historique entraînement", Icons.history_rounded, 'softYellow'),
  _MenuItem('Comment ça marche ?', Icons.info_rounded, 'powderPink'),
  _MenuItem('Compétition', Icons.sports_kabaddi, 'forestGreen'),
  _MenuItem('Classement', Icons.emoji_events_outlined, 'royalViolet'),
];
