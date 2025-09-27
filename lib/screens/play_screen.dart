// lib/screens/play_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:characters/characters.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/ongoing_quiz_store.dart';
import '../services/question_loader.dart';
import '../services/scoring.dart';
import '../utils/palette_utils.dart';
import '../utils/responsive_utils.dart';

import '../models/question.dart';

import 'dashboard_screen.dart';
import 'design_settings_screen.dart';
import 'subject_list_screen.dart';
import 'exam_history_screen.dart';
import 'profile_edit_screen.dart';
import 'training_quick_start.dart';
import 'exam_full_screen.dart';

// --- Catégories refactorisées (ENA CI) ---
import 'categories/category_definitions.dart';
import 'categories/prepa_ena_screen.dart';
import 'categories/cours_ena_screen.dart';
import 'categories/banque_sujets_screen.dart';
import 'categories/ressources_officielles_screen.dart';
import 'categories/historique_suivi_screen.dart';
import 'categories/defis_classement_screen.dart';
import 'categories/aide_themes_screen.dart';

/// ============================================================================
/// === CONFIG UI (éditable facilement) ========================================
/// ============================================================================

class SectionStyle {
  final double? itemHeight;
  final TextStyle titleTextStyle;

  const SectionStyle({
    this.itemHeight,
    required this.titleTextStyle,
  });
}

class PlayUIConfig {
  final double panelHeightFactor;
  final Map<String, SectionStyle> sectionStyles;

  /// Espace sous le message de bienvenue (déjà existant)
  final double spacingUnderWelcome;

  /// Espace **entre** le logo et le message de bienvenue
  final double spacingBetweenLogoAndWelcome;

  const PlayUIConfig({
    required this.panelHeightFactor,
    required this.sectionStyles,
    this.spacingUnderWelcome = 16.0,
    this.spacingBetweenLogoAndWelcome = 1.0,
  });
}

/// Overlay calendrier (configurable)
class CalendarOverlayConfig {
  final bool showSeconds;
  final bool use24h;
  final EdgeInsets padding;
  final double borderRadius;
  final Color bgColor;
  final Color iconColor;
  final double iconSize;
  final TextStyle textStyle;
  final double spacing;
  final List<BoxShadow>? shadows;

  const CalendarOverlayConfig({
    this.showSeconds = false,
    this.use24h = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = 16,
    this.bgColor = const Color(0xFF2E53B3),
    this.iconColor = const Color(0xFFFFD740),
    this.iconSize = 24,
    this.textStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
    ),
    this.spacing = 10,
    this.shadows = const [
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  });
}

/// Couleurs de base
const _titleColor = Color(0xFF0E1420);
const _cardWhite = Colors.white;

/// Petite constante manquante dans la branche “catégories”
const double baseCardHeight = 180;

/// ========= CONFIG GLOBALE =========
final PlayUIConfig UI = PlayUIConfig(
  panelHeightFactor: 0.72,
  sectionStyles: {
    'quick': const SectionStyle(
      itemHeight: 200,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    ),
    'courses': const SectionStyle(
      itemHeight: 200,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    ),
    'bank': const SectionStyle(
      itemHeight: 170,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    ),
    'resources': const SectionStyle(
      itemHeight: 170,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    ),
    'history': const SectionStyle(
      itemHeight: 190,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    ),
    'challenge': const SectionStyle(
      itemHeight: 205,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    ),
    'help': const SectionStyle(
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    ),
  },
  spacingUnderWelcome: 16.0,
  spacingBetweenLogoAndWelcome: 1.0,
);

const CalendarOverlayConfig CAL = CalendarOverlayConfig();

