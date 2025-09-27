// lib/screens/play_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:characters/characters.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import '../utils/responsive_utils.dart';

import 'official_intro_screen.dart';
import 'subject_list_screen.dart';
import 'training_history_screen.dart';
import 'exam_history_screen.dart';
import 'leaderboard_screen.dart';
import 'dashboard_screen.dart';
import 'design_settings_screen.dart';
import 'competition_screen.dart';
import 'profile_edit_screen.dart';
import 'training_quick_start.dart';
import 'courses/communication_administrative_screen.dart';
import 'courses/culture_generale_screen.dart';
import 'courses/droit_public_screen.dart';
import '../services/question_loader.dart';
import '../services/question_randomizer.dart';
import '../services/question_history_store.dart';
import '../models/question.dart';

/// ============================================================================
/// === CONFIG UI (éditable facilement) ========================================
/// ============================================================================

class SectionStyle {
  final double itemWidthFraction;
  final double? itemHeight;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  /// Couleur de fond… si `tileGradient` est null.
  final Color tileBackgroundColor;

  /// Dégradé vibrant (prioritaire si défini)
  final Gradient? tileGradient;

  final TextStyle sectionTitleStyle;

  /// Couleur du texte sur la tuile (par défaut: blanc sur dégradé sombre)
  final TextStyle? tileTitleTextStyle;

  /// Couleur de l’icône (par défaut: blanc)
  final Color? tileIconColor;

  final double tileSpacing;

  const SectionStyle({
    required this.itemWidthFraction,
    required this.itemHeight,
    required this.borderColor,
    this.borderWidth = 1.25,
    this.borderRadius = 18,
    required this.tileBackgroundColor,
    this.tileGradient,
    required this.sectionTitleStyle,
    this.tileTitleTextStyle,
    this.tileIconColor,
    this.tileSpacing = 12,
  });
}

class PlayUIConfig {
  final double panelHeightFactor;
  final String quickPrepTitle;
  final String coursesTitle;
  final String bankTitle;
  final String resourcesTitle;
  final String historyTitle;
  final String challengeTitle;
  final String helpTitle;
  final Map<String, SectionStyle> sectionStyles;

  /// Espace sous le message de bienvenue (déjà existant)
  final double spacingUnderWelcome;

  /// Espace **entre** le logo et le message de bienvenue
  final double spacingBetweenLogoAndWelcome;

  const PlayUIConfig({
    required this.panelHeightFactor,
    required this.quickPrepTitle,
    required this.coursesTitle,
    required this.bankTitle,
    required this.resourcesTitle,
    required this.historyTitle,
    required this.challengeTitle,
    required this.helpTitle,
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

/// ========= CONFIG GLOBALE =========
final PlayUIConfig UI = PlayUIConfig(
  panelHeightFactor: 0.72,
  quickPrepTitle: 'Prépa rapide',
  coursesTitle: 'Cours ENA (Côte d’Ivoire)',
  bankTitle: 'Sujets & corrigés',
  resourcesTitle: 'Ressources officielles (CI)',
  historyTitle: 'Historique & suivi',
  challengeTitle: 'Défis & classement',
  helpTitle: 'Aide & thèmes',
  sectionStyles: {
    'quick': SectionStyle(
      itemWidthFraction: 0.50,
      itemHeight: 200,
      borderColor: const Color(0x887C4DFF),
      borderWidth: 1.0,
      borderRadius: 10,
      tileBackgroundColor: const Color(0xFF7C4DFF),
      tileGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4DBBFF), Color(0xFF3182EA)],
      ),
      sectionTitleStyle: const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white,
      ),
      tileIconColor: Colors.white,
      tileSpacing: 12.0,
    ),

