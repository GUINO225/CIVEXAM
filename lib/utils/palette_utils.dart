import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'fireOcean':
      return const [Color(0xFF003049), Color(0xFF669BBC)];
    case 'refreshingSummer':
      return const [Color(0xFF219EBC), Color(0xFF8ECAE6)];
    case 'oliveGardenFeast':
      return const [Color(0xFF283618), Color(0xFF606C38)];
    case 'oceanBleuSerenity':
      return const [Color(0xFF0096C7), Color(0xFF00B4D8)];
    case 'oceanBreeze':
      return const [Color(0xFF90E0EF), Color(0xFFCAF0F8)];
    case 'softSand':
      return const [Color(0xFFEDEDE9), Color(0xFFF5EBE0)];
    case 'beachSunset':
      return const [Color(0xFF5FA8D3), Color(0xFF62B6CB)];
    case 'slateGrayContrast':
      return const [Color(0xFFC0C0C0), Color(0xFFEBEBEB)];
    default:
      // Fallback to the chosen minimal contrast pair
      return const [Color(0xFF5FA8D3), Color(0xFF62B6CB)];
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
