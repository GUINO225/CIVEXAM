// lib/screens/_SmartSvgSafe_patch.dart
// ---------------------------------------------------------------------------------
// Fix ciblé : préserver les détails blancs quand la couleur MONO est très claire.
// - Ne touche qu'au widget _SmartSvgSafe (copie/colle ce bloc dans play_screen.dart)
// - Stratégie :
//     • on garde SvgTheme(currentColor: monoColor) (blancs préservés)
//     • si la couleur mono est TRÈS CLAIRE (luminance élevée), on ajoute un HALO
//       sous l'icône (duplicata noir léger + blur) pour que les zones blanches
//       restent visibles (sur base blanche ou très claire).
// ---------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _SmartSvgSafe extends StatelessWidget {
  final String iconName;
  final String primary;
  final String? fallback;
  final double size;
  final bool isMono;
  final Color monoColor;

  const _SmartSvgSafe({
    required this.iconName,
    required this.primary,
    this.fallback,
    required this.size,
    required this.isMono,
    required this.monoColor,
  });

  bool _isVeryLight(Color c) {
    // Luminance per W3C; seuil ~0.8 = très clair (blanc, jaune pâle…)
    return c.computeLuminance() >= 0.80;
  }

  Future<bool> _exists(String path) async {
    try { await rootBundle.load(path); return true; } catch (_) { return false; }
  }

  Widget _svg(String path, {Color? tint, required bool useMonoTheme}) {
    return SvgPicture.asset(
      path, width: size, height: size,
      // Si on veut un "silhouette" (halo), on force une teinte en colorFilter noir.
      colorFilter: tint != null ? ColorFilter.mode(tint, BlendMode.srcIn) : null,
      // Pour le rendu normal en mode mono, on passe la couleur via SvgTheme ->
      //   - les éléments "fill='currentColor'" prennent monoColor
      //   - les éléments "fill='#FFFFFF'" restent blancs (donc visibles)
      theme: useMonoTheme ? SvgTheme(currentColor: monoColor) : const SvgTheme(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool needsHalo = isMono && _isVeryLight(monoColor);

    Widget buildStack(String path) {
      // Pile : halo (optionnel) + rendu normal
      if (!needsHalo) {
        return _svg(path, useMonoTheme: isMono);
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          // HALO sombre discret sous l'icône (pour contraster les blancs)
          Opacity(
            opacity: 0.55,
            child: Transform.translate(
              offset: const Offset(0, 0.6),
              child: ImageFiltered.blur(
                sigmaX: 0.8, sigmaY: 0.8,
                child: _svg(path, tint: Colors.black, useMonoTheme: false), // silhouette noire
              ),
            ),
          ),
          // Rendu normal (blancs préservés)
          _svg(path, useMonoTheme: isMono),
        ],
      );
    }

    return FutureBuilder<bool>(
      future: _exists(primary),
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(width: size, height: size);
        }
        if (snap.data == true) {
          return buildStack(primary);
        }
        if (fallback != null) {
          return FutureBuilder<bool>(
            future: _exists(fallback!),
            builder: (_, snap2) {
              if (snap2.connectionState != ConnectionState.done) {
                return SizedBox(width: size, height: size);
              }
              if (snap2.data == true) {
                return buildStack(fallback!);
              }
              return Icon(Icons.image_outlined, size: size, color: Colors.white70);
            },
          );
        }
        return Icon(Icons.image_outlined, size: size, color: Colors.white70);
      },
    );
  }
}
