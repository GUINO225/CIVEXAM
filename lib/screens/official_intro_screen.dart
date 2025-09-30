import 'dart:async';
import 'package:flutter/material.dart';
import '../services/scoring.dart';
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

class _OfficialIntroScreenState extends State<OfficialIntroScreen> with SingleTickerProviderStateMixin {
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
        final textTheme = theme.textTheme;
        final mediaQuery = MediaQuery.of(context);
        final scale = computeScaleFactor(mediaQuery);
        final textScaler = MediaQuery.textScalerOf(context);
        final Color playPurple = PlayBottomNavBar.defaultBackgroundColor;
        final Color backdropColor = darken(playPurple, 0.08);
        final Color textOnPurple = Colors.white.withOpacity(0.92);
        final Color secondaryText = Colors.white.withOpacity(0.78);
        final Color cardColor = Colors.white.withOpacity(0.12);
        final double introTitleSize = scaledFontSize(
          base: 18,
          scale: scale,
          textScaler: textScaler,
          min: 16,
          max: 24,
        );
        final double countdownFontSize = scaledFontSize(
          base: 96,
          scale: scale,
          textScaler: textScaler,
          min: 72,
          max: 132,
        );
        final bodyStyle =
            textTheme.bodyLarge ?? textTheme.bodyMedium ?? const TextStyle(fontSize: 16);
        final double bodyFontSize = bodyStyle.fontSize ?? 16;
        final baseCardTitleStyle =
            textTheme.titleMedium ?? textTheme.titleLarge ?? bodyStyle;
        final double cardTitleFontSize = (baseCardTitleStyle.fontSize != null &&
                baseCardTitleStyle.fontSize! > bodyFontSize)
            ? baseCardTitleStyle.fontSize!
            : bodyFontSize + 2;
        final cardTitleStyle = baseCardTitleStyle.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: cardTitleFontSize,
          color: Colors.white,
        );
        final introTitleStyle =
            (textTheme.titleLarge ?? textTheme.headlineSmall ?? baseCardTitleStyle)
                .copyWith(
          fontSize: introTitleSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
        final bodyTextStyle = bodyStyle.copyWith(
          color: textOnPurple,
          height: 1.45,
        );
        final subduedTextStyle = bodyTextStyle.copyWith(color: secondaryText);
        final checkboxSide = BorderSide(color: Colors.white.withOpacity(0.7));

        return Scaffold(
          extendBody: true,
          backgroundColor: backdropColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            title: const Text('Concours officiel — Consignes'),
          ),
          bottomNavigationBar: PlayBottomNavBar(
            destinations: playNavDestinations,
            selectedIndex: 2,
            onDestinationSelected: (index) {
              if (index == 2) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayScreen(initialIndex: index),
                ),
              );
            },
          ),
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    color: PlayBottomNavBar.defaultBackgroundColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 140, 16, 120),
                  children: [
                    Text(
                      'Simulation du concours ENA (pré‑sélection)',
                      style: introTitleStyle,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vous allez enchaîner 4 épreuves :\n'
                      '1) Culture Générale (Côte d’Ivoire)\n'
                      '2) Aptitude Verbale (Vocabulaire & règles)\n'
                      '3) Organisation & Logique (Classements & déductions)\n'
                      '4) Aptitude Numérique (Bases & proportionnalité)\n',
                      style: bodyTextStyle,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: cardColor,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Durée & barème', style: cardTitleStyle),
                            const SizedBox(height: 8),
                            Text(
                              '• Durée : 60 minutes par épreuve (total ~4h).',
                              style: bodyTextStyle,
                            ),
                            Text(
                              '• Barème : +1 bonne, 0 blanc, −1 mauvaise (barème négatif).',
                              style: bodyTextStyle,
                            ),
                            Text(
                              '• Coefficient : ×2 par épreuve (pondération finale).',
                              style: bodyTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: cardColor,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Règles', style: cardTitleStyle),
                            const SizedBox(height: 8),
                            Text(
                              '• Une fois le chrono lancé, vous ne pouvez pas revenir en arrière.',
                              style: bodyTextStyle,
                            ),
                            Text(
                              '• À la fin du temps, l’épreuve est automatiquement soumise.',
                              style: bodyTextStyle,
                            ),
                            Text(
                              '• Évitez de quitter l’app pendant une épreuve.',
                              style: bodyTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _accepted,
                          onChanged: (v) => setState(() => _accepted = v ?? false),
                          activeColor: Colors.white,
                          checkColor: playPurple,
                          side: checkboxSide,
                          fillColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.white;
                            }
                            return Colors.white.withOpacity(0.2);
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _accepted && !_starting ? _startCountdown : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: playPurple,
                          minimumSize: const Size.fromHeight(52),
                          textStyle: bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: bodyFontSize + 2,
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
