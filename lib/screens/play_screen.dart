// lib/screens/play_screen.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:characters/characters.dart';

import '../models/design_config.dart';
import '../models/exam_history_entry.dart';
import '../models/leaderboard_entry.dart';
import '../services/design_bus.dart';
import '../services/ongoing_quiz_store.dart';
import '../services/question_loader.dart';
import '../services/scoring.dart';
import '../services/history_store.dart';
import '../services/competition_service.dart';
import '../services/competition_quiz_launcher.dart';
import '../services/arcade_progress_store.dart';
import '../utils/palette_utils.dart';
import '../utils/responsive_utils.dart';

import '../widgets/arcade_badge_chip.dart';

import '../models/question.dart';

import 'dashboard_screen.dart';
import 'design_settings_screen.dart';
import 'subject_list_screen.dart';
import 'exam_history_screen.dart';
import 'profile_edit_screen.dart';
import 'training_quick_start.dart';
import 'exam_full_screen.dart';
import 'leaderboard_screen.dart';
import 'arcade_mode_screen.dart';

// --- Catégories refactorisées (ENA CI) ---
import 'categories/category_definitions.dart';
import 'categories/prepa_ena_screen.dart';
import 'categories/cours_ena_screen.dart';
import 'categories/banque_sujets_screen.dart';
import 'categories/ressources_officielles_screen.dart';
import 'categories/historique_suivi_screen.dart';
import 'categories/defis_classement_screen.dart';
import 'categories/aide_themes_screen.dart';
import 'official_intro_screen.dart';

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
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeShell();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const Color _bottomBarColor = Color(0xFF6C4DFF);
  static const Color _bottomBarHighlight = Color(0x29FFFFFF);
  static const Color _fabForeground = Color(0xFF6C4DFF);

  int _selectedNavIndex = 0;
  late final List<_NavDestination> _navItems;

  final CompetitionService _competitionService = CompetitionService();
  List<LeaderboardEntry> _topEntries = const [];
  bool _topEntriesLoading = true;
  String? _topEntriesError;

  final ArcadeProgressStore _arcadeProgressStore = ArcadeProgressStore();
  ArcadeProgressData? _arcadeProgress;
  bool _arcadeProgressLoading = true;

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
  late final Listenable _quickQuizListenable = Listenable.merge([
    OngoingQuickQuizStore.notifier,
    OngoingQuickQuizStore.lastResultNotifier,
    HistoryStore.latestEntryNotifier(),
  ]);

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

    _navItems = const [
      _NavDestination(
        icon: Icons.home_outlined,
        label: 'Accueil',
      ),
      _NavDestination(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
      ),
      _NavDestination(
        icon: Icons.quiz_outlined,
        label: 'Quiz',
      ),
      _NavDestination(
        icon: Icons.history,
        label: 'Historique',
      ),
      _NavDestination(
        icon: Icons.person_outline,
        label: 'Profil',
      ),
      _NavDestination(
        icon: Icons.settings_outlined,
        label: 'Paramètres',
      ),
    ];

    _promoController = PageController(viewportFraction: 1.0);
    _startAutoPlay();
    _startClock();
    unawaited(OngoingQuickQuizStore.load());
    unawaited(HistoryStore.load());
    unawaited(_loadTopEntries());
    unawaited(_loadArcadeProgress());
  }

  Future<void> _loadArcadeProgress() async {
    if (mounted) {
      setState(() {
        _arcadeProgressLoading = true;
      });
    }
    try {
      final progress = await _arcadeProgressStore.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _arcadeProgress = progress;
        _arcadeProgressLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _arcadeProgressLoading = false;
      });
    }
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

  Future<void> _loadTopEntries() async {
    setState(() {
      _topEntriesLoading = true;
      _topEntriesError = null;
    });
    try {
      final entries = await _competitionService.topEntries(limit: 3);
      if (!mounted) {
        return;
      }
      setState(() {
        _topEntries = entries;
        _topEntriesLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _topEntries = const [];
        _topEntriesLoading = false;
        _topEntriesError = "Impossible de récupérer le classement.";
      });
    }
  }

  void _onNavItemSelected(int index) {
    if (_selectedNavIndex == index) {
      return;
    }
    setState(() => _selectedNavIndex = index);
  }

  Future<void> _handleCreateQuickQuiz() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TrainingQuickStartScreen()),
    );
  }

  Future<void> _handleLaunchArcade() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ArcadeModeScreen()),
    );
    if (!mounted) return;
    await _loadArcadeProgress();
  }

  Future<void> _handleLaunchOfficialQuiz() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OfficialIntroScreen()),
    );
  }

  Future<void> _handleLaunchCompetition() async {
    await CompetitionQuizLauncher.launch(context);
  }

  Future<void> _openLeaderboard() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    );
    if (!mounted) return;
    unawaited(_loadTopEntries());
  }

  Future<void> _handleResumeQuickQuiz(OngoingQuickQuizState state) async {
    if (_resumingQuickQuiz) {
      return;
    }
    setState(() => _resumingQuickQuiz = true);
    bool dialogShown = false;
    void closeDialog() {
      if (!dialogShown) return;
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
      final completedAt = DateTime.now();
      if (result != null) {
        await OngoingQuickQuizStore.saveLastResult(
          QuickQuizSummary(
            title: state.title,
            completedAt: completedAt,
            correctAnswers: result.correctCount,
            totalQuestions: result.total,
          ),
        );
      } else {
        await OngoingQuickQuizStore.clearLastResult();
      }
      await OngoingQuickQuizStore.clear();

      if (!mounted) return;
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
            floatingActionButton:
                _selectedNavIndex == 0 ? _buildMainFab() : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: _buildBottomAppBar(),
            body: _buildShellBody(
              backgroundColor: bgColor,
              surfaceColor: Theme.of(context).scaffoldBackgroundColor,
              topInset: topInset,
              hasName: hasName,
              name: name,
              welcomeFontSize: welcomeFontSize,
              nameFontSize: nameFontSize,
              sections: sections,
              scale: scale,
              panelHeightFactor: UI.panelHeightFactor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildShellBody({
    required Color backgroundColor,
    required Color surfaceColor,
    required double topInset,
    required bool hasName,
    required String? name,
    required double welcomeFontSize,
    required double nameFontSize,
    required List<CategoryDefinition> sections,
    required double scale,
    required double panelHeightFactor,
  }) {
    final tabChildren = <Widget>[
      KeyedSubtree(
        key: const ValueKey('home_tab'),
        child: _buildHomeTab(
          backgroundColor: backgroundColor,
          topInset: topInset,
          hasName: hasName,
          name: name,
          welcomeFontSize: welcomeFontSize,
          nameFontSize: nameFontSize,
          sections: sections,
          scale: scale,
          panelHeightFactor: panelHeightFactor,
        ),
      ),
      _buildSurfaceTab(
        key: const ValueKey('dashboard_tab'),
        backgroundColor: surfaceColor,
        child: const DashboardScreen(
          key: PageStorageKey<String>('dashboard_tab'),
        ),
      ),
      _buildSurfaceTab(
        key: const ValueKey('subjects_tab'),
        backgroundColor: surfaceColor,
        child: const SubjectListScreen(
          key: PageStorageKey<String>('subject_list_tab'),
        ),
      ),
      _buildSurfaceTab(
        key: const ValueKey('history_tab'),
        backgroundColor: surfaceColor,
        child: const ExamHistoryScreen(
          key: PageStorageKey<String>('history_tab'),
        ),
      ),
      _buildSurfaceTab(
        key: const ValueKey('profile_tab'),
        backgroundColor: surfaceColor,
        child: const ProfileEditScreen(
          key: PageStorageKey<String>('profile_tab'),
        ),
      ),
      _buildSurfaceTab(
        key: const ValueKey('design_tab'),
        backgroundColor: surfaceColor,
        child: const DesignSettingsScreen(
          key: PageStorageKey<String>('design_tab'),
        ),
      ),
    ];

    return IndexedStack(
      index: _selectedNavIndex,
      children: tabChildren,
    );
  }

  Widget _buildHomeTab({
    required Color backgroundColor,
    required double topInset,
    required bool hasName,
    required String? name,
    required double welcomeFontSize,
    required double nameFontSize,
    required List<CategoryDefinition> sections,
    required double scale,
    required double panelHeightFactor,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            image: DecorationImage(image: _screenBg, fit: BoxFit.cover),
          ),
        ),
        _buildHeader(
          topInset: topInset,
          hasName: hasName,
          name: name,
          welcomeFontSize: welcomeFontSize,
          nameFontSize: nameFontSize,
          arcadeProgress: _arcadeProgress,
          arcadeProgressLoading: _arcadeProgressLoading,
        ),
        _buildSections(
          sections: sections,
          scale: scale,
          panelHeightFactor: panelHeightFactor,
        ),
      ],
    );
  }

  Widget _buildSurfaceTab({
    required Key key,
    required Color backgroundColor,
    required Widget child,
  }) {
    return KeyedSubtree(
      key: key,
      child: ColoredBox(
        color: backgroundColor,
        child: child,
      ),
    );
  }

  /// NAV BAR
  Widget _buildBottomAppBar() {
    final buttons = <Widget>[];

    final notchIndex = (_navItems.length / 2).floor();
    for (var i = 0; i < _navItems.length; i++) {
      if (i == notchIndex) {
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
      child: Semantics(
        label: item.label,
        selected: isSelected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            message: item.label,
            child: InkWell(
              onTap: () => _onNavItemSelected(index),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? _bottomBarHighlight : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(item.icon, color: foreground, size: 24),
              ),
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
    required ArcadeProgressData? arcadeProgress,
    required bool arcadeProgressLoading,
  }) {
    final displayName = hasName && (name?.trim().isNotEmpty ?? false)
        ? name!.trim()
        : 'Utilisateur';
    final avatarLabel = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : '?';

    return ValueListenableBuilder<DateTime>(
      valueListenable: _now,
      builder: (_, now, __) {
        final greeting = now.hour < 18 ? 'Bonjour' : 'Bonsoir';
        final icon = (now.hour >= 6 && now.hour < 18)
            ? Icons.wb_sunny_rounded
            : Icons.nights_stay_rounded;
        final formattedDate = _formatDateTime(now);

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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        greeting,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: welcomeFontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (arcadeProgressLoading)
                            const SizedBox(
                              height: 28,
                              width: 28,
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          else if (arcadeProgress != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ArcadeBadgeChip(
                                label: arcadeProgress.levelLabel,
                                compact: true,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
      },
    );
  }

  /// BOX BLANCHE + BACKGROUND_Playscreen2 + CONTENU SCROLLABLE
  Widget _buildSections({
    required List<CategoryDefinition> sections,
    required double scale,
    required double panelHeightFactor,
  }) {
    final liveQuizItems = <_LiveQuizItem>[
      _LiveQuizItem(
        icon: Icons.flash_on_rounded,
        iconColor: const Color(0xFF7C4DFF),
        title: 'Quiz rapide',
        subtitle: 'Démarre un entraînement instantané',
        onTap: _handleCreateQuickQuiz,
      ),
      _LiveQuizItem(
        icon: Icons.videogame_asset_rounded,
        iconColor: const Color(0xFF4E8FFF),
        title: 'Mode arcade',
        subtitle: 'Grimpe les paliers de difficulté',
        onTap: _handleLaunchArcade,
      ),
      _LiveQuizItem(
        icon: Icons.people_alt_rounded,
        iconColor: const Color(0xFF5336C6),
        title: 'Défi compétition',
        subtitle: '60 questions pour grimper au classement',
        onTap: _handleLaunchCompetition,
      ),
      _LiveQuizItem(
        icon: Icons.workspace_premium_rounded,
        iconColor: const Color(0xFF9C6BFF),
        title: 'Simulation officielle',
        subtitle: 'Sujet d’entraînement en conditions réelles',
        onTap: _handleLaunchOfficialQuiz,
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
                                  duration: const Duration(milliseconds: 450),
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
                          child: AnimatedBuilder(
                            animation: _quickQuizListenable,
                            builder: (_, __) {
                              final state = OngoingQuickQuizStore.notifier.value;
                              final summary =
                                  OngoingQuickQuizStore.lastResultNotifier.value;
                              final lastExam =
                                  HistoryStore.latestEntryNotifier().value;
                              final ongoing = (state != null &&
                                      state.questionIds.isNotEmpty)
                                  ? state
                                  : null;
                              final bool showQuickQuiz =
                                  summary != null || lastExam == null;
                              return _RecentQuizCard(
                                ongoingState: ongoing,
                                lastSummary: summary,
                                lastExamEntry: lastExam,
                                onContinue: ongoing != null
                                    ? () => _handleResumeQuickQuiz(ongoing)
                                    : null,
                                onLaunchQuickQuiz: ongoing == null && showQuickQuiz
                                    ? _handleCreateQuickQuiz
                                    : null,
                                onLaunchOfficialExam:
                                    ongoing == null && !showQuickQuiz
                                        ? _handleLaunchOfficialQuiz
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
                          child: _LeaderboardHighlightCard(
                            entries: _topEntries,
                            isLoading: _topEntriesLoading,
                            error: _topEntriesError,
                            onSeeAll: _openLeaderboard,
                          ),
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
    required this.ongoingState,
    required this.lastSummary,
    required this.lastExamEntry,
    required this.onContinue,
    required this.onLaunchQuickQuiz,
    required this.onLaunchOfficialExam,
    required this.isBusy,
  });

  final OngoingQuickQuizState? ongoingState;
  final QuickQuizSummary? lastSummary;
  final ExamHistoryEntry? lastExamEntry;
  final VoidCallback? onContinue;
  final VoidCallback? onLaunchQuickQuiz;
  final VoidCallback? onLaunchOfficialExam;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final hasQuiz = ongoingState != null && ongoingState!.questionIds.isNotEmpty;
    final bool showResume = hasQuiz && onContinue != null;
    final summary = lastSummary;
    final examEntry = lastExamEntry;
    final double? examRatio = examEntry?.overallSuccessRatio();
    final bool showExamResult = !hasQuiz && summary == null && examEntry != null;
    final bool showQuickLaunch =
        !hasQuiz && !showExamResult && onLaunchQuickQuiz != null;
    final bool showOfficialLaunch =
        !hasQuiz && showExamResult && onLaunchOfficialExam != null;
    final bool showLaunch = showQuickLaunch || showOfficialLaunch;
    final double rawProgress = hasQuiz
        ? ongoingState!.completionRatio
        : summary != null
            ? summary.completionRatio
            : (examRatio ?? 0.0);
    final double clampedProgress = rawProgress.clamp(0.0, 1.0);
    final int percentValue = (clampedProgress * 100).round();
    final String subtitle;
    if (hasQuiz) {
      final rawTitle = ongoingState!.title.trim();
      subtitle = rawTitle.isNotEmpty
          ? 'Vous étiez sur « $rawTitle »'
          : 'Vous étiez sur votre quiz rapide en cours.';
    } else if (summary != null) {
      final rawTitle = summary.title?.trim();
      subtitle = (rawTitle != null && rawTitle.isNotEmpty)
          ? 'Dernier quiz rapide : $rawTitle'
          : 'Commencez un quiz rapide pour vous entraîner.';
    } else if (showExamResult && examEntry != null) {
      final localization = MaterialLocalizations.of(context);
      final formattedDate = localization.formatMediumDate(examEntry.date);
      subtitle = 'Dernière simulation ENA : $formattedDate';
    } else {
      subtitle = 'Commencez un quiz rapide pour vous entraîner.';
    }
    final String progressLabel;
    if (hasQuiz) {
      progressLabel = '$percentValue % complété';
    } else if (summary != null) {
      progressLabel =
          'Dernier score : $percentValue % – ${summary.correctAnswers}/${summary.totalQuestions}';
    } else if (showExamResult) {
      progressLabel = examRatio != null
          ? 'Dernière simulation ENA : $percentValue % de réussite'
          : 'Dernière simulation ENA : données indisponibles';
    } else {
      progressLabel = 'Aucun quiz en cours';
    }
    final String titleText = hasQuiz ? 'Reprendre le quiz' : 'Quiz rapide ENA';
    final bool hasHistory = summary != null || showExamResult;
    final String buttonLabel = showResume
        ? 'Reprendre'
        : hasHistory
            ? 'Relancer'
            : 'Lancer';
    final bool showButton = showResume || showLaunch;
    final bool enableResume = showResume && !isBusy;
    final VoidCallback? launchHandler = showExamResult
        ? onLaunchOfficialExam
        : onLaunchQuickQuiz;
    final mainAxisAlignment =
        showButton ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start;

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
            titleText,
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
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Expanded(
                child: Text(
                  progressLabel,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (showButton)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4315C5),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: showResume
                        ? (enableResume ? onContinue : null)
                        : launchHandler,
                    child: showResume && isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            buttonLabel,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardHighlightCard extends StatelessWidget {
  const _LeaderboardHighlightCard({
    required this.entries,
    required this.isLoading,
    required this.error,
    required this.onSeeAll,
  });

  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? error;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget body;
    if (isLoading) {
      body = Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chargement du classement...',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F5A78),
                  ),
            ),
          ),
        ],
      );
    } else if (error != null) {
      body = Text(
        error!,
        style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5F5A78),
            ),
      );
    } else if (entries.isEmpty) {
      body = Text(
        'Aucun score pour le moment. Sois le premier à entrer dans le classement !',
        style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5F5A78),
            ),
      );
    } else {
      body = Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _LeaderboardEntryRow(entry: entries[i], rank: i + 1),
          ],
        ],
      );
    }

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
              Icons.emoji_events_rounded,
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
                  'Top du classement',
                  style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF2D1B5E),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                body,
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
                    onPressed: onSeeAll,
                    child: const Text(
                      'Voir tout le classement',
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

class _LeaderboardEntryRow extends StatelessWidget {
  const _LeaderboardEntryRow({required this.entry, required this.rank});

  final LeaderboardEntry entry;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = entry.name.trim().isEmpty ? 'Anonyme' : entry.name.trim();
    final percentText = _formatPercent(entry.percent);
    final durationText = _formatDuration(entry.durationSec);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$rank.',
          style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2D1B5E),
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            displayName.characters.take(28).toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2D1B5E),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 72,
          child: Text(
            '$percentText%',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4315C5),
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 86,
          child: Text(
            durationText,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5F5A78),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  String _formatPercent(double value) {
    final decimals = value == value.roundToDouble() ? 0 : 1;
    return value.toStringAsFixed(decimals);
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) {
      return '0s';
    }
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${secs.toString().padLeft(2, '0')}s';
    }
    return '${secs}s';
  }
}

class _LiveQuizList extends StatefulWidget {
  const _LiveQuizList({required this.items});

  final List<_LiveQuizItem> items;

  @override
  State<_LiveQuizList> createState() => _LiveQuizListState();
}

class _LiveQuizListState extends State<_LiveQuizList> {
  int? _loadingIndex;

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
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE8E6F3),
        ),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isLoading = _loadingIndex == index;
          final hasAction = item.onTap != null;
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
            trailing: isLoading
                ? SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(item.iconColor),
                    ),
                  )
                : const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF7C4DFF),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            enabled: hasAction && !isLoading,
            onTap: hasAction
                ? () async {
                    if (_loadingIndex != null) return;
                    setState(() => _loadingIndex = index);
                    try {
                      await item.onTap?.call();
                    } finally {
                      if (mounted) {
                        setState(() => _loadingIndex = null);
                      }
                    }
                  }
                : null,
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
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Future<void> Function()? onTap;
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

  const _NavDestination({
    required this.icon,
    required this.label,
  });
}
