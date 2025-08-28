import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';

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
        final colors = _paletteFromName(cfg.bgPaletteName);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
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

  List<Color> _paletteFromName(String name) {
    switch (name) {
      case 'blueAqua':
        return const [Color(0xFF3A4CC5), Color(0xFF6C8BF5)];
      case 'midnight':
        return const [Color(0xFF0F2027), Color(0xFF2C5364)];
      case 'sunset':
        return const [Color(0xFFFF5E62), Color(0xFFFF9966)];
      case 'forest':
        return const [Color(0xFF2F7336), Color(0xFFAAFFA9)];
      case 'ocean':
        return const [Color(0xFF1A2980), Color(0xFF26D0CE)];
      case 'fire':
        return const [Color(0xFFFF512F), Color(0xFFF09819)];
      case 'purple':
        return const [Color(0xFF2A0845), Color(0xFF6441A5)];
      case 'pink':
        return const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)];
      case 'emerald':
        return const [Color(0xFF00B09B), Color(0xFF96C93D)];
      case 'candy':
        return const [Color(0xFFF857A6), Color(0xFFFF5858)];
      case 'steel':
        return const [Color(0xFF232526), Color(0xFF414345)];
      case 'coffee':
        return const [Color(0xFF603813), Color(0xFFB29F94)];
      case 'gold':
        return const [Color(0xFFF6D365), Color(0xFFFDA085)];
      case 'lavender':
        return const [Color(0xFFB993D6), Color(0xFF8CA6DB)];
      case 'blueRoyal':
      default:
        return const [Color(0xFF0D1E42), Color(0xFF37478F)];
    }
  }
}

