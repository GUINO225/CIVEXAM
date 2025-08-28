import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'midnight':
      // Soft steel blue toward deep navy
      return const [Color(0xFFB0C4DE), Color(0xFF2C5364)];
    case 'forest':
      // Gentle green center fading to dark forest edge
      return const [Color(0xFFDDEED7), Color(0xFF2F7336)];
    case 'ocean':
      // Pale aqua center to deep ocean blue
      return const [Color(0xFFD7F2F3), Color(0xFF1A2980)];
    case 'purple':
      // Light lavender center to rich purple edge
      return const [Color(0xFFE6DAF5), Color(0xFF2A0845)];
    case 'lavender':
      // Almost white lavender to muted periwinkle
      return const [Color(0xFFF2ECFF), Color(0xFF8CA6DB)];
    case 'steel':
      // Soft grey center to charcoal edge
      return const [Color(0xFFE5E7EA), Color(0xFF414345)];
    case 'coffee':
      // Creamy center to dark coffee edge
      return const [Color(0xFFEAD7C4), Color(0xFF603813)];
    case 'blueRoyal':
    default:
      // Subtle light blue center to royal blue edge
      return const [Color(0xFFE1E6F2), Color(0xFF0D1E42)];
  }
}

/// Returns [Colors.white] or [Colors.black] depending on the average
/// brightness of the palette.
Color textColorForPalette(String name) {
  final colors = paletteFromName(name);
  // Average the palette colors
  int r = 0, g = 0, b = 0;
  for (final c in colors) {
    r += c.red;
    g += c.green;
    b += c.blue;
  }
  final avg = Color.fromARGB(255, r ~/ colors.length, g ~/ colors.length, b ~/ colors.length);
  final brightness = ThemeData.estimateBrightnessForColor(avg);
  return brightness == Brightness.dark ? Colors.white : Colors.black;
}
