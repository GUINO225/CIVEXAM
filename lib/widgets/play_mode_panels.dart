import 'package:flutter/material.dart';

import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';

class PlayPanelSurface extends StatelessWidget {
  const PlayPanelSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 26,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final palette = pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode);
        final start = Color.lerp(
          palette.first,
          cfg.darkMode ? Colors.black : Colors.white,
          cfg.darkMode ? 0.05 : 0.45,
        );
        final end = Color.lerp(
          palette.length > 1 ? palette.last : palette.first,
          cfg.darkMode ? Colors.black : Colors.white,
          cfg.darkMode ? 0.08 : 0.6,
        );
        final resolvedShadow = boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(cfg.darkMode ? 0.2 : 0.08),
                blurRadius: cfg.darkMode ? 18 : 24,
                offset: const Offset(0, 10),
              ),
            ];

        return Container(
          margin: margin,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [start ?? palette.first, end ?? palette.last],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: resolvedShadow,
          ),
          child: child,
        );
      },
    );
  }
}

class PlayInfoChip extends StatelessWidget {
  const PlayInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final palette = pastelColors(cfg.bgPaletteName, darkMode: cfg.darkMode);
        final baseColor = color ?? palette.last;
        final background = Color.lerp(
          baseColor,
          cfg.darkMode ? Colors.black : Colors.white,
          cfg.darkMode ? 0.65 : 0.85,
        )!;
        final borderColor = baseColor.withOpacity(cfg.darkMode ? 0.35 : 0.28);
        final brightness = ThemeData.estimateBrightnessForColor(background);
        final foreground =
            brightness == Brightness.dark ? Colors.white : theme.colorScheme.onSurface;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 16 : 18, color: baseColor.darken(0.1)),
              SizedBox(width: compact ? 6 : 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

class PlayCountdownChip extends StatelessWidget {
  const PlayCountdownChip({
    super.key,
    required this.label,
    this.icon = Icons.timer_outlined,
    this.completed = false,
  });

  final String label;
  final IconData icon;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color? chipColor = completed
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    return PlayInfoChip(
      icon: icon,
      label: label,
      color: chipColor,
    );
  }
}

class PlayPrimaryButton extends StatelessWidget {
  const PlayPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final colors = playIconColors(cfg.bgPaletteName);
        final background = colors.first;
        final brightness = ThemeData.estimateBrightnessForColor(background);
        final foreground =
            brightness == Brightness.dark ? Colors.white : Colors.black87;
        final button = icon != null
            ? FilledButton.icon(
                icon: busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(foreground),
                        ),
                      )
                    : Icon(icon, size: 20),
                label: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: background,
                  foregroundColor: foreground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: busy ? null : onPressed,
              )
            : FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: background,
                  foregroundColor: foreground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: busy ? null : onPressed,
                child: busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(foreground),
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
              );
        return SizedBox(width: double.infinity, child: button);
      },
    );
  }
}

class PlayPanelHeader extends StatelessWidget {
  const PlayPanelHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.description,
    this.chips = const <Widget>[],
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? description;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PlayPanelSurface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 16),
            Text(
              description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }
}
