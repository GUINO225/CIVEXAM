// lib/models/design_config.dart (Compat étendue)
// - Conserve les champs récents (bgPaletteName, waveEnabled, glass*, tileIconSize, tileCenter)
// - RÉINTRODUIT les anciens champs attendus par design_prefs.dart :
//   useMono, iconSetName, svgIconSize, monoColor
//   → évite les erreurs de compilation et reste compatible avec vos prefs existantes.
import 'dart:convert';
import 'dart:ui' show Color;

class DesignConfig {
  // Thème fond
  final String bgPaletteName;
  final bool waveEnabled;

  // Verre
  final double glassBlur;
  final double glassBgOpacity;
  final double glassBorderOpacity;

  // Contrôles tuiles (nouveaux)
  final double tileIconSize;   // taille du badge d’icône dans les tuiles
  final bool tileCenter;       // centrer icône + texte

  // Legacy (anciens champs utilisés par design_prefs.dart)
  final bool useMono;          // icônes monochromes ?
  final String iconSetName;    // nom du pack d’icônes
  final double svgIconSize;    // taille d’icône (hérité) — on le mappe à tileIconSize
  final Color monoColor;       // couleur monochrome

  const DesignConfig({
    // Thème fond
    this.bgPaletteName = 'blueRoyal',
    this.waveEnabled = true,
    // Verre
    this.glassBlur = 18.0,
    this.glassBgOpacity = 0.16,
    this.glassBorderOpacity = 0.22,
    // Tuiles
    this.tileIconSize = 54.0,
    this.tileCenter = true,
    // Legacy
    this.useMono = false,
    this.iconSetName = 'default',
    this.svgIconSize = 54.0,
    this.monoColor = const Color(0xFFFFFFFF),
  });

  DesignConfig copyWith({
    String? bgPaletteName,
    bool? waveEnabled,
    double? glassBlur,
    double? glassBgOpacity,
    double? glassBorderOpacity,
    double? tileIconSize,
    bool? tileCenter,
    bool? useMono,
    String? iconSetName,
    double? svgIconSize,
    Color? monoColor,
  }) {
    return DesignConfig(
      bgPaletteName: bgPaletteName ?? this.bgPaletteName,
      waveEnabled: waveEnabled ?? this.waveEnabled,
      glassBlur: glassBlur ?? this.glassBlur,
      glassBgOpacity: glassBgOpacity ?? this.glassBgOpacity,
      glassBorderOpacity: glassBorderOpacity ?? this.glassBorderOpacity,
      tileIconSize: tileIconSize ?? this.tileIconSize,
      tileCenter: tileCenter ?? this.tileCenter,
      useMono: useMono ?? this.useMono,
      iconSetName: iconSetName ?? this.iconSetName,
      svgIconSize: svgIconSize ?? this.svgIconSize,
      monoColor: monoColor ?? this.monoColor,
    );
  }

  Map<String, dynamic> toJson() => {
    'bgPaletteName': bgPaletteName,
    'waveEnabled': waveEnabled,
    'glassBlur': glassBlur,
    'glassBgOpacity': glassBgOpacity,
    'glassBorderOpacity': glassBorderOpacity,
    'tileIconSize': tileIconSize,
    'tileCenter': tileCenter,
    // Legacy
    'useMono': useMono,
    'iconSetName': iconSetName,
    'svgIconSize': svgIconSize,
    'monoColor': monoColor.value,
  };

  factory DesignConfig.fromJson(Map<String, dynamic> map) {
    // Extraction sûre + pont entre svgIconSize et tileIconSize
    final double svgSize = (map['svgIconSize'] ?? 54.0).toDouble();
    final double tileSize = (map['tileIconSize'] ?? svgSize).toDouble();

    return DesignConfig(
      bgPaletteName: map['bgPaletteName'] ?? 'blueRoyal',
      waveEnabled: (map['waveEnabled'] ?? true) as bool,
      glassBlur: (map['glassBlur'] ?? 18.0).toDouble(),
      glassBgOpacity: (map['glassBgOpacity'] ?? 0.16).toDouble(),
      glassBorderOpacity: (map['glassBorderOpacity'] ?? 0.22).toDouble(),
      tileIconSize: tileSize,
      tileCenter: (map['tileCenter'] ?? true) as bool,
      useMono: (map['useMono'] ?? false) as bool,
      iconSetName: map['iconSetName'] ?? 'default',
      svgIconSize: svgSize,
      monoColor: Color((map['monoColor'] ?? 0xFFFFFFFF) as int),
    );
  }

  static DesignConfig fromJsonString(String s) =>
      DesignConfig.fromJson(json.decode(s) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());
}
