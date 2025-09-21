// lib/screens/play_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/auth_service.dart';
// import '../widgets/glass_tile.dart'; // ❌ plus utilisé
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
/// === CONFIG UI (à éditer facilement) ========================================
/// ****************************************************************************
/// Tout ce qui suit est FAIT pour être modifié sans toucher au reste du code.
/// Les "légendes" expliquent quoi changer.
/// ****************************************************************************

class SectionStyle {
  /// Largeur relative de CHAQUE tuile (ex: 0.25 = 25% de la largeur du carrousel)
  final double itemWidthFraction;

  /// Hauteur FIXE de chaque tuile (en px). Si null, on laissera la hauteur par défaut.
  final double? itemHeight;

  /// Couleur du LISERÉ (bordure extérieure) des tuiles.
  final Color borderColor;

  /// Épaisseur du liseré.
  final double borderWidth;

  /// Rayon d’arrondi des tuiles.
  final double borderRadius;

  /// Couleur de FOND des tuiles.
  final Color tileBackgroundColor;

  /// Style du texte (TITRE DE SECTION) affiché au-dessus du carrousel.
  final TextStyle sectionTitleStyle;

  /// Style du titre DANS la tuile.
  final TextStyle? tileTitleTextStyle;

  /// Couleur de l’icône dans la tuile (si null, on déduira depuis la palette).
  final Color? tileIconColor;

  /// Espace horizontal entre 2 tuiles (en px).
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
  /// Fraction de hauteur occupée par le panneau “sections/tuiles” (0.60 = 60%).
  final double panelHeightFactor;

  /// Titre des sections (modifiable ici).
  final String trainingTitle;
  final String historyTitle;
  final String challengeTitle;
  final String helpTitle;

  /// Styles par section (clé -> style).
  /// Clés attendues : 'training', 'history', 'challenge', 'help'
  final Map<String, SectionStyle> sectionStyles;

  /// Espace (px) sous le header “Bienvenue”.
  final double spacingUnderWelcome;

  const PlayUIConfig({
    required this.panelHeightFactor,
    required this.trainingTitle,
    required this.historyTitle,
    required this.challengeTitle,
    required this.helpTitle,
    required this.sectionStyles,
    this.spacingUnderWelcome = 16.0,
  });
}

/// Couleurs utilitaires par défaut
const _blue = Color(0xFF1565C0);
const _red = Color(0xFFFF0000);
const _orange = Color(0xFFEF6C00);
const _cardWhite = Colors.white;
const _titleColor = Color(0xFF1C2430);

/// Légendes rapides :
/// - itemWidthFraction : largeur d’une tuile en % de la zone carrousel (ex: 0.25)
/// - itemHeight       : hauteur d’une tuile en px (ex: 100.0)
/// - borderColor      : couleur du liseré
/// - borderWidth      : épaisseur du liseré
/// - borderRadius     : arrondi des coins
/// - tileBackgroundColor : fond de la tuile
/// - sectionTitleStyle   : style du titre au-dessus du carrousel
/// - tileTitleTextStyle  : style du texte dans la tuile
/// - tileIconColor       : couleur de l’icône (si null, automatique)
/// - tileSpacing         : espace horizontal entre tuiles

