import 'package:flutter/material.dart';

/// Thème d’affichage pour `CompetitionScreen`.
///
/// Centralise **tous les réglages visuels** afin de modifier l’apparence
/// de l’écran en **un seul endroit**. Chaque champ contrôle un aspect précis
/// de l’UI : couleurs, coins arrondis, ombres, tailles du chrono, styles de
/// texte, etc.
@immutable
class CompetitionTheme {
  // ==== Couleurs & fond général ====

  /// Couleur d’arrière-plan de l’écran complet.
  final Color backgroundColor;

  // ==== Carte question / progression ====

  /// Couleur de fond de la carte qui contient le chrono, la question et la barre de progression.
  final Color questionCardColor;

  /// Rayon des coins (en px) de la carte question.
  final double questionCardRadius;

  /// Ombres appliquées à la carte question.
  final List<BoxShadow> questionCardShadow;

  // ==== Cartes des options (réponses) ====

  /// Couleur de fond des cartes d’options (les réponses).
  final Color optionCardColor;

  /// Rayon des coins (en px) des cartes d’options.
  final double optionCardRadius;

  /// Ombres appliquées aux cartes d’options.
  final List<BoxShadow> optionCardShadow;

  /// Couleur de la bordure quand une option est sélectionnée.
  final Color optionSelectedBorderColor;

  // ==== Barre de progression globale ====

  /// Couleur de la barre de progression située sous la question.
  final Color progressBarColor;

  // ==== Chronomètre circulaire ====

  /// Diamètre du cercle du chrono (en px).
  final double timerSize;

  /// Épaisseur du trait du cercle du chrono (en px).
  final double timerStrokeWidth;

  /// Couleur du cercle du chrono (progression).
  final Color timerColor;

  /// Couleur de fond du conteneur autour du chrono (le petit bloc blanc arrondi).
  final Color timerContainerColor;

  /// Rayon des coins (en px) du conteneur du chrono.
  final double timerContainerRadius;

  /// Ombres appliquées au conteneur du chrono.
  final List<BoxShadow> timerContainerShadow;

  // ==== Styles de texte ====

  /// Style du texte affichant les secondes restantes au centre du chrono.
  final TextStyle timerTextStyle;

  /// Style du texte pour l’index de la question (ex. “Question 12/500”).
  final TextStyle questionIndexTextStyle;

  /// Style du texte de l’énoncé de la question.
  final TextStyle questionTextStyle;

  /// Style du texte des options (réponses).
  final TextStyle optionTextStyle;

  /// Style du texte de la “pastille” (chip) qui affiche l’option sélectionnée.
  final TextStyle selectedChipTextStyle;

  // ==== Pastille de sélection (chip) ====

  /// Couleur de fond de la pastille affichant l’option sélectionnée.
  final Color selectedChipBackgroundColor;

  /// Rayon des coins (en px) de la pastille.
  final double selectedChipRadius;

  /// Constructeur avec valeurs par défaut pensées pour un look propre.
  const CompetitionTheme({
    // Fond global
    this.backgroundColor = const Color(0xFF433B91),

    // Carte question
    this.questionCardColor = const Color(0xFFF5F5F5),
    this.questionCardRadius = 16.0,
    this.questionCardShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],

    // Cartes d’options
    this.optionCardColor = Colors.white,
    this.optionCardRadius = 12.0,
    this.optionCardShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],
    this.optionSelectedBorderColor = Colors.pinkAccent,

    // Barre de progression
    this.progressBarColor = Colors.pinkAccent,

    // Chronomètre
    this.timerSize = 80.0,
    this.timerStrokeWidth = 6.0,
    this.timerColor = Colors.pinkAccent,
    this.timerContainerColor = Colors.white,
    this.timerContainerRadius = 12.0,
    this.timerContainerShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
    ],

    // Textes
    this.timerTextStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
        fontFamily: 'Roboto'
    ),
    this.questionIndexTextStyle = const TextStyle(

      fontSize: 20,
      color: Colors.black54,



    ),
    this.questionTextStyle = const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.black,

    ),
    this.optionTextStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    this.selectedChipTextStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),

    // Pastille (chip)
    this.selectedChipBackgroundColor = Colors.pinkAccent,
    this.selectedChipRadius = 20.0,
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

  /// Retourne une **copie** du thème avec certaines valeurs remplacées.
  ///
  /// Idéal pour surcharger quelques propriétés à la volée :
  /// ```dart
  /// final custom = kDefaultCompetitionTheme.copyWith(
  ///   timerColor: Colors.blue,
  ///   questionTextStyle: const TextStyle(fontSize: 22),
  /// );
  /// ```
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

/// Thème par défaut utilisé par l’écran de compétition.
/// Tu peux l’utiliser tel quel, ou le surcharger avec `copyWith(...)`.
const CompetitionTheme kDefaultCompetitionTheme = CompetitionTheme();
