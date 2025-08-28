// lib/screens/design_settings_screen.dart
import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_prefs.dart';
import '../services/design_bus.dart';
import '../utils/palette_utils.dart';

class DesignSettingsScreen extends StatefulWidget {
  const DesignSettingsScreen({super.key});

  @override
  State<DesignSettingsScreen> createState() => _DesignSettingsScreenState();
}

class _DesignSettingsScreenState extends State<DesignSettingsScreen> {
  DesignConfig _cfg = const DesignConfig();

  static const _solidPalettes = [
    'offWhite',
    'lightGrey',
    'darkGrey',
    'pastelBlue',
    'powderPink',
    'lightGreen',
    'softYellow',
    'midnightBlue',
  ];

  static const _gradientPalettes = [
    'anthracite',
    'blueIndigo',
    'violetRose',
    'mintTurquoise',
    'deepBlack',
  ];

  static const Map<String, String> _paletteLabels = {
    'offWhite': 'Blanc cassé',
    'lightGrey': 'Gris clair',
    'darkGrey': 'Gris foncé',
    'pastelBlue': 'Bleu pastel',
    'powderPink': 'Rose poudré',
    'lightGreen': 'Vert clair',
    'softYellow': 'Jaune doux',
    'midnightBlue': 'Bleu nuit',
    'anthracite': 'Anthracite',
    'blueIndigo': 'Bleu indigo',
    'violetRose': 'Violet rosé',
    'mintTurquoise': 'Menthe turquoise',
    'deepBlack': 'Noir profond',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await DesignPrefs.load();
    if (!mounted) return;
    setState(() => _cfg = c);
    // pousser l’état actuel vers le bus (au cas où)
    DesignBus.push(c);
  }

  Future<void> _apply(DesignConfig c) async {
    setState(() => _cfg = c);
    DesignBus.push(c);            // 🔴 live update
    await DesignPrefs.save(c);    // 💾 persistance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages design')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: pastelColors(_cfg.bgPaletteName, darkMode: _cfg.darkMode),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Palette de fond'),
          const SizedBox(height: 8),
          const Text('Couleurs unies'),
          const SizedBox(height: 8),
          _paletteWrap(_solidPalettes),
          const SizedBox(height: 16),
          const Text('Dégradés doux'),
          const SizedBox(height: 8),
          _paletteWrap(_gradientPalettes),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Fond dégradé'),
            value: _cfg.bgGradient,
            onChanged: (v) => _apply(_cfg.copyWith(bgGradient: v)),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Effet “wave” (halo)'),
            value: _cfg.waveEnabled,
            onChanged: (v) => _apply(_cfg.copyWith(waveEnabled: v)),
          ),
          const SizedBox(height: 16),
          const Text('Icônes', style: TextStyle(fontWeight: FontWeight.bold)),
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
          const Divider(height: 32),

          const Text('Verre (glassmorphism)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _sliderTile(
            label: 'Blur',
            value: _cfg.glassBlur,
            min: 8, max: 28, divisions: 20,
            onChanged: (v) => _apply(_cfg.copyWith(glassBlur: v)),
          ),
          _sliderTile(
            label: 'Opacité fond (verre)',
            value: _cfg.glassBgOpacity,
            min: 0.08, max: 0.30, divisions: 22,
            onChanged: (v) => _apply(_cfg.copyWith(glassBgOpacity: v)),
          ),
          _sliderTile(
            label: 'Opacité bordure (verre)',
            value: _cfg.glassBorderOpacity,
            min: 0.0, max: 0.5, divisions: 25,
            onChanged: (v) => _apply(_cfg.copyWith(glassBorderOpacity: v)),
          ),
          const Divider(height: 32),

          const Text('Tuiles', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _sliderTile(
            label: 'Taille icône (px)',
            value: _cfg.tileIconSize,
            min: 36, max: 76, divisions: 40,
            onChanged: (v) => _apply(_cfg.copyWith(tileIconSize: v)),
          ),
          SwitchListTile(
            title: const Text('Centrer icône + texte'),
            value: _cfg.tileCenter,
            onChanged: (v) => _apply(_cfg.copyWith(tileCenter: v)),
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

  Widget _paletteChip(String name, bool selected) {
    final colors = pastelColors(name, darkMode: _cfg.darkMode);
    final textColor = textColorForPalette(name, darkMode: _cfg.darkMode);
    final borderColor = selected ? textColor : Colors.transparent;
    final label = _paletteLabels[name] ?? name;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          final updated = _cfg.useMono
              ? _cfg.copyWith(
                  bgPaletteName: name,
                  monoColor: complementaryColor(name),
                )
              : _cfg.copyWith(bgPaletteName: name);
          _apply(updated);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: Text(label, style: TextStyle(color: textColor)),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

  Widget _paletteWrap(List<String> palettes) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final p in palettes) _paletteChip(p, _cfg.bgPaletteName == p),
        ],
      );

  Widget _sliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          value: value, min: min, max: max, divisions: divisions,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
