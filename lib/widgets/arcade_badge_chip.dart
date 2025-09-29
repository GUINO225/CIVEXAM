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
    return Chip(
      avatar: Icon(Icons.stars, size: iconSize, color: foreground),
      label: Text(label, style: textStyle),
      backgroundColor: background,
      side: BorderSide(color: colorScheme.primary.withOpacity(0.4)),
      padding: padding,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    );
  }
}
