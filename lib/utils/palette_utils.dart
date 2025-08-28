import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'midnight':
      // Soft steel blue pair for a gentle gradient
      return const [Color(0xFFB0C4DE), Color(0xFFA5BAD6)];
    case 'forest':
      // Gentle green tones kept very close
      return const [Color(0xFFDDEED7), Color(0xFFD2E3CC)];
    case 'ocean':
      // Pale aqua shades for a subtle sea breeze
      return const [Color(0xFFD7F2F3), Color(0xFFCDE9F0)];
    case 'purple':
      // Light lavender pair
      return const [Color(0xFFE6DAF5), Color(0xFFDCD0EF)];
    case 'lavender':
      // Almost white lavender to muted periwinkle, softened
      return const [Color(0xFFF2ECFF), Color(0xFFE8E1FA)];
    case 'steel':
      // Subtle grey duo
      return const [Color(0xFFE5E7EA), Color(0xFFDADCE0)];
    case 'coffee':
      // Neutral greys to avoid warm tones
      return const [Color(0xFFE0E0E0), Color(0xFFD0D0D0)];
    case 'fireOcean':
      // Cool blue pair
      return const [Color(0xFF3A4CC5), Color(0xFF4557CA)];
    case 'refreshingSummer':
      // Soft turquoise shades
      return const [Color(0xFF8ECAE6), Color(0xFF7EBFDD)];
    case 'oliveGardenFeast':
      // Muted greens close together
      return const [Color(0xFF606C38), Color(0xFF6A7642)];
    case 'oceanBleuSerenity':
      // Calm ocean blues
      return const [Color(0xFF0077B6), Color(0xFF008BC0)];
    case 'softPink':
      // Cool pastel purples
      return const [Color(0xFFE6DAF5), Color(0xFFDAD0EF)];
    case 'oceanBreeze':
      // Breezy light blues
      return const [Color(0xFF00B4D8), Color(0xFF23C2E3)];
    case 'softSand':
      // Neutral soft greys
      return const [Color(0xFFE5E5E5), Color(0xFFDADADA)];
    case 'beachSunset':
      // Gentle seaside blues
      return const [Color(0xFFBEE9E8), Color(0xFFC7EEF0)];
    case 'slateGrayContrast':
      // Slate blue duo
      return const [Color(0xFF3A6EA5), Color(0xFF4678AD)];
    case 'blueRoyal':
    default:
      // Subtle light blue pair
      return const [Color(0xFFDDE3F0), Color(0xFFE1E6F2)];
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
