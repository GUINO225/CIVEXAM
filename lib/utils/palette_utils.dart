import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'coteIvoire':
      // Inspired by the Ivorian flag (orange/green) with lighter shades
      return const [Color(0xFFFF8C00), Color(0xFF00C851)];
    case 'senegal':
      // Green to red gradient reflecting Senegal's flag
      return const [Color(0xFF00853F), Color(0xFFEF2B2D)];
    case 'ghana':
      // Red to dark green taken from Ghana's flag colours
      return const [Color(0xFFE21B1B), Color(0xFF006B3F)];
    case 'nigeria':
      // Dual greens reminiscent of Nigeria's flag
      return const [Color(0xFF008751), Color(0xFFA7FF83)];
    case 'kenya':
      // Kenyan flag tones with warm red and deep green
      return const [Color(0xFFBB1919), Color(0xFF006600)];
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
