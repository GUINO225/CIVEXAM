import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'midnight':
      // Soft steel blue gradient with close shades
      return const [Color(0xFF9BAEC8), Color(0xFF768AA5)];
    case 'forest':
      // Muted light green to slightly darker green
      return const [Color(0xFF9EC9A3), Color(0xFF74A27C)];
    case 'ocean':
      // Light aqua to gentle teal
      return const [Color(0xFF9DD5E0), Color(0xFF6EB1C2)];
    case 'purple':
      // Soft lavender shades
      return const [Color(0xFFBFADE6), Color(0xFF9C8ACB)];
    case 'lavender':
      // Pale lavender duo
      return const [Color(0xFFE4DEFA), Color(0xFFC8C0E4)];
    case 'steel':
      // Light to medium grey
      return const [Color(0xFFD7DBE0), Color(0xFFB0B6BD)];
    case 'coffee':
      // Neutral greys to avoid warm tones
      return const [Color(0xFFDCDCDC), Color(0xFFB5B5B5)];
    case 'fireOcean':
      // Cool teal pair
      return const [Color(0xFF9BC7D4), Color(0xFF769FB0)];
    case 'refreshingSummer':
      return const [Color(0xFFA9D9E8), Color(0xFF82B8CC)];
    case 'oliveGardenFeast':
      return const [Color(0xFFB7D7BE), Color(0xFF8FAF96)];
    case 'oceanBleuSerenity':
      return const [Color(0xFF8AB9E2), Color(0xFF6999C9)];
    case 'softPink':
      // Use cool lavender instead of warm pink
      return const [Color(0xFFD9C8F4), Color(0xFFB9A9DA)];
    case 'oceanBreeze':
      return const [Color(0xFF8CC9E8), Color(0xFF69AFCF)];
    case 'softSand':
      // Cool grey duo
      return const [Color(0xFFE0E3E6), Color(0xFFBCC2C8)];
    case 'beachSunset':
      // Soft sea blue gradient
      return const [Color(0xFF8DBBD6), Color(0xFF6D9FC0)];
    case 'slateGrayContrast':
      return const [Color(0xFFC4CCD6), Color(0xFF9BA5B2)];
    case 'blueRoyal':
    default:
      // Subtle light to medium blue
      return const [Color(0xFFCBD6EC), Color(0xFFA5B6D9)];
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
