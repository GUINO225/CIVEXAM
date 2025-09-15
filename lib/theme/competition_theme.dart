/// Design options for the `CompetitionScreen`.
///
/// Centralizes all visual settings so the appearance of the screen can be
/// tweaked in a single place. Each field controls one aspect of the UI and can
/// be modified as needed.
import 'package:flutter/material.dart';

@immutable
class CompetitionTheme {
  /// Background color of the whole screen.
  final Color backgroundColor;

  /// Styling for the card that holds the question and progress information.
  final Color questionCardColor;
  final double questionCardRadius;
  final List<BoxShadow> questionCardShadow;

  /// Styling for the options (answer) cards.
  final Color optionCardColor;
  final double optionCardRadius;
  final List<BoxShadow> optionCardShadow;
  final Color optionSelectedBorderColor;

  /// Color of the progress bar displayed under the question.
  final Color progressBarColor;

  /// Dimensions and appearance of the countdown circle.
  final double timerSize;
  final double timerStrokeWidth;
  final Color timerColor;
  final Color timerContainerColor;
  final double timerContainerRadius;
  final List<BoxShadow> timerContainerShadow;

  /// Text styles used throughout the screen.
  final TextStyle timerTextStyle;
  final TextStyle questionIndexTextStyle;
  final TextStyle questionTextStyle;
  final TextStyle optionTextStyle;
  final TextStyle selectedChipTextStyle;

  /// Appearance of the chip that shows the selected answer.
  final Color selectedChipBackgroundColor;
  final double selectedChipRadius;

  const CompetitionTheme({
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.questionCardColor = Colors.white,
    this.questionCardRadius = 16.0,
    this.questionCardShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],
    this.optionCardColor = Colors.white,
    this.optionCardRadius = 24.0,
    this.optionCardShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],
    this.optionSelectedBorderColor = Colors.pinkAccent,
    this.progressBarColor = Colors.pinkAccent,
    this.timerSize = 80.0,
    this.timerStrokeWidth = 6.0,
    this.timerColor = Colors.pinkAccent,
    this.timerContainerColor = Colors.white,
    this.timerContainerRadius = 12.0,
    this.timerContainerShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
    ],
    this.timerTextStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    this.questionIndexTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
    this.questionTextStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.optionTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    this.selectedChipTextStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    this.selectedChipBackgroundColor = Colors.pinkAccent,
    this.selectedChipRadius = 24.0,
  });

  /// Builds a [CompetitionTheme] that matches the global [ThemeData].
  ///
  /// Using the app's color scheme ensures the competition screen adopts the
  /// same visual language as the rest of the interface.
  factory CompetitionTheme.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return CompetitionTheme(
      backgroundColor: theme.scaffoldBackgroundColor,
      questionCardColor: theme.cardColor,
      optionCardColor: theme.cardColor,
      optionSelectedBorderColor: scheme.primary,
      progressBarColor: scheme.primary,
      timerColor: scheme.primary,
      timerContainerColor: theme.cardColor,
      timerTextStyle:
          textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      questionIndexTextStyle: textTheme.bodySmall ?? const TextStyle(),
      questionTextStyle:
          textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      optionTextStyle: textTheme.bodyMedium ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      selectedChipTextStyle: textTheme.bodyMedium?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      selectedChipBackgroundColor: scheme.primary,
    );
  }

  /// Creates a copy of this theme with the given fields replaced by new values.
  CompetitionTheme copyWith({
    Color? backgroundColor,
    Color? questionCardColor,
    double? questionCardRadius,
    List<BoxShadow>? questionCardShadow,
    Color? optionCardColor,
    double? optionCardRadius,
    List<BoxShadow>? optionCardShadow,
    Color? optionSelectedBorderColor,
    Color? progressBarColor,
    double? timerSize,
    double? timerStrokeWidth,
    Color? timerColor,
    Color? timerContainerColor,
    double? timerContainerRadius,
    List<BoxShadow>? timerContainerShadow,
    TextStyle? timerTextStyle,
    TextStyle? questionIndexTextStyle,
    TextStyle? questionTextStyle,
    TextStyle? optionTextStyle,
    TextStyle? selectedChipTextStyle,
    Color? selectedChipBackgroundColor,
    double? selectedChipRadius,
  }) {
    return CompetitionTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      questionCardColor: questionCardColor ?? this.questionCardColor,
      questionCardRadius: questionCardRadius ?? this.questionCardRadius,
      questionCardShadow: questionCardShadow ?? this.questionCardShadow,
      optionCardColor: optionCardColor ?? this.optionCardColor,
      optionCardRadius: optionCardRadius ?? this.optionCardRadius,
      optionCardShadow: optionCardShadow ?? this.optionCardShadow,
      optionSelectedBorderColor:
          optionSelectedBorderColor ?? this.optionSelectedBorderColor,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      timerSize: timerSize ?? this.timerSize,
      timerStrokeWidth: timerStrokeWidth ?? this.timerStrokeWidth,
      timerColor: timerColor ?? this.timerColor,
      timerContainerColor: timerContainerColor ?? this.timerContainerColor,
      timerContainerRadius: timerContainerRadius ?? this.timerContainerRadius,
      timerContainerShadow: timerContainerShadow ?? this.timerContainerShadow,
      timerTextStyle: timerTextStyle ?? this.timerTextStyle,
      questionIndexTextStyle:
          questionIndexTextStyle ?? this.questionIndexTextStyle,
      questionTextStyle: questionTextStyle ?? this.questionTextStyle,
      optionTextStyle: optionTextStyle ?? this.optionTextStyle,
      selectedChipTextStyle:
          selectedChipTextStyle ?? this.selectedChipTextStyle,
      selectedChipBackgroundColor:
          selectedChipBackgroundColor ?? this.selectedChipBackgroundColor,
      selectedChipRadius: selectedChipRadius ?? this.selectedChipRadius,
    );
  }
}

/// Default visual settings used by the competition screen.
const CompetitionTheme kDefaultCompetitionTheme = CompetitionTheme();
