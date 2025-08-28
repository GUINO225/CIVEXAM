import 'package:flutter/material.dart';

/// Utilities for design palettes and contrast helpers
Color accentColor(String name) {
  switch (name) {
    case 'offWhite':
      return const Color(0xFFF5F5F5);
    case 'lightGrey':
      return const Color(0xFFEAEAEA);
    case 'darkGrey':
      return const Color(0xFF2C2C2C);
    case 'pastelBlue':
      return const Color(0xFFA8DADC);
    case 'powderPink':
      return const Color(0xFFF7CAD0);
    case 'lightGreen':
      return const Color(0xFFB7E4C7);
    case 'softYellow':
      return const Color(0xFFFFE66D);
    case 'midnightBlue':
      return const Color(0xFF1E1E2F);
    case 'anthracite':
      return const Color(0xFF2B2B2B);
    case 'blueIndigo':
      return const Color(0xFF2193B0);
    case 'violetRose':
      return const Color(0xFF7F00FF);
    case 'mintTurquoise':
      return const Color(0xFF43CEA2);
    case 'deepBlack':
      return const Color(0xFF121212);
    default:
      return const Color(0xFFF5F5F5);
  }
}

/// Returns two pastel variants of the accent color for gradient backgrounds.
List<Color> pastelColors(String name, {bool darkMode = false}) {
  switch (name) {
    case 'offWhite':
      return const [Color(0xFFF5F5F5), Color(0xFFF5F5F5)];
    case 'lightGrey':
      return const [Color(0xFFEAEAEA), Color(0xFFEAEAEA)];
    case 'darkGrey':
      return const [Color(0xFF2C2C2C), Color(0xFF2C2C2C)];
    case 'pastelBlue':
      return const [Color(0xFFA8DADC), Color(0xFFA8DADC)];
    case 'powderPink':
      return const [Color(0xFFF7CAD0), Color(0xFFF7CAD0)];
    case 'lightGreen':
      return const [Color(0xFFB7E4C7), Color(0xFFB7E4C7)];
    case 'softYellow':
      return const [Color(0xFFFFE66D), Color(0xFFFFE66D)];
    case 'midnightBlue':
      return const [Color(0xFF1E1E2F), Color(0xFF1E1E2F)];
    case 'anthracite':
      return const [Color(0xFF2B2B2B), Color(0xFF2B2B2B)];
    case 'blueIndigo':
      return const [Color(0xFF2193B0), Color(0xFF6DD5ED)];
    case 'violetRose':
      return const [Color(0xFF7F00FF), Color(0xFFE100FF)];
    case 'mintTurquoise':
      return const [Color(0xFF43CEA2), Color(0xFF185A9D)];
    case 'deepBlack':
      return const [Color(0xFF121212), Color(0xFF121212)];
    default:
      final accent = accentColor(name);
      final hsl = HSLColor.fromColor(accent);
      final light1 = darkMode ? 0.25 : 0.85;
      final light2 = darkMode ? 0.35 : 0.95;
      final c1 = hsl.withLightness(light1).toColor();
      final c2 = hsl.withLightness(light2).toColor();
      return [c1, c2];
  }
}

/// Complementary color used for buttons to stand out from the background.
Color complementaryColor(String name) {
  final accent = accentColor(name);
  final hsl = HSLColor.fromColor(accent);
  return hsl.withHue((hsl.hue + 180.0) % 360).toColor();
}

/// Returns [Colors.white] or [Colors.black] depending on the background brightness.
Color textColorForPalette(String name, {bool darkMode = false}) {
  final colors = pastelColors(name, darkMode: darkMode);
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

/// Returns true if the palette's averaged color is dark enough to require
/// light foreground content.
bool paletteIsDark(String name) {
  return textColorForPalette(name) == Colors.white;
}

/// Helper to get readable text color on top of any solid [color].
Color onColor(Color color) =>
    ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
