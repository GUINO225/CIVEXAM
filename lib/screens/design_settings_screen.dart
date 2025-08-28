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
              _paletteChip('red', _cfg.bgPaletteName == 'red'),
              _paletteChip('orange', _cfg.bgPaletteName == 'orange'),
              _paletteChip('yellow', _cfg.bgPaletteName == 'yellow'),
              _paletteChip('green', _cfg.bgPaletteName == 'green'),
              _paletteChip('blue', _cfg.bgPaletteName == 'blue'),
              _paletteChip('indigo', _cfg.bgPaletteName == 'indigo'),
              _paletteChip('violet', _cfg.bgPaletteName == 'violet'),
            ],
          ),
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
    final colors = pastelColors(name, darkMode: _cfg.darkMode);
    final textColor = textColorForPalette(name, darkMode: _cfg.darkMode);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _apply(_cfg.copyWith(bgPaletteName: name)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(name, style: TextStyle(color: textColor)),
        ),
      ),
    );
  }

  List<Color> _iconColorsForPalette(String name) {
    return [accentColor(name), complementaryColor(name)];
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
