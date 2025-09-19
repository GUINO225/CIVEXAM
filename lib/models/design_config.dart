// lib/models/design_config.dart (Compat étendue)
// - Conserve les champs récents (bgPaletteName, waveEnabled, glass*, tileIconSize, tileCenter)
// - RÉINTRODUIT les anciens champs attendus par design_prefs.dart :
//   useMono, iconSetName, svgIconSize, monoColor
//   → évite les erreurs de compilation et reste compatible avec vos prefs existantes.
import 'dart:convert';
import 'dart:ui' show Color;

double _toDouble(dynamic v, double fallback) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

bool _toBool(Map<String, dynamic> map, String key, bool fallback) {
  final v = map[key];
  return v is bool ? v : fallback;
}

class DesignConfig {
  // Thème fond
  final String bgPaletteName;
  final bool waveEnabled;
  final bool bgGradient;
  final bool darkMode; // mode sombre activé ?

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
    this.bgPaletteName = 'charcoalElectric',
    this.waveEnabled = true,
    this.bgGradient = true,
    this.darkMode = false,
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
    this.monoColor = const Color(0xFFF472B6),
  });

  DesignConfig copyWith({
    String? bgPaletteName,
    bool? waveEnabled,
    bool? bgGradient,
    bool? darkMode,
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
      bgGradient: bgGradient ?? this.bgGradient,
      darkMode: darkMode ?? this.darkMode,
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
    'bgGradient': bgGradient,
    'glassBlur': glassBlur,
    'glassBgOpacity': glassBgOpacity,
    'glassBorderOpacity': glassBorderOpacity,
    'tileIconSize': tileIconSize,
    'tileCenter': tileCenter,
    'darkMode': darkMode,
    // Legacy
    'useMono': useMono,
    'iconSetName': iconSetName,
    'svgIconSize': svgIconSize,
    'monoColor': monoColor.value,
  };

  factory DesignConfig.fromJson(Map<String, dynamic> map) {
    // Extraction sûre + pont entre svgIconSize et tileIconSize
    final double svgSize = _toDouble(map['svgIconSize'], 54.0);
    final double tileSize = _toDouble(map['tileIconSize'], svgSize);

    return DesignConfig(
      bgPaletteName: map['bgPaletteName'] ?? 'charcoalElectric',
      waveEnabled: _toBool(map, 'waveEnabled', true),
      bgGradient: _toBool(map, 'bgGradient', true),
      glassBlur: _toDouble(map['glassBlur'], 18.0),
      glassBgOpacity: _toDouble(map['glassBgOpacity'], 0.16),
      glassBorderOpacity: _toDouble(map['glassBorderOpacity'], 0.22),
      tileIconSize: tileSize,
      tileCenter: _toBool(map, 'tileCenter', true),
      darkMode: _toBool(map, 'darkMode', false),
      useMono: _toBool(map, 'useMono', false),
      iconSetName: map['iconSetName'] ?? 'default',
      svgIconSize: svgSize,
      monoColor: Color((map['monoColor'] ?? 0xFFF472B6) as int),
    );
  }

  static DesignConfig fromJsonString(String s) =>
      DesignConfig.fromJson(json.decode(s) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());
}
