// lib/screens/official_intro_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';
import '../utils/responsive_utils.dart';
import '../widgets/play_bottom_nav_bar.dart';
import 'multi_exam_flow.dart';
import 'play_screen.dart';

class OfficialIntroScreen extends StatefulWidget {
  const OfficialIntroScreen({super.key});

  @override
  State<OfficialIntroScreen> createState() => _OfficialIntroScreenState();
}

class _OfficialIntroScreenState extends State<OfficialIntroScreen> {
  bool _accepted = false;
  bool _starting = false;
  int _count = 3;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _starting = true;
      _count = 3;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_count <= 1) {
        t.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MultiExamFlowScreen()),
        );
      } else {
        setState(() => _count--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final textTheme = theme.textTheme;
        final mq = MediaQuery.of(context);
        final scale = computeScaleFactor(mq);
        final textScaler = MediaQuery.textScalerOf(context);

        // Palette / surfaces
        final palette = playIconColors(cfg.bgPaletteName);
        final Color brand =
            palette.isNotEmpty ? palette.last : const Color(0xFF6C4DFF);
        final Color onBrand = ThemeData.estimateBrightnessForColor(brand) ==
                Brightness.dark
            ? Colors.white
            : Colors.black;
        final Color navHighlight =
            Color.alphaBlend(onBrand.withOpacity(0.14), brand);
        final Color pageBg = scheme.brightness == Brightness.dark
            ? const Color(0xFF111318)
            : const Color(0xFFF7F8FA);
        final Color onPage = scheme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.92)
            : const Color(0xFF1B1B1F);
        final Color secondaryText = scheme.brightness == Brightness.dark
            ? Colors.white70
            : const Color(0xFF44474F);
        final Color cardColor = scheme.brightness == Brightness.dark
            ? const Color(0xFF1F1F22)
            : Colors.white;

        // Typography
        final double introTitleSize = scaledFontSize(
          base: 20, scale: scale, textScaler: textScaler, min: 18, max: 26,
        );
        final double sectionTitleSize = scaledFontSize(
          base: 18, scale: scale, textScaler: textScaler, min: 16, max: 22,
        );
        final bodyStyle =
            textTheme.bodyLarge ?? textTheme.bodyMedium ?? const TextStyle(fontSize: 16);
        final bodyTextStyle = bodyStyle.copyWith(color: onPage, height: 1.45);
        final subduedTextStyle = bodyTextStyle.copyWith(color: secondaryText);
        final double countdownFontSize = scaledFontSize(
          base: 96, scale: scale, textScaler: textScaler, min: 72, max: 132,
        );

        // Style helpers
        RoundedRectangleBorder r24() => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        );

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: pageBg,

          // AppBar invisible: juste pour forcer la status bar violette & icônes claires
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: brand,
              statusBarIconBrightness:
                  ThemeData.estimateBrightnessForColor(brand) ==
                          Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
              statusBarBrightness:
                  ThemeData.estimateBrightnessForColor(brand) ==
                          Brightness.dark
                      ? Brightness.dark
                      : Brightness.light,
            ),
          ),

          bottomNavigationBar: PlayBottomNavBar(
            destinations: playNavDestinations,
            selectedIndex: 2,
            onDestinationSelected: (index) {
              if (index == 2) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PlayScreen(initialIndex: index)),
              );
            },
            backgroundColor: brand,
            highlightColor: navHighlight,
            foregroundColor: onBrand,
          ),

          body: Stack(
            children: [
              // Languette violette = pile la hauteur de l'encoche
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(height: mq.padding.top, color: brand),
              ),

              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    // ===== HERO CARD (inspirée "Top Picks") =====
                    _HeroIntroCard(
                      brand: brand,
                      onBrand: onBrand,
                      titleStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: introTitleSize,
                        color: onBrand,
                        letterSpacing: .2,
                      ),
                      bodyStyle: bodyTextStyle.copyWith(color: onBrand.withOpacity(0.92)),
                    ),

                    const SizedBox(height: 20),

                    // ===== SECTION: Top Rank (style puce + avatar) =====
                    Text('Rappel important', // style de sous-titre "Top Rank of the week"
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: sectionTitleSize,
                          color: onPage,
                        )),
                    const SizedBox(height: 10),
                    _BadgeRowCard(
                      icon: Icons.timer,
                      labelPrimary: 'Durée',
                      labelSecondary: '60 min/épreuve · total ~4h',
                      brand: brand,
                      onPage: onPage,
                      cardColor: cardColor,
                      shape: r24(),
                    ),
                    const SizedBox(height: 10),
                    _BadgeRowCard(
                      icon: Icons.rule,
                      labelPrimary: 'Barème',
                      labelSecondary: '+1 bonne · 0 blanc · −1 mauvaise',
                      brand: brand,
                      onPage: onPage,
                      cardColor: cardColor,
                      shape: r24(),
                    ),
                    const SizedBox(height: 10),
                    _BadgeRowCard(
                      icon: Icons.calculate,
                      labelPrimary: 'Coefficient',
                      labelSecondary: '×2 par épreuve',
                      brand: brand,
                      onPage: onPage,
                      cardColor: cardColor,
                      shape: r24(),
                    ),

                    const SizedBox(height: 22),

                    // ===== SECTION: Règles (tuiles arrondies façon "Categories") =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Règles',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: sectionTitleSize,
                              color: onPage,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _CategoryTile(
                          brand: brand,
                          icon: Icons.block,
                          title: 'Pas de retour en arrière',
                          subtitle: 'Une fois le chrono lancé',
                        ),
                        _CategoryTile(
                          brand: brand,
                          icon: Icons.schedule_send,
                          title: 'Soumission auto',
                          subtitle: 'À la fin du temps',
                        ),
                        _CategoryTile(
                          brand: brand,
                          icon: Icons.phone_iphone,
                          title: 'Rester dans l’app',
                          subtitle: 'Éviter de quitter',
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ===== Accept & CTA =====
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _accepted,
                          onChanged: (v) => setState(() => _accepted = v ?? false),
                          activeColor: brand,
                          checkColor: onBrand,
                          side: BorderSide(color: onPage.withOpacity(0.5)),
                          fillColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) return brand;
                            return onPage.withOpacity(0.06);
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Je comprends les règles et je suis prêt(e) à commencer.',
                            style: subduedTextStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _accepted && !_starting ? _startCountdown : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: onBrand,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: (bodyTextStyle.fontSize ?? 16) + 2,
                          ),
                        ),
                        icon: const Icon(Icons.flag),
                        label: const Text('Démarrer la simulation officielle'),
                      ),
                    ),
                  ],
                ),
              ),

              if (_starting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        '$_count',
                        style: TextStyle(
                          fontSize: countdownFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// === Composants inspirés du design fourni ===

class _HeroIntroCard extends StatelessWidget {
  final Color brand;
  final Color onBrand;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  const _HeroIntroCard({
    required this.brand,
    required this.onBrand,
    required this.titleStyle,
    required this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: brand,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Puce "Top Picks" style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: onBrand.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Prépa officielle',
              style: TextStyle(color: onBrand, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Text('Concours officiel — Consignes', style: titleStyle),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.add_circle, size: 18, color: onBrand),
              const SizedBox(width: 8),
              Text('4 épreuves • ENA Côte d’Ivoire', style: bodyStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeRowCard extends StatelessWidget {
  final IconData icon;
  final String labelPrimary;
  final String labelSecondary;
  final Color brand;
  final Color onPage;
  final Color cardColor;
  final ShapeBorder shape;

  const _BadgeRowCard({
    required this.icon,
    required this.labelPrimary,
    required this.labelSecondary,
    required this.brand,
    required this.onPage,
    required this.cardColor,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: shape,
      shadowColor: Colors.black.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: brand.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labelPrimary, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: onPage)),
                  const SizedBox(height: 2),
                  Text(labelSecondary, style: TextStyle(color: onPage.withOpacity(0.7))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: brand.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.check, size: 16, color: brand),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Color brand;
  final IconData icon;
  final String title;
  final String subtitle;

  const _CategoryTile({
    required this.brand,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = scheme.brightness == Brightness.dark;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2, // 2 colonnes
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: brand.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: brand, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
