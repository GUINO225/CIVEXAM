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
        final colors = paletteFromName(cfg.bgPaletteName);
        final BoxDecoration decoration;
        if (colors.length == 1) {
          decoration = BoxDecoration(color: colors.first);
        } else {
          decoration = BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                // Center is lighter for a soft gradient
                Colors.lerp(colors[0], Colors.white, 0.3)!,
                colors[1],
              ],
            ),
          );
        }
        return DecoratedBox(
          decoration: decoration,
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

