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
          const Text('Palette de fond', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _paletteChip('midnight', _cfg.bgPaletteName == 'midnight'),
              _paletteChip('forest', _cfg.bgPaletteName == 'forest'),
              _paletteChip('ocean', _cfg.bgPaletteName == 'ocean'),
              _paletteChip('purple', _cfg.bgPaletteName == 'purple'),
              _paletteChip('lavender', _cfg.bgPaletteName == 'lavender'),
              _paletteChip('steel', _cfg.bgPaletteName == 'steel'),
              _paletteChip('coffee', _cfg.bgPaletteName == 'coffee'),
              _paletteChip('blueRoyal', _cfg.bgPaletteName == 'blueRoyal'),
            ],
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
            onChanged: (v) => _apply(_cfg.copyWith(useMono: v)),
          ),
          if (_cfg.useMono)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconColorsForPalette(_cfg.bgPaletteName)
                  .map((c) => _colorChip(c, _cfg.monoColor == c))
                  .toList(),
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
    return ChoiceChip(
      label: Text(name),
      selected: selected,
      onSelected: (_) => _apply(_cfg.copyWith(bgPaletteName: name)),
    );
  }

  List<Color> _iconColorsForPalette(String name) {
    final palette = paletteFromName(name);
    Color complement(Color c) =>
        Color.fromARGB(255, 255 - c.red, 255 - c.green, 255 - c.blue);
    final c1 = complement(palette[0]);
    final c2 = complement(palette.length > 1 ? palette[1] : palette[0]);
    final avg = Color.fromARGB(
      255,
      ((palette[0].red + palette[1].red) / 2).round(),
      ((palette[0].green + palette[1].green) / 2).round(),
      ((palette[0].blue + palette[1].blue) / 2).round(),
    );
    final c3 = complement(avg);
    return [Colors.black, Colors.white, c1, c2, c3];
  }

  Widget _colorChip(Color color, bool selected) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return ChoiceChip(
      label: const SizedBox(width: 24, height: 24),
      selected: selected,
      selectedColor: color,
      backgroundColor: color,
      checkmarkColor: brightness == Brightness.dark ? Colors.white : Colors.black,
      onSelected: (_) => _apply(_cfg.copyWith(monoColor: color)),
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
