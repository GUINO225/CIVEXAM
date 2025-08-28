import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import '../services/design_prefs.dart';
import '../utils/palette_utils.dart';

class ThemePickerScreen extends StatefulWidget {
  const ThemePickerScreen({super.key});

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen> {
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
  }

  Future<void> _apply(String name) async {
    final c = _cfg.copyWith(bgPaletteName: name);
    setState(() => _cfg = c);
    DesignBus.push(c);
    await DesignPrefs.save(c);
  }

  @override
  Widget build(BuildContext context) {
    final palettes = ['red','orange','yellow','green','blue','indigo','violet'];
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un thème')),
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: palettes.map((p) => _paletteChip(p)).toList(),
        ),
      ),
    );
  }

  Widget _paletteChip(String name) {
    final colors = pastelPaletteFromName(name, brightness: Theme.of(context).brightness);
    final vivid = vividColorForPalette(name);
    final selected = _cfg.bgPaletteName == name;
    return GestureDetector(
      onTap: () => _apply(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? vivid : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette, color: vivid),
            const SizedBox(width: 6),
            Text(name, style: TextStyle(color: vivid)),
          ],
        ),
      ),
    );
  }
}
