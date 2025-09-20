import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';

/// Widget that paints the dynamic gradient background and optional wave effect
/// based on [DesignConfig]. It listens to [DesignBus] for live updates so that
/// theme changes from the design settings propagate to all pages.
class DesignBackground extends StatelessWidget {
  const DesignBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final baseColors =
            pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode);

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: cfg.bgGradient
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: baseColors,
                  )
                : null,
            color: cfg.bgGradient ? null : baseColors.first,
            image: const DecorationImage(
              image:
                  AssetImage('assets/images/background_playscreen.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              if (cfg.waveEnabled)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.0, -0.6),
                          radius: 1.0,
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              child,
            ],
          ),
        );
      },
    );
  }

  // Palette resolution moved to palette_utils.dart
}