final PlayUIConfig UI = PlayUIConfig(
  panelHeightFactor: 0.60, // ← Le panneau des tuiles occupe 60% du bas
  trainingTitle: 'Modes d’entraînement',
  historyTitle: 'Historique & suivi',
  challengeTitle: 'Défis & classement',
  helpTitle: 'Aide & thèmes',

  sectionStyles: {
    // SECTION ENTRAÎNEMENT
    'training': SectionStyle(
      itemWidthFraction: 0.50,
      itemHeight: 150.0,
      borderColor: _blue,
      borderWidth: 1.50,
      borderRadius: 18,
      tileBackgroundColor: _cardWhite,
      sectionTitleStyle: const TextStyle(
        fontSize: 25, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileIconColor: _blue,
      tileSpacing: 12.0,
    ),

    // SECTION HISTORIQUE
    'history': SectionStyle(
      itemWidthFraction: 0.50,
      itemHeight: 200, // mets null pour responsive
      borderColor: _orange,
      borderWidth: 1.25,
      borderRadius: 18,
      tileBackgroundColor: _orange,
      sectionTitleStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 25, fontWeight: FontWeight.w700, color: _cardWhite,
      ),
      tileIconColor: _cardWhite,
      tileSpacing: 12.0,
    ),

    // SECTION DÉFIS
    'challenge': SectionStyle(
      itemWidthFraction: 0.50,
      itemHeight: 250,
      borderColor: _blue,
      borderWidth: 1.25,
      borderRadius: 18,
      tileBackgroundColor: _blue,
      sectionTitleStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: _titleColor,
      ),
      tileTitleTextStyle: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: _cardWhite,
      ),
      tileIconColor: _cardWhite,
      tileSpacing: 12.0,
    ),

    // SECTION AIDE
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
        fontSize: 25, fontWeight: FontWeight.w700, color: _titleColor,
      ),
      tileIconColor: _orange,
      tileSpacing: 12.0,
    ),
  },
);

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

        // ✅ Utilise TextScaler (conforme à ta util)
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

        // Définition des sections et mapping styles
        final sections = <_Section>[
          _Section(
            keyName: 'training',
            title: UI.trainingTitle,
            itemIndexes: const [0, 1], // Simulation ENA, Par matière
          ),
          _Section(
            keyName: 'history',
            title: UI.historyTitle,
            itemIndexes: const [2, 3],
          ),
          _Section(
            keyName: 'challenge',
            title: UI.challengeTitle,
            itemIndexes: const [5, 6],
          ),
          _Section(
            keyName: 'help',
            title: UI.helpTitle,
            itemIndexes: const [4],
          ),
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
                // BACKGROUND ÉCRAN
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: bgColor,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/background_playscreen.png'),
                      fit: BoxFit.cover,
                    ),
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

  /// SECTIONS + CARROUSELS (fond image background_playscreen_2)
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
          child: DecoratedBox(
            decoration: const BoxDecoration(
              // ✅ Image de fond pour la box des tuiles
              image: DecorationImage(
                image: AssetImage('assets/images/background_playscreen_2.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                // "Base" si une section n'a pas d'itemHeight — calcule une hauteur cohérente
                final baseCardHeight =
                (h > 260) ? 200.0 : (h - 80).clamp(150.0, 220.0);

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, si) {
                    final section = sections[si];
                    final style = UI.sectionStyles[section.keyName]!;

                    // Largeur/hauteur d’une tuile selon la config
                    final double itemWidth =
                    (w * style.itemWidthFraction).clamp(80.0, w);
                    final double itemHeight =
                        style.itemHeight ?? baseCardHeight;

                    // viewportFraction = largeur tuile / largeur viewport
                    final double viewportFraction =
                    (itemWidth / w).clamp(0.1, 1.0);
                    final controller =
                    PageController(viewportFraction: viewportFraction);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title, style: style.sectionTitleStyle),
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

                              // Couleur d'icône : config → sinon, on prend une couleur de la palette
                              final paletteColors = playIconColors(item.palette);
                              final iconColor = style.tileIconColor ??
                                  (paletteColors.isNotEmpty
                                      ? paletteColors.last
                                      : textColor);

                              final tile = _TileCard(
                                borderColor: style.borderColor,
                                borderWidth: style.borderWidth,
                                borderRadius: style.borderRadius,
                                backgroundColor: style.tileBackgroundColor,
                                onTap: () => _navigate(context, i), // ← NAVIGATION
                                child: _BasicTile(
                                  title: item.title,
                                  icon: item.icon,
                                  iconSize: scale * 48, // ou cfg.tileIconSize
                                  iconColor: iconColor,
                                  titleStyle: style.tileTitleTextStyle ??
                                      const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _titleColor,
                                      ),
                                ),
                              );

                              // largeur fixe via SizedBox pour respecter itemWidth
                              return Padding(
                                padding: EdgeInsets.only(right: trailing),
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
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// NAVIGATION
  Future<void> _navigate(BuildContext context, int index) async {
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OfficialIntroScreen()));
        break;
      case 1:
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
        await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Comment ça marche ?'),
            content: Text(
              '• Entraînement : 5–10 s par question.\n'
                  '• Concours ENA : difficulté = timing.\n'
                  '• Entraînement par matière : révise par modules.\n'
                  '• Historique : suis tes progrès.',
            ),
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
          if (!proceed) return;

          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          unawaited(
            QuestionHistoryStore.addAll(selected.map((q) => q.id)).catchError(
                  (Object error, _) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content:
                    Text('Échec de l’enregistrement de l’historique des questions.'),
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
      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
        break;
      default:
        assert(false, 'Unexpected index: $index');
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
  final String keyName;         // ← clé de style ('training'/'history'/'challenge'/'help')
  final String title;           // ← texte du titre de section
  final List<int> itemIndexes;  // ← indexes dans _items
  const _Section({
    required this.keyName,
    required this.title,
    required this.itemIndexes,
  });
}

/// Carte “pure” (sans glass), gérée par _TileCard pour bordure/fond.
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
  final VoidCallback? onTap; // ✅ gère le tap (navigation)

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

/// ============================================================================
/// === DONNÉES : tuiles affichées =============================================
/// ============================================================================

class _MenuItem {
  final String title;
  final IconData icon;
  final String palette;
  const _MenuItem(this.title, this.icon, this.palette);
}

/// Astuce : change ici les textes affichés **dans** les tuiles.
const _items = <_MenuItem>[
  _MenuItem('Simulation concours ENA', Icons.school_rounded, 'violetRose'),
  _MenuItem('Entraînement par matière', Icons.menu_book_rounded, 'sereneBlue'),
  _MenuItem('Historique examens', Icons.fact_check_rounded, 'lightGreen'),
  _MenuItem("Historique entraînement", Icons.history_rounded, 'softYellow'),
  _MenuItem('Comment ça marche ?', Icons.info_rounded, 'powderPink'),
  _MenuItem('Compétition', Icons.sports_kabaddi, 'forestGreen'),
  _MenuItem('Classement', Icons.emoji_events_outlined, 'royalViolet'),
];
