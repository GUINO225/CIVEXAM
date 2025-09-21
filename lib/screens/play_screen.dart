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

/// ============================================================================
/// === CONFIG UI (éditable facilement) ========================================
/// ============================================================================

class SectionStyle {
  final double itemWidthFraction;
  final double? itemHeight;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color tileBackgroundColor;
  final TextStyle sectionTitleStyle;
  final TextStyle? tileTitleTextStyle;
  final Color? tileIconColor;
  final double tileSpacing;

  const SectionStyle({
    required this.itemWidthFraction,
    required this.itemHeight,
    required this.borderColor,
    this.borderWidth = 1.25,
    this.borderRadius = 18,
    required this.tileBackgroundColor,
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
  final double spacingUnderWelcome;

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
    this.iconColor = const Color(0xFFEF6C00),
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

/// Couleurs
const _blue = Color(0xFF1565C0);
const _orange = Color(0xFFEF6C00);
const _cardWhite = Colors.white;
const _titleColor = Color(0xFF1C2430);

/// ========= CONFIG GLOBALE =========
final PlayUIConfig UI = PlayUIConfig(
  panelHeightFactor: 0.60,
  quickPrepTitle: 'Prépa rapide',
  coursesTitle: 'Cours ENA (Côte d’Ivoire)',
  bankTitle: 'Sujets & corrigés',
  resourcesTitle: 'Ressources officielles (CI)',
  historyTitle: 'Historique & suivi',
  challengeTitle: 'Défis & classement',
  helpTitle: 'Aide & thèmes',
  sectionStyles: {
    // Prépa rapide
    'quick': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 150.0,
      borderColor: _blue,
      borderWidth: 1.4,
      borderRadius: 18,
      tileBackgroundColor: _cardWhite,
      sectionTitleStyle: const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileIconColor: _blue,
      tileSpacing: 12.0,
    ),

    // Cours
    'courses': SectionStyle(
      itemWidthFraction: 0.45,
      itemHeight: 140.0,
      borderColor: const Color(0xFF1E88E5),
      borderWidth: 1.2,
      borderRadius: 16,
      tileBackgroundColor: const Color(0xFFFDFEFE),
      sectionTitleStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileIconColor: const Color(0xFF1E88E5),
      tileSpacing: 10.0,
    ),

    // Banque
    'bank': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 150.0,
      borderColor: const Color(0xFF6A1B9A),
      borderWidth: 1.3,
      borderRadius: 18,
      tileBackgroundColor: const Color(0xFFF9F6FF),
      sectionTitleStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileIconColor: const Color(0xFF6A1B9A),
      tileSpacing: 12.0,
    ),

    // Ressources
    'resources': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 150.0,
      borderColor: const Color(0xFF2E7D32),
      borderWidth: 1.2,
      borderRadius: 18,
      tileBackgroundColor: const Color(0xFFF4FFF6),
      sectionTitleStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileIconColor: const Color(0xFF2E7D32),
      tileSpacing: 12.0,
    ),

    // Historique
    'history': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 180,
      borderColor: _orange,
      borderWidth: 1.25,
      borderRadius: 18,
      tileBackgroundColor: _orange,
      sectionTitleStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700, color: _cardWhite,
      ),
      tileIconColor: _cardWhite,
      tileSpacing: 12.0,
    ),

    // Défis
    'challenge': SectionStyle(
      itemWidthFraction: 0.55,
      itemHeight: 200,
      borderColor: _blue,
      borderWidth: 1.25,
      borderRadius: 18,
      tileBackgroundColor: _blue,
      sectionTitleStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: _cardWhite,
      ),
      tileIconColor: _cardWhite,
      tileSpacing: 12.0,
    ),

    // Aide
    'help': SectionStyle(
      itemWidthFraction: 1,
      itemHeight: null,
      borderColor: _orange,
      borderWidth: 1.25,
      borderRadius: 18,
      tileBackgroundColor: _cardWhite,
      sectionTitleStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileIconColor: _orange,
      tileSpacing: 12.0,
    ),
  },
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
    final interval = CAL.showSeconds ? const Duration(seconds: 1) : const Duration(minutes: 1);
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
          _Section(keyName: 'quick',     title: UI.quickPrepTitle, itemIndexes: const [0, 15, 1]),
          _Section(keyName: 'courses',   title: UI.coursesTitle,   itemIndexes: const [
            7, 16, 8, 17, 9, 10, 18, 11, 12, 13, 14, 19
          ]),
          _Section(keyName: 'bank',      title: UI.bankTitle,      itemIndexes: const [20, 21, 22]),
          _Section(keyName: 'resources', title: UI.resourcesTitle, itemIndexes: const [23, 24, 25, 26]),
          _Section(keyName: 'history',   title: UI.historyTitle,   itemIndexes: const [2, 3]),
          _Section(keyName: 'challenge', title: UI.challengeTitle, itemIndexes: const [5, 6]),
          _Section(keyName: 'help',      title: UI.helpTitle,      itemIndexes: const [4]),
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
                icon: const Icon(Icons.person_outline, color: Color(0xFF0D47A1)),
                tooltip: 'Tableau de bord',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
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
                    MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                  );
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
    required DesignConfig cfg,
    required List<_Section> sections,
    required double scale,
    required Color textColor,
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
                  (h > 260) ? 200.0 : (h - 80).clamp(150.0, 220.0);

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
                            if (index.isOdd) return const SizedBox(height: 12);
                            final si = index ~/ 2;
                            final section = sections[si];
                            final style = UI.sectionStyles[section.keyName]!;

                            final double itemWidth =
                            (w * style.itemWidthFraction).clamp(80.0, w);
                            final double itemHeight =
                                style.itemHeight ?? baseCardHeight;

                            final double viewportFraction =
                            (itemWidth / w).clamp(0.1, 1.0);
                            final controller = PageController(
                                viewportFraction: viewportFraction);

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(section.title,
                                      style: style.sectionTitleStyle),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: itemHeight,
                                    child: PageView.builder(
                                      controller: controller,
                                      padEnds: false,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: section.itemIndexes.length,
                                      itemBuilder: (context, pi) {
                                        final i = section.itemIndexes[pi];
                                        final item = _items[i];
                                        final trailing =
                                        (pi == section.itemIndexes.length - 1)
                                            ? 0.0
                                            : style.tileSpacing;

                                        final paletteColors =
                                        playIconColors(item.palette);
                                        final iconColor = style.tileIconColor ??
                                            (paletteColors.isNotEmpty
                                                ? paletteColors.last
                                                : textColor);

                                        final tile = _TileCard(
                                          borderColor: style.borderColor,
                                          borderWidth: style.borderWidth,
                                          borderRadius: style.borderRadius,
                                          backgroundColor:
                                          style.tileBackgroundColor,
                                          onTap: () => _navigate(context, i),
                                          child: _BasicTile(
                                            title: item.title,
                                            icon: item.icon,
                                            iconSize: scale * 48,
                                            iconColor: iconColor,
                                            titleStyle:
                                            style.tileTitleTextStyle ??
                                                const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  color: _titleColor,
                                                ),
                                          ),
                                        );

                                        return Padding(
                                          padding:
                                          EdgeInsets.only(right: trailing),
                                          child: SizedBox(
                                            width: itemWidth,
                                            height: itemHeight,
                                            child: tile,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: sections.length * 2 - 1,
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
  Future<void> _showComingSoon(BuildContext context, String title, [String? body]) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body ?? 'Bientôt disponible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, null), child: const Text('OK')),
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
        await _showComingSoon(context, 'Comment ça marche ?', 'Fiches d’utilisation et tutoriels arrivent.');
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
      case 7:  await _showComingSoon(context, 'Culture générale (CI & Afrique)'); break;
      case 16: await _showComingSoon(context, 'Communication administrative'); break;
      case 8:  await _showComingSoon(context, 'Droit public (Constitutionnel & Administratif)'); break;
      case 17: await _showComingSoon(context, 'TIC & Bureautique'); break;
      case 9:  await _showComingSoon(context, 'Finances publiques (CI)'); break;
      case 10: await _showComingSoon(context, 'Économie & gestion'); break;
      case 18: await _showComingSoon(context, 'Comptabilité publique'); break;
      case 11: await _showComingSoon(context, 'Relations internationales & UE'); break;
      case 12: await _showComingSoon(context, 'Institutions de la Côte d’Ivoire'); break;
      case 13: await _showComingSoon(context, 'Note de synthèse'); break;
      case 14: await _showComingSoon(context, 'Méthodologie QRC / QCM'); break;
      case 19: await _showComingSoon(context, 'Anglais (option)'); break;

    // ===== Banque de sujets & corrigés
      case 20: await _showComingSoon(context, 'Banque de sujets ENA CI'); break;
      case 21: await _showComingSoon(context, 'Corrigés détaillés'); break;
      case 22: await _showComingSoon(context, 'Sujets par filière (A/B/C)'); break;

    // ===== Ressources officielles
      case 23: await _showComingSoon(context, 'Constitution & textes clés'); break;
      case 24: await _showComingSoon(context, 'Programme officiel (PDF)'); break;
      case 25: await _showComingSoon(context, 'Calendrier des concours'); break;
      case 26: await _showComingSoon(context, 'Textes ENA / Arrêtés / Guides'); break;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 8),
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

class _TileCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _TileCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor.withOpacity(0.85), width: borderWidth),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          color: backgroundColor,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
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
    final double height = (mq.size.height * 0.18).clamp(120, 180);

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
                  color: active ? _orange : _orange.withOpacity(0.35),
                  boxShadow: active
                      ? const [
                    BoxShadow(
                      color: Color(0x33EF6C00),
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
  final IconData icon;
  final String palette;
  const _MenuItem(this.title, this.icon, this.palette);
}

// Indices : 0..6 existants, 7..26 nouveaux
const _items = <_MenuItem>[
  // Base existante
  _MenuItem('Simulation concours ENA', Icons.school_rounded, 'violetRose'),     // 0
  _MenuItem('Entraînement par matière', Icons.menu_book_rounded, 'sereneBlue'), // 1
  _MenuItem('Historique examens', Icons.fact_check_rounded, 'lightGreen'),      // 2
  _MenuItem('Historique entraînement', Icons.history_rounded, 'softYellow'),    // 3
  _MenuItem('Comment ça marche ?', Icons.info_rounded, 'powderPink'),           // 4
  _MenuItem('Classement', Icons.emoji_events_outlined, 'royalViolet'),          // 5
  _MenuItem('Compétition', Icons.sports_kabaddi, 'forestGreen'),                // 6

  // Cours ENA (CI)
  _MenuItem('Culture générale (CI & Afrique)', Icons.auto_stories_rounded, 'sereneBlue'), // 7
  _MenuItem('Droit public (Consti/Administratif)', Icons.gavel_rounded, 'royalViolet'),   // 8
  _MenuItem('Finances publiques (CI)', Icons.account_balance_wallet_rounded, 'lightGreen'), // 9
  _MenuItem('Économie & gestion', Icons.show_chart_rounded, 'softYellow'),                // 10
  _MenuItem('Relations internationales & UE', Icons.public_rounded, 'violetRose'),        // 11
  _MenuItem('Institutions de la Côte d’Ivoire', Icons.corporate_fare_rounded, 'sereneBlue'), // 12
  _MenuItem('Note de synthèse', Icons.description_rounded, 'powderPink'),                 // 13
  _MenuItem('Méthodo QRC / QCM', Icons.checklist_rtl_rounded, 'forestGreen'),             // 14
  _MenuItem('Examens blancs ENA', Icons.timer_rounded, 'royalViolet'),                    // 15
  _MenuItem('Communication administrative', Icons.record_voice_over_rounded, 'powderPink'), // 16
  _MenuItem('TIC & Bureautique', Icons.computer_rounded, 'sereneBlue'),                   // 17
  _MenuItem('Comptabilité publique', Icons.request_quote_rounded, 'lightGreen'),          // 18
  _MenuItem('Anglais (option)', Icons.translate_rounded, 'softYellow'),                   // 19

  // Banque de sujets & corrigés
  _MenuItem('Banque de sujets ENA CI', Icons.folder_special_rounded, 'royalViolet'),      // 20
  _MenuItem('Corrigés détaillés', Icons.task_rounded, 'violetRose'),                      // 21
  _MenuItem('Sujets par filière (A/B/C)', Icons.view_module_rounded, 'forestGreen'),      // 22

  // Ressources officielles (CI)
  _MenuItem('Constitution & textes clés', Icons.menu_book_outlined, 'sereneBlue'),        // 23
  _MenuItem('Programme officiel (PDF)', Icons.picture_as_pdf_rounded, 'powderPink'),      // 24
  _MenuItem('Calendrier des concours', Icons.calendar_month_rounded, 'softYellow'),       // 25
  _MenuItem('Textes ENA / Arrêtés / Guides', Icons.library_books_rounded, 'lightGreen'),  // 26
];
