import 'dart:async';

import 'package:flutter/material.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/responsive_utils.dart';
import '../widgets/play_mode_panels.dart';
import '../widgets/play_themed_scaffold.dart';
import 'multi_exam_flow.dart';

class OfficialIntroScreen extends StatefulWidget {
  const OfficialIntroScreen({super.key});

  @override
  State<OfficialIntroScreen> createState() => _OfficialIntroScreenState();
}

class _OfficialIntroScreenState extends State<OfficialIntroScreen>
    with SingleTickerProviderStateMixin {
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
    return PlayThemedScaffold(
      bodyMode: PlayThemedScaffoldBodyMode.panel,
      panelHeightFactor: 0.86,
      safeAreaTop: false,
      body: ValueListenableBuilder<DesignConfig>(
        valueListenable: DesignBus.notifier,
        builder: (context, cfg, _) {
          final theme = Theme.of(context);
          final textTheme = theme.textTheme;
          final overlayTextColor = theme.colorScheme.onSurface;
          final mediaQuery = MediaQuery.of(context);
          final scale = computeScaleFactor(mediaQuery);
          final textScaler = MediaQuery.textScalerOf(context);
          final double countdownFontSize = scaledFontSize(
            base: 96,
            scale: scale,
            textScaler: textScaler,
            min: 72,
            max: 132,
          );
          final bodyStyle =
              textTheme.bodyLarge ?? textTheme.bodyMedium ?? const TextStyle(fontSize: 16);
          final baseCardTitleStyle =
              textTheme.titleMedium ?? textTheme.titleLarge ?? bodyStyle;
          final cardTitleStyle = baseCardTitleStyle.copyWith(
            fontWeight: FontWeight.w700,
          );

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlayPanelHeader(
                      icon: Icons.flag_rounded,
                      title: 'Concours officiel — Consignes',
                      subtitle: 'Simulation du concours ENA (pré‑sélection)',
                      description:
                          'Vous allez enchaîner 4 épreuves chronométrées. Assurez-vous d’être prêt avant de lancer la simulation.',
                      chips: const [
                        PlayInfoChip(
                            icon: Icons.grid_view_rounded, label: '4 épreuves enchaînées'),
                        PlayInfoChip(icon: Icons.timer_rounded, label: '60 min/épreuve'),
                        PlayInfoChip(icon: Icons.gavel_rounded, label: 'Barème négatif'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    PlayPanelSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Durée & barème', style: cardTitleStyle),
                          const SizedBox(height: 12),
                          Text('• Durée : 60 minutes par épreuve (total ~4h).',
                              style: bodyStyle),
                          Text(
                            '• Barème : +1 bonne, 0 blanc, −1 mauvaise (barème négatif).',
                            style: bodyStyle,
                          ),
                          Text(
                            '• Coefficient : ×2 par épreuve (pondération finale).',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    PlayPanelSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Règles', style: cardTitleStyle),
                          const SizedBox(height: 12),
                          Text(
                            '• Une fois le chrono lancé, vous ne pouvez pas revenir en arrière.',
                            style: bodyStyle,
                          ),
                          Text(
                            '• À la fin du temps, l’épreuve est automatiquement soumise.',
                            style: bodyStyle,
                          ),
                          Text(
                            '• Évitez de quitter l’app pendant une épreuve.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    PlayPanelSurface(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _accepted,
                            onChanged: (v) => setState(() => _accepted = v ?? false),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Je comprends les règles et je suis prêt(e) à commencer.',
                              style: bodyStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    PlayPrimaryButton(
                      label: 'Démarrer la simulation officielle',
                      icon: Icons.flag_rounded,
                      onPressed: _accepted && !_starting ? _startCountdown : null,
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
                          color: overlayTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