/// ============================================================================
/// === ÉCRAN ==================================================================
/// ============================================================================
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  static const Color _bottomBarColor = Color(0xFF5B2E91);
  static const Color _bottomBarHighlight = Color(0x29FFFFFF);
  static const Color _fabForeground = Color(0xFF5B2E91);

  int _selectedNavIndex = 0;
  late final List<_NavDestination> _navItems;

  // Carrousel
  final List<String> _promoImages = const [
    'assets/images/C1.png',
    'assets/images/C2.png',
    'assets/images/C3.png',
    'assets/images/C4.png',
  ];
  late final PageController _promoController;
  Timer? _promoTimer;
  int _promoIndex = 0;

  bool _resumingQuickQuiz = false;

  // Fonds
  late final AssetImage _screenBg =
      const AssetImage('assets/images/background_playscreen.png');
  late final AssetImage _panelBg =
      const AssetImage('assets/images/background_playscreen2.png');

  // Horloge
  final ValueNotifier<DateTime> _now = ValueNotifier<DateTime>(DateTime.now());
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _navItems = [
      _NavDestination(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
        builder: (_) => const DashboardScreen(),
      ),
      _NavDestination(
        icon: Icons.quiz_outlined,
        label: 'Quiz',
        builder: (_) => const SubjectListScreen(),
      ),
      _NavDestination(
        icon: Icons.history,
        label: 'Historique',
        builder: (_) => const ExamHistoryScreen(),
      ),
      _NavDestination(
        icon: Icons.person_outline,
        label: 'Profil',
        builder: (_) => const ProfileEditScreen(),
      ),
      _NavDestination(
        icon: Icons.settings_outlined,
        label: 'Paramètres',
        builder: (_) => const DesignSettingsScreen(),
      ),
    ];

    _promoController = PageController(viewportFraction: 1.0);
    _startAutoPlay();
    _startClock();
    unawaited(OngoingQuickQuizStore.load());
  }

  void _startAutoPlay() {
    _promoTimer?.cancel();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _promoImages.isEmpty) return;
      if (!_promoController.hasClients) return;
      final next = (_promoIndex + 1) % _promoImages.length;
      _promoController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
      setState(() => _promoIndex = next);
    });
  }

  void _startClock() {
    _clockTimer?.cancel();
    final interval =
        CAL.showSeconds ? const Duration(seconds: 1) : const Duration(minutes: 1);
    _clockTimer = Timer.periodic(interval, (_) {
      _now.value = DateTime.now();
    });
  }

  Future<void> _onNavItemSelected(int index) async {
    setState(() => _selectedNavIndex = index);
    final builder = _navItems[index].builder;

    if (builder != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: builder),
      );
    }

    if (!mounted) return;

    setState(() => _selectedNavIndex = 0);
  }

  Future<void> _handleCreateQuickQuiz() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TrainingQuickStartScreen()),
    );
  }

  Future<void> _handleResumeQuickQuiz(OngoingQuickQuizState state) async {
    if (_resumingQuickQuiz) {
      return;
    }
    setState(() => _resumingQuickQuiz = true);
    bool dialogShown = false;
    void closeDialog() {
      if (!dialogShown) {
        return;
      }
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      dialogShown = false;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      dialogShown = true;

      final all = await QuestionLoader.loadENA();
      if (!mounted) {
        closeDialog();
        return;
      }
      final byId = <String, Question>{for (final q in all) q.id: q};
      final questions = <Question>[];
      for (final id in state.questionIds) {
        final question = byId[id];
        if (question != null) {
          questions.add(question);
        }
      }

      closeDialog();

      if (questions.isEmpty || questions.length != state.questionIds.length) {
        await OngoingQuickQuizStore.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de reprendre le quiz en cours.')),
        );
        return;
      }

      final initialAnswers = List<int?>.filled(questions.length, null, growable: false);
      for (int i = 0; i < initialAnswers.length && i < state.answers.length; i++) {
        initialAnswers[i] = state.answers[i];
      }
      final remaining = state.remainingSeconds > 0 ? state.remainingSeconds : 1;
      final scoring = const ExamScoring(correct: 1, wrong: -1, blank: 0, coefficient: 1);

      final result = await Navigator.push<ExamResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => ExamFullScreen(
            questions: questions,
            duration: Duration(seconds: remaining),
            scoring: scoring,
            title: state.title,
            showLocalSummary: true,
            initialAnswers: initialAnswers,
            initialRemainingSeconds: remaining,
            onStateChanged: (newRemaining, answers) {
              unawaited(
                OngoingQuickQuizStore.save(
                  state.copyWith(
                    remainingSeconds: newRemaining,
                    answers: answers,
                  ),
                ),
              );
            },
            onStateCleared: () {
              unawaited(OngoingQuickQuizStore.clear());
            },
          ),
        ),
      );
      await OngoingQuickQuizStore.clear();

      if (!mounted) {
        return;
      }
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz interrompu.')),
        );
      }
    } catch (err) {
      closeDialog();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de reprendre le quiz : $err')),
      );
    } finally {
      closeDialog();
      if (mounted) {
        setState(() => _resumingQuickQuiz = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_screenBg, context);
    precacheImage(_panelBg, context);
    for (final p in _promoImages) {
      precacheImage(AssetImage(p), context);
    }
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoController.dispose();
    _clockTimer?.cancel();
    _now.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final user = FirebaseAuth.instance.currentUser;
        final name = user?.displayName ?? user?.email;
        final hasName = name != null && name.isNotEmpty;

        final textColor =
            textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);
        final badgeColors = playIconColors(cfg.bgPaletteName);
        final nameColor =
            badgeColors.length > 1 ? badgeColors.last : badgeColors.first;
        final bgColor =
            pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode).first;

        final mq = MediaQuery.of(context);
        final scale = computeScaleFactor(mq);
        final textScaler = MediaQuery.textScalerOf(context);

        final welcomeFontSize = scaledFontSize(
            base: 22, scale: scale, textScaler: textScaler, min: 18, max: 28);
        final nameFontSize = scaledFontSize(
            base: 26, scale: scale, textScaler: textScaler, min: 20, max: 36);

        final screenH = mq.size.height;
        final topInset = mq.viewPadding.top;
        final headerAvailableH =
            screenH * (1 - UI.panelHeightFactor) - topInset;

        final desiredLogo =
            scaledDimension(base: 200, scale: scale, min: 140, max: 220);
        final maxLogoBySpace = (headerAvailableH * 0.65).clamp(100.0, 260.0);
        final logoHeight = desiredLogo.clamp(120.0, maxLogoBySpace);

        final overlay = cfg.darkMode
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
              );

        // ===== Orga des sections (ENA CI) =====
        final sections = kHomeCategories;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: textColor,
              toolbarHeight: 0,
            ),
            floatingActionButton: _buildMainFab(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: _buildBottomAppBar(),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Background écran
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: bgColor,
                    image: DecorationImage(image: _screenBg, fit: BoxFit.cover),
                  ),
                ),
                _buildHeader(
                  topInset: topInset,
                  hasName: hasName,
                  name: name,
                  welcomeFontSize: welcomeFontSize,
                  nameFontSize: nameFontSize,
                ),
                _buildSections(
                  sections: sections,
                  scale: scale,
                  panelHeightFactor: UI.panelHeightFactor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// NAV BAR
  Widget _buildBottomAppBar() {
    final buttons = <Widget>[];

    for (var i = 0; i < _navItems.length; i++) {
      if (i == 2) {
        buttons.add(const SizedBox(width: 68));
      }
      buttons.add(
        Expanded(
          child: _buildNavButton(i),
        ),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: _bottomBarColor,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: buttons,
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(int index) {
    final item = _navItems[index];
    final isSelected = _selectedNavIndex == index;
    final Color foreground =
        isSelected ? Colors.white : Colors.white.withOpacity(0.72);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNavItemSelected(index),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? _bottomBarHighlight : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: foreground, size: 22),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFab() {
    return FloatingActionButton(
      heroTag: 'play_screen_fab',
      backgroundColor: Colors.white,
      foregroundColor: _fabForeground,
      elevation: 8,
      onPressed: _handleCreateQuickQuiz,
      tooltip: 'Nouveau quiz',
      child: const Icon(Icons.add, size: 30),
    );
  }

  /// HEADER (logo + bienvenue)
  Widget _buildHeader({
    required double topInset,
    required bool hasName,
    required String? name,
    required double welcomeFontSize,
    required double nameFontSize,
  }) {
    final displayName = hasName && (name?.trim().isNotEmpty ?? false)
        ? name!.trim()
        : 'Utilisateur';
    final avatarLabel = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : '?';

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, topInset + 24, 24, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF6C4DFF),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Good Morning',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: welcomeFontSize,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Text(
                  avatarLabel,
                  style: const TextStyle(
                    color: Color(0xFF6C4DFF),
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BOX BLANCHE + BACKGROUND_Playscreen2 + CONTENU SCROLLABLE
  Widget _buildSections({
    required List<CategoryDefinition> sections,
    required double scale,
    required double panelHeightFactor,
  }) {
    final liveQuizItems = <_LiveQuizItem>[
      const _LiveQuizItem(
        icon: Icons.flash_on_rounded,
        iconColor: Color(0xFF7C4DFF),
        title: 'Sprint Express',
        subtitle: '20 questions en 5 minutes',
      ),
      const _LiveQuizItem(
        icon: Icons.people_alt_rounded,
        iconColor: Color(0xFF5336C6),
        title: 'Duel du soir',
        subtitle: 'Affronte un candidat au hasard',
      ),
      const _LiveQuizItem(
        icon: Icons.workspace_premium_rounded,
        iconColor: Color(0xFF9C6BFF),
        title: 'Marathon Officiel',
        subtitle: 'Sujet d’entraînement en conditions réelles',
      ),
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: panelHeightFactor,
        widthFactor: 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // image de fond de la BOX
              DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(image: _panelBg, fit: BoxFit.cover),
                ),
              ),
              // voile discret
              Container(color: Colors.white.withOpacity(0.04)),

              // === CONTENU (carrousel + tuiles) ===
              LayoutBuilder(
                builder: (context, _) {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Row(
                            children: [
                              const Spacer(),
                              ValueListenableBuilder<DateTime>(
                                valueListenable: _now,
                                builder: (_, now, __) {
                                  final text = _formatDateTime(now);
                                  return Container(
                                    padding: CAL.padding,
                                    decoration: BoxDecoration(
                                      color: CAL.bgColor,
                                      borderRadius:
                                          BorderRadius.circular(CAL.borderRadius),
                                      boxShadow: CAL.shadows,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today_rounded,
                                            size: CAL.iconSize,
                                            color: CAL.iconColor),
                                        SizedBox(width: CAL.spacing),
                                        Text(text, style: CAL.textStyle),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: _PromoCarousel(
                            images: _promoImages,
                            controller: _promoController,
                            currentIndex: _promoIndex,
                            onIndexTapped: (index) {
                              if (index == _promoIndex) {
                                return;
                              }
                              setState(() => _promoIndex = index);
                              if (_promoController.hasClients) {
                                _promoController.animateToPage(
                                  index,
                                  duration:
                                      const Duration(milliseconds: 450),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      // Carte "Reprendre le quiz"
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: ValueListenableBuilder<OngoingQuickQuizState?>(
                            valueListenable: OngoingQuickQuizStore.notifier,
                            builder: (_, state, __) {
                              final hasQuiz =
                                  state != null && state.questionIds.isNotEmpty;
                              final progress = hasQuiz
                                  ? state!.completionRatio.clamp(0.0, 1.0)
                                  : 0.0;
                              final percentLabel = hasQuiz
                                  ? '${(progress * 100).round()} % complété'
                                  : 'Aucun quiz en cours';
                              final subtitle = hasQuiz
                                  ? state!.title
                                  : 'Lancez un entraînement rapide pour continuer.';
                              return _RecentQuizCard(
                                subtitle: subtitle,
                                progress: progress,
                                progressLabel: percentLabel,
                                onContinue: hasQuiz
                                    ? () => _handleResumeQuickQuiz(state!)
                                    : null,
                                isBusy: _resumingQuickQuiz,
                              );
                            },
                          ),
                        ),
                      ),

                      // Carte "Invite tes amis"
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: _FeaturedCard(),
                        ),
                      ),

                      // Liste “Live Quiz”
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: _LiveQuizList(items: liveQuizItems),
                        ),
                      ),

                      // Sections ENA (catégories)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final section = sections[index];
                            final style = UI.sectionStyles[section.keyName]!;
                            final modulesCount = section.itemIndexes.length;

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                              child: HomeCategoryTile(
                                definition: section,
                                style: style,
                                modulesCount: modulesCount,
                                scale: scale,
                                height: style.itemHeight ?? baseCardHeight,
                                onTap: () => _navigate(context, section.category),
                              ),
                            );
                          },
                          childCount: sections.length,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format date/heure
  String _formatDateTime(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    final y = now.year.toString();
    final m = two(now.month);
    final d = two(now.day);
    int hour = now.hour;
    String suffix = '';
    if (!CAL.use24h) {
      suffix = hour >= 12 ? ' PM' : ' AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
    }
    final h = two(hour);
    final min = two(now.minute);
    final sec = two(now.second);
    final time = CAL.showSeconds ? '$h:$min:$sec' : '$h:$min';
    return '$d/$m/$y  $time$suffix';
  }

  /// NAVIGATION
  Future<void> _navigate(BuildContext context, HomeCategory category) async {
    final definition =
        kHomeCategories.firstWhere((element) => element.category == category);

    switch (category) {
      case HomeCategory.quickPrep:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrepaEnaScreen(definition: definition),
          ),
        );
        break;
      case HomeCategory.courses:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CoursEnaScreen(definition: definition),
          ),
        );
        break;
      case HomeCategory.bank:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BanqueSujetsScreen(definition: definition),
          ),
        );
        break;
      case HomeCategory.resources:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RessourcesOfficiellesScreen(
              definition: definition,
            ),
          ),
        );
        break;
      case HomeCategory.history:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoriqueSuiviScreen(definition: definition),
          ),
        );
        break;
      case HomeCategory.challenge:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DefisClassementScreen(definition: definition),
          ),
        );
        break;
      case HomeCategory.help:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AideThemesScreen(definition: definition),
          ),
        );
        break;
    }
  }
}

