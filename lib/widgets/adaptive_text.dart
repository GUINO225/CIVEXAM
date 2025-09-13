import 'package:flutter/material.dart';
import '../utils/palette_utils.dart';

/// Text widget that automatically chooses a readable color based on the
/// provided [backgroundColor].
class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
    this.data, {
    super.key,
    required this.backgroundColor,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final Color backgroundColor;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final color = onColor(backgroundColor);
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: (style ?? const TextStyle()).copyWith(color: color),
    );
  }
}
