import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF37478F);
const Color kPrimaryBlueLight = Color(0xFF6C7BD0);
const Color kSurface = Colors.white;

ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryBlue,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: kSurface,
  );

  final textTheme = base.textTheme.copyWith(
    headlineLarge: base.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.3),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.3),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: Colors.black87,
      elevation: 0.5,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