class _RecentQuizCard extends StatelessWidget {
  const _RecentQuizCard({
    required this.subtitle,
    required this.progress,
    required this.progressLabel,
    required this.onContinue,
    required this.isBusy,
  });

  final String subtitle;
  final double progress;
  final String progressLabel;
  final VoidCallback? onContinue;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final bool enabled = onContinue != null && !isBusy;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8856FF), Color(0xFF6C3BFF)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reprendre le quiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 14,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD740)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressLabel,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4315C5),
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: enabled ? onContinue : null,
                child: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Continuer',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.group_add_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite tes amis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF2D1B5E),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Décuple ta motivation avec une préparation collective.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F5A78),
                      ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF7C4DFF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Find Friends',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveQuizList extends StatelessWidget {
  const _LiveQuizList({required this.items});

  final List<_LiveQuizItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE8E6F3),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 26),
            ),
            title: Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1F1A3D),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            subtitle: Text(
              item.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6F6A89),
                  ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF7C4DFF)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class HomeCategoryTile extends StatelessWidget {
  const HomeCategoryTile({
    super.key,
    required this.definition,
    required this.style,
    required this.modulesCount,
    required this.scale,
    required this.height,
    required this.onTap,
  });

  final CategoryDefinition definition;
  final SectionStyle style;
  final int modulesCount;
  final double scale;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accent = definition.accentColor;
    final double iconContainerSize = (72 * scale).clamp(56.0, 86.0);
    final double iconSize = (48 * scale).clamp(36.0, 56.0);
    final String modulesLabel =
        '$modulesCount module${modulesCount > 1 ? 's' : ''}';
    final TextStyle descriptionStyle =
        theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5F5A78),
              fontWeight: FontWeight.w500,
            ) ??
            const TextStyle(
              color: Color(0xFF5F5A78),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            );
    final TextStyle badgeStyle =
        theme.textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ) ??
            TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            );

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: accent.withOpacity(0.16), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: iconContainerSize,
                    width: iconContainerSize,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      definition.icon,
                      color: accent,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          definition.title,
                          style: style.titleTextStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          definition.description,
                          style: descriptionStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(modulesLabel, style: badgeStyle),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: accent.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveQuizItem {
  const _LiveQuizItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
}

  /// Carrousel (si besoin ailleurs)
class _PromoCarousel extends StatelessWidget {
  final List<String> images;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onIndexTapped;

  const _PromoCarousel({
    super.key,
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onIndexTapped,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double height = (mq.size.height * 0.26).clamp(150, 260);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height.toDouble(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: PageView.builder(
              controller: controller,
              onPageChanged: onIndexTapped,
              itemCount: images.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(images[i], fit: BoxFit.cover),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: List.generate(images.length, (i) {
            final bool active = (i == currentIndex);
            return GestureDetector(
              onTap: () => onIndexTapped(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      active ? const Color(0xFFFFAB40) : const Color(0x33FFAB40),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: Color(0x33FFAB40),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _NavDestination {
  final IconData icon;
  final String label;
  final WidgetBuilder? builder;

  const _NavDestination({
    required this.icon,
    required this.label,
    this.builder,
  });
}
