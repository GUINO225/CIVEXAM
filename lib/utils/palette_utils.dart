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
    case 'sereneBlue':
      return const Color(0xFF1A73E8);
    case 'forestGreen':
      return const Color(0xFF2E7D32);
    case 'deepIndigo':
      return const Color(0xFF283593);
    case 'royalViolet':
      return const Color(0xFF6A1B9A);
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
    case 'sereneBlue':
      return const [Color(0xFF1A73E8), Color(0xFF64B5F6)];
    case 'forestGreen':
      return const [Color(0xFF2E7D32), Color(0xFF81C784)];
    case 'deepIndigo':
      return const [Color(0xFF283593), Color(0xFF5C6BC0)];
    case 'royalViolet':
      return const [Color(0xFF6A1B9A), Color(0xFFBA68C8)];
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

/// Returns a darker shade of the palette color for icons so that they remain
/// visible while staying in the same blue-toned family.
Color iconColorForPalette(String name) {
  final accent = accentColor(name);
  final hsl = HSLColor.fromColor(accent);
  // Reduce lightness to create a darker variant.
  final dark = hsl.withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0));
  return dark.toColor();
}

/// Gradient used for icon badges based on the palette. The gradient goes from a
/// darker shade to the base accent color for a subtle blue effect.
List<Color> iconGradientForPalette(String name) {
  final accent = accentColor(name);
  final dark = iconColorForPalette(name);
  return [dark, accent];
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

/// Helper to get readable text color on top of any solid [color].
Color onColor(Color color) =>
    ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