    'courses': SectionStyle(
      itemWidthFraction: 0.46,
      itemHeight: 200.0,
      borderColor: const Color(0xFF21295C),
      borderWidth: 1.0,
      borderRadius: 10,
      tileBackgroundColor: const Color(0xFF00E5FF),
      tileGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4DBBFF), Color(0xFF3182EA)], ),
      sectionTitleStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
      ),
      tileIconColor: Colors.white,
      tileSpacing: 10.0,
    ),

    'bank': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 160.0,
      borderColor: const Color(0x88FFC400),
      borderWidth: 1.0,
      borderRadius: 10,
      tileBackgroundColor: const Color(0xFFFFC400),
      tileGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFA200), Color(0xFFFF8800)],
      ),
      sectionTitleStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
      ),
      tileIconColor: Colors.white,
      tileSpacing: 12.0,
    ),

    'resources': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 160.0,
      borderColor: const Color(0x8800C853),
      borderWidth: 1.0,
      borderRadius: 0,
      tileBackgroundColor: const Color(0xFF00C853),
      tileGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF5A00), Color(0xFFFF4C00)],
      ),
      sectionTitleStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
      ),
      tileIconColor: Colors.white,
      tileSpacing: 12.0,
    ),

    'history': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 190,
      borderColor: const Color(0x88FF6D00),
      borderWidth: 1.0,
      borderRadius: 2,
      tileBackgroundColor: const Color(0xFFFF6D00),
      tileGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF006507), Color(0xFF2F5C00)],
      ),
      sectionTitleStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
      ),
      tileIconColor: Colors.white,
      tileSpacing: 12.0,
    ),

    'challenge': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 205,
      borderColor: const Color(0x882962FF),
      borderWidth: 1.0,
      borderRadius: 2,
      tileBackgroundColor: const Color(0xFF2962FF),
      tileGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF264653), Color(0xFF264653)],
      ),
      sectionTitleStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
      ),
      tileIconColor: Colors.white,
      tileSpacing: 12.0,
    ),

    'help': SectionStyle(
      itemWidthFraction: 1,
      itemHeight: null,
      borderColor: const Color(0x88AA00FF),
      borderWidth: 1.0,
      borderRadius: 2,
      tileBackgroundColor: const Color(0xFFAA00FF),
      tileGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4DBBFF), Color(0xFF3182EA)],
      ),
      sectionTitleStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
      ),
      tileIconColor: Colors.white,
      tileSpacing: 12.0,
    ),
  },

  spacingUnderWelcome: 16.0,
  spacingBetweenLogoAndWelcome: 1.0,
);

const CalendarOverlayConfig CAL = CalendarOverlayConfig();

