import 'package:flutter/material.dart';

class ArcadeBadgeChip extends StatelessWidget {
  final String label;
  final bool compact;

  const ArcadeBadgeChip({super.key, required this.label, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = colorScheme.primaryContainer;
    final foreground = colorScheme.onPrimaryContainer;
    final iconSize = compact ? 16.0 : 18.0;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final textStyle = TextStyle(
      color: foreground,
      fontWeight: FontWeight.w600,
      fontSize: compact ? 12 : null,
    );
    final levelMatch = RegExp(r'\d+').firstMatch(label);
    final hasLevelNumber = levelMatch != null;

    final labelWidget = hasLevelNumber
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, size: iconSize, color: foreground),
              const SizedBox(width: 4),
              Text(levelMatch!.group(0)!, style: textStyle),
            ],
          )
        : Text(label, style: textStyle);

    return Chip(
      label: labelWidget,
      backgroundColor: background,
      side: BorderSide(color: colorScheme.primary.withOpacity(0.4)),
      padding: padding,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    );
  }
}
