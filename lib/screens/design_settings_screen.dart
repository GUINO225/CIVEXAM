// lib/screens/design_settings_screen.dart
// Page de personnalisation repensée avec une interface moderne et intuitive.
// Propose un aperçu dynamique, un choix de couleurs épuré et des options
// avancées masquées dans des sections extensibles.

import 'dart:async';

import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/design_prefs.dart';
import '../utils/palette_utils.dart';
import '../utils/responsive_utils.dart';

class DesignSettingsScreen extends StatefulWidget {
  const DesignSettingsScreen({super.key});

  @override
  State<DesignSettingsScreen> createState() => _DesignSettingsScreenState();
}

class _DesignSettingsScreenState extends State<DesignSettingsScreen> {
  DesignConfig _cfg = const DesignConfig();

  // Palettes proposées (tons épurés et contrastes soignés)
  static const List<String> _palettes = [
    'civFlag',
    'navyCyanAmber',
    'indigoPurpleSky',
    'emeraldTealMint',
    'royalBlueGold',
    'charcoalElectric',
    'forestSandTerracotta',
    'cobaltLimeSlate',
    'calmPastels',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await DesignPrefs.load();
    if (!mounted) return;
    setState(() => _cfg = c);
    // Propager l'état actuel pour les autres widgets.
    DesignBus.push(c);
  }

  void _apply(DesignConfig c) {
    setState(() => _cfg = c);
    DesignBus.push(c); // mise à jour en direct
    unawaited(() async {
      try {
        await DesignPrefs.save(c); // persistance
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de sauvegarder')),
        );
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    final previewColors =
        pastelColors(_cfg.bgPaletteName, darkMode: _cfg.darkMode);
    final previewTextColor =
        textColorForPalette(_cfg.bgPaletteName, darkMode: _cfg.darkMode);
    final mediaQuery = MediaQuery.of(context);
    final scale = computeScaleFactor(mediaQuery);
    final textScaler = MediaQuery.textScalerOf(context);
    final double previewFontSize = scaledFontSize(
      base: 20,
      scale: scale,
      textScaler: textScaler,
      min: 18,
      max: 28,
    );
    final double sectionTitleSize = scaledFontSize(
      base: 16,
      scale: scale,
      textScaler: textScaler,
      min: 14,
      max: 22,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Personnalisation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Aperçu dynamique du thème actuel
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: previewColors),
            ),
            alignment: Alignment.center,
            child: Text(
              'Aperçu',
              style: TextStyle(
                color: previewTextColor,
                fontSize: previewFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          _sectionTitle('Thème', sectionTitleSize),
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: _cfg.darkMode,
            onChanged: (v) => _apply(_cfg.copyWith(darkMode: v)),
          ),
          SwitchListTile(
            title: const Text('Fond dégradé'),
            value: _cfg.bgGradient,
            onChanged: (v) => _apply(_cfg.copyWith(bgGradient: v)),
          ),
          const Divider(height: 32),

          _sectionTitle('Palette de couleurs', sectionTitleSize),
          SizedBox(
            height: 200,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final p in _palettes) _colorChoice(p),
              ],
            ),
          ),
          const Divider(height: 32),

          _sectionTitle('Options', sectionTitleSize),
          SwitchListTile(
            title: const Text('Effet "wave" (halo)'),
            value: _cfg.waveEnabled,
            onChanged: (v) => _apply(_cfg.copyWith(waveEnabled: v)),
          ),
          SwitchListTile(
            title: const Text('Icônes monochromes'),
            value: _cfg.useMono,
            onChanged: (v) => _apply(
              _cfg.copyWith(
                useMono: v,
                monoColor: v
                    ? complementaryColor(_cfg.bgPaletteName)
                    : _cfg.monoColor,
              ),
            ),
          ),

          // Sections avancées repliables
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('Verre (glassmorphism)'),
            children: [
              _sliderTile(
                label: 'Blur',
                value: _cfg.glassBlur,
                min: 8,
                max: 28,
                divisions: 20,
                onChanged: (v) => _apply(_cfg.copyWith(glassBlur: v)),
              ),
              _sliderTile(
                label: 'Opacité fond',
                value: _cfg.glassBgOpacity,
                min: 0.08,
                max: 0.30,
                divisions: 22,
                onChanged: (v) => _apply(_cfg.copyWith(glassBgOpacity: v)),
              ),
              _sliderTile(
                label: 'Opacité bordure',
                value: _cfg.glassBorderOpacity,
                min: 0.0,
                max: 0.5,
                divisions: 25,
                onChanged: (v) =>
                    _apply(_cfg.copyWith(glassBorderOpacity: v)),
              ),
            ],
          ),

          ExpansionTile(
            title: const Text('Tuiles'),
            children: [
              _sliderTile(
                label: 'Taille icône (px)',
                value: _cfg.tileIconSize,
                min: 36,
                max: 100,
                divisions: 64,
                onChanged: (v) =>
                    _apply(_cfg.copyWith(tileIconSize: v)),
              ),
              SwitchListTile(
                title: const Text('Centrer icône + texte'),
                value: _cfg.tileCenter,
                onChanged: (v) =>
                    _apply(_cfg.copyWith(tileCenter: v)),
              ),
            ],
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  Widget _colorChoice(String name) {
    final color = accentColor(name);
    final selected = _cfg.bgPaletteName == name;

    return Semantics(
      label: name,
      selected: selected,
      child: GestureDetector(
        onTap: () {
          final updated = _cfg.useMono
              ? _cfg.copyWith(
                  bgPaletteName: name,
                  monoColor: complementaryColor(name),
                )
              : _cfg.copyWith(bgPaletteName: name);
          _apply(updated);
        },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? onColor(color) : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              if (selected) Icon(Icons.check, color: onColor(color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(2)}'),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, double fontSize) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

