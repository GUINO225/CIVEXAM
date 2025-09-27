// lib/screens/play_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/auth_service.dart';
import '../utils/palette_utils.dart';
import '../utils/responsive_utils.dart';

import 'leaderboard_screen.dart';
import 'dashboard_screen.dart';
import 'design_settings_screen.dart';
import 'login_screen.dart';
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
  final _auth = AuthService();
  bool _signingOut = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_screenBg, context);
    precacheImage(_panelBg, context);
    for (final p in _promoImages) {
      precacheImage(AssetImage(p), context);
    }
    // Précharger les PNG des tuiles disponibles
    for (final it in kCategoryMenuItems) {
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
            bottomNavigationBar: _buildBottomNav(),
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
                  logoHeight: logoHeight,
                  topInset: topInset,
                  hasName: hasName,
                  name: name,
                  textColor: textColor,
                  welcomeFontSize: welcomeFontSize,
                  nameColor: nameColor,
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
  Widget _buildBottomNav() {
    return Container(
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
                icon:
                const Icon(Icons.person_outline, color: Color(0xFF0D47A1)),
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
                icon: const Icon(Icons.emoji_events_outlined,
                    color: Color(0xFF0D47A1)),
                tooltip: 'Classement',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined,
                    color: Color(0xFF0D47A1)),
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
    );
  }

  /// HEADER (logo + bienvenue)
  Widget _buildHeader({
    required double logoHeight,
    required double topInset,
    required bool hasName,
    required String? name,
    required Color textColor,
    required double welcomeFontSize,
    required Color nameColor,
    required double nameFontSize,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, topInset + 4, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_splash.png',
              height: logoHeight,
              fit: BoxFit.contain,
            ),
            SizedBox(height: UI.spacingBetweenLogoAndWelcome),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bienvenue 👋 ',
                      style: TextStyle(
                        color: textColor,
                        fontSize: welcomeFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    if (hasName)
                      TextSpan(
                        text: name!,
                        style: TextStyle(
                          color: nameColor,
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: UI.spacingUnderWelcome),
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
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  final baseCardHeight =
                  (h > 260) ? 220.0 : (h - 60).clamp(170.0, 240.0);

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Barre calendrier
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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

                      // Carrousel
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: _PromoCarousel(
                            images: _promoImages,
                            controller: _promoController,
                            currentIndex: _promoIndex,
                            onIndexTapped: (idx) {
                              _promoController.animateToPage(
                                idx,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOut,
                              );
                              setState(() => _promoIndex = idx);
                            },
                          ),
                        ),
                      ),

                      // Sections
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final section = sections[index];
                            final style = UI.sectionStyles[section.keyName]!;
                            final double cardHeight =
                                style.itemHeight ?? baseCardHeight;
                            final Color accentColor =
                                _pickTileMainColor(style);
                            final Color iconColor =
                                style.tileIconColor ?? Colors.white;
                            final Color descriptionColor =
                                style.tileTitleTextStyle?.color ??
                                    Colors.white.withOpacity(0.85);
                            final modulesCount = section.itemIndexes.length;
                            final modulesLabel =
                                '$modulesCount module${modulesCount > 1 ? 's' : ''}';

                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 6, 16, 0),
                              child: SizedBox(
                                height: cardHeight,
                                child: _TileCard(
                                  borderColor: style.borderColor,
                                  borderWidth: style.borderWidth,
                                  borderRadius: style.borderRadius,
                                  backgroundColor: style.tileBackgroundColor,
                                  gradient: style.tileGradient,
                                  onTap: () => _navigate(context, section.category),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                section.title,
                                                style: style.sectionTitleStyle,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                section.description,
                                                style: TextStyle(
                                                  color: descriptionColor,
                                                  fontSize: 15 * scale,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: accentColor
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30),
                                                ),
                                                child: Text(
                                                  modulesLabel,
                                                  style: TextStyle(
                                                    color: accentColor,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        _buildCategoryVisual(
                                          section,
                                          iconColor,
                                          scale,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: sections.length,
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
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

  Widget _buildCategoryVisual(
    CategoryDefinition section,
    Color iconColor,
    double scale,
  ) {
    final double size = (120 * scale).clamp(80.0, 140.0);
    if (section.asset != null) {
      return SizedBox(
        height: size,
        width: size,
        child: Image.asset(
          section.asset!,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: Icon(
        section.icon ?? Icons.apps_rounded,
        size: size * 0.7,
        color: iconColor,
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