/// === Helper: couleur principale de la tuile (dernier stop du gradient sinon fond) ===
Color _pickTileMainColor(SectionStyle style) {
  final g = style.tileGradient;
  if (g is LinearGradient && g.colors.isNotEmpty) return g.colors.last;
  if (g is RadialGradient && g.colors.isNotEmpty) return g.colors.last;
  if (g is SweepGradient && g.colors.isNotEmpty) return g.colors.last;
  return style.tileBackgroundColor;
}

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
  }

  void _startAutoPlay() {
    _promoTimer?.cancel();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _promoImages.isEmpty) return;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_screenBg, context);
    precacheImage(_panelBg, context);
    for (final p in _promoImages) {
      precacheImage(AssetImage(p), context);
    }
    // Précharger les PNG des tuiles disponibles
    for (final it in _items) {
      if (it.asset != null) {
        precacheImage(AssetImage(it.asset!), context);
      }
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
        final sections = <_Section>[
          _Section(
              keyName: 'quick',
              title: UI.quickPrepTitle,
              itemIndexes: const [0, 15, 1]),
          _Section(
              keyName: 'courses',
              title: UI.coursesTitle,
              itemIndexes: const [
                7,
                16,
                8,
                17,
                9,
                10,
                18,
                11,
                12,
                13,
                14,
                19
              ]),
          _Section(
              keyName: 'bank',
              title: UI.bankTitle,
              itemIndexes: const [20, 21, 22]),
          _Section(
              keyName: 'resources',
              title: UI.resourcesTitle,
              itemIndexes: const [23, 24, 25, 26]),
          _Section(
              keyName: 'history',
              title: UI.historyTitle,
              itemIndexes: const [2, 3]),
          _Section(
              keyName: 'challenge',
              title: UI.challengeTitle,
              itemIndexes: const [5, 6]),
          _Section(
              keyName: 'help', title: UI.helpTitle, itemIndexes: const [4]),
        ];

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
                  cfg: cfg,
                  sections: sections,
                  scale: scale,
                  textColor: textColor,
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
    required DesignConfig cfg,
    required List<_Section> _sections,
    required double scale,
    required Color textColor,
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
                          child: _RecentQuizCard(),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: _FeaturedCard(),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: _LiveQuizList(items: liveQuizItems),
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

  /// Helper placeholder
  Future<void> _showComingSoon(BuildContext context, String title,
      [String? body]) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body ?? 'Bientôt disponible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, null),
              child: const Text('OK')),
        ],
      ),
    );
  }

  /// NAVIGATION
  Future<void> _navigate(BuildContext context, int index) async {
    switch (index) {
    // ===== Prépa rapide & existants
      case 0: // Simulation concours
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OfficialIntroScreen()));
        break;
      case 1: // Entraînement par matière
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SubjectListScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ExamHistoryScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()));
        break;
      case 4:
        await _showComingSoon(context, 'Comment ça marche ?',
            'Fiches d’utilisation et tutoriels arrivent.');
        break;
      case 5:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
        break;
      case 6:
      // Compétition chronométrée (existant)
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
          if (!proceed) return;

          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          unawaited(
            QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError(
                  (Object error, _) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Échec de l’enregistrement de l’historique des questions.'),
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
            SnackBar(content: Text('Unable to load question bank: $e')),
          );
        }
        break;
      case 15: // Examens blancs (NOUVEAU)
        await _showComingSoon(
          context,
          'Examens blancs ENA',
          'Programmez des sessions complètes (durées, barèmes, corrigés).',
        );
        break;

    // ===== Cours ENA (CI)
      case 7:
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CultureGeneraleScreen(),
          ),
        );
        break;
      case 16:
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CommunicationAdministrativeScreen(),
          ),
        );
        break;
      case 8:
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DroitPublicScreen(),
          ),
        );
        break;
      case 17:
        await _showComingSoon(context, 'TIC & Bureautique');
        break;
      case 9:
        await _showComingSoon(context, 'Finances publiques (CI)');
        break;
      case 10:
        await _showComingSoon(context, 'Économie & gestion');
        break;
      case 18:
        await _showComingSoon(context, 'Comptabilité publique');
        break;
      case 11:
        await _showComingSoon(context, 'Relations internationales & UE');
        break;
      case 12:
        await _showComingSoon(context, 'Institutions de la Côte d’Ivoire');
        break;
      case 13:
        await _showComingSoon(context, 'Note de synthèse');
        break;
      case 14:
        await _showComingSoon(context, 'Méthodologie QRC / QCM');
        break;
      case 19:
        await _showComingSoon(context, 'Anglais (option)');
        break;

    // ===== Banque de sujets & corrigés
      case 20:
        await _showComingSoon(context, 'Banque de sujets ENA CI');
        break;
      case 21:
        await _showComingSoon(context, 'Corrigés détaillés');
        break;
      case 22:
        await _showComingSoon(context, 'Sujets par filière (A/B/C)');
        break;

    // ===== Ressources officielles
      case 23:
        await _showComingSoon(context, 'Constitution & textes clés');
        break;
      case 24:
        await _showComingSoon(context, 'Programme officiel (PDF)');
        break;
      case 25:
        await _showComingSoon(context, 'Calendrier des concours');
        break;
      case 26:
        await _showComingSoon(context, 'Textes ENA / Arrêtés / Guides');
        break;

      default:
      // sécurité
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fonctionnalité à venir.')),
        );
        break;
    }
  }

  Future<bool> _handleShortDraw(List<Question> selected, int requested) async {
    if (selected.length >= requested) return true;
    if (!mounted) return false;

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

class _RecentQuizCard extends StatelessWidget {
  const _RecentQuizCard();

  @override
  Widget build(BuildContext context) {
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
            'Préparation concours ENA',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LinearProgressIndicator(
              value: 0.65,
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
                '65 % complété',
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
                onPressed: () {},
                child: const Text(
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

/// ============================================================================
/// === HELPERS / MODÈLES LOCAUX ===============================================
/// ============================================================================

class _Section {
  final String keyName;
  final String title;
  final List<int> itemIndexes;
  const _Section({
    required this.keyName,
    required this.title,
    required this.itemIndexes,
  });
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

class _BasicTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final TextStyle titleStyle;

  const _BasicTile({
    super.key,
    required this.title,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Nouveau : tuile icône OU image PNG
class _IconOnlyTile extends StatelessWidget {
  final IconData? icon;
  final String? asset; // chemin PNG
  final double iconSize;
  final Color iconColor;

  const _IconOnlyTile({
    super.key,
    required this.icon,
    required this.asset,
    required this.iconSize,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (asset != null) {
      child = Image.asset(
        asset!,
        height: iconSize,
        width: iconSize,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    } else {
      child = Icon(icon, size: iconSize, color: iconColor);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}

class _TileCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const _TileCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.backgroundColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
          gradient: gradient,
          color: gradient == null ? backgroundColor : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// Carrousel
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

/// ============================================================================
/// === DONNÉES : tuiles affichées =============================================
/// ============================================================================

class _MenuItem {
  final String title;
  final String palette;
  final IconData? icon; // fallback
  final String? asset; // PNG dans assets/images/tuiles/

  const _MenuItem.icon(this.title, this.icon, this.palette) : asset = null;
  const _MenuItem.asset(this.title, this.asset, this.palette) : icon = null;
}

// Indices : 0..6 existants, 7..26 nouveaux
const _items = <_MenuItem>[
  // Base existante (branche les PNG disponibles)
  _MenuItem.asset('Simulation concours ENA',
      "assets/images/tuiles/Simulation concours ENA.png", 'violetRose'), // 0
  _MenuItem.asset('Entraînement par matière',
      "assets/images/tuiles/Entraînement par matière.png", 'sereneBlue'), // 1
  _MenuItem.asset('Historique examens',
      "assets/images/tuiles/Historique examens.png", 'lightGreen'), // 2
  _MenuItem.asset('Historique entraînement',
      "assets/images/tuiles/Historique entraînement.png", 'softYellow'), // 3
  _MenuItem.asset('Comment ça marche ?',
      "assets/images/tuiles/Comment ça marche.png", 'powderPink'), // 4
  _MenuItem.asset('Classement',
      "assets/images/tuiles/Classement.png", 'royalViolet'), // 5
  _MenuItem.asset('Compétition',
      "assets/images/tuiles/Compétition.png", 'forestGreen'), // 6

  // Cours ENA (CI)
  _MenuItem.asset('Culture générale (CI & Afrique)',
      "assets/images/tuiles/Culture générale (CI & Afrique).png", 'sereneBlue'), // 7
  _MenuItem.asset('Droit public (Consti/Administratif)',
      "assets/images/tuiles/Droit public Consti Administratif.png", 'royalViolet'), // 8
  _MenuItem.asset('Finances publiques (CI)',
      "assets/images/tuiles/Finances publiques (CI).png", 'lightGreen'), // 9
  _MenuItem.asset('Économie & gestion',
      "assets/images/tuiles/Économie & gestion.png", 'softYellow'), // 10
  _MenuItem.asset('Relations internationales & UE',
      "assets/images/tuiles/Relations internationales & UE.png", 'violetRose'), // 11
  _MenuItem.asset('Institutions de la Côte d’Ivoire',
      "assets/images/tuiles/Institutions de la Côte d'ivoire.png", 'sereneBlue'), // 12

  // Pas encore d’assets → fallback icônes
  _MenuItem.icon('Note de synthèse', Icons.description_rounded, 'powderPink'), // 13
  _MenuItem.icon('Méthodo QRC / QCM', Icons.checklist_rtl_rounded, 'forestGreen'), // 14
  _MenuItem.icon('Examens blancs ENA', Icons.timer_rounded, 'royalViolet'), // 15
  _MenuItem.icon('Communication administrative', Icons.record_voice_over_rounded, 'powderPink'), // 16
  _MenuItem.icon('TIC & Bureautique', Icons.computer_rounded, 'sereneBlue'), // 17
  _MenuItem.icon('Comptabilité publique', Icons.request_quote_rounded, 'lightGreen'), // 18
  _MenuItem.icon('Anglais (option)', Icons.translate_rounded, 'softYellow'), // 19

  // Banque de sujets & corrigés
  _MenuItem.icon('Banque de sujets ENA CI', Icons.folder_special_rounded, 'royalViolet'), // 20
  _MenuItem.icon('Corrigés détaillés', Icons.task_rounded, 'violetRose'), // 21
  _MenuItem.icon('Sujets par filière (A/B/C)', Icons.view_module_rounded, 'forestGreen'), // 22

  // Ressources officielles (CI)
  _MenuItem.icon('Constitution & textes clés', Icons.menu_book_outlined, 'sereneBlue'), // 23
  _MenuItem.icon('Programme officiel (PDF)', Icons.picture_as_pdf_rounded, 'powderPink'), // 24
  _MenuItem.icon('Calendrier des concours', Icons.calendar_month_rounded, 'softYellow'), // 25
  _MenuItem.icon('Textes ENA / Arrêtés / Guides', Icons.library_books_rounded, 'lightGreen'), // 26
];
