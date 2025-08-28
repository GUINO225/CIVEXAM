// lib/services/design_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/design_config.dart';

class DesignPrefs {
  static const _kUseMono = 'design_useMono';
  static const _kIconSet = 'design_iconSet';
  static const _kSvgSize = 'design_svgSize';
  static const _kMonoCol = 'design_monoColor';
  static const _kBlur    = 'design_glassBlur';
  static const _kBgOp    = 'design_glassBgOpacity';
  static const _kBdOp    = 'design_glassBorderOpacity';
  static const _kWave    = 'design_waveEnabled';
  static const _kBgPal   = 'design_bgPaletteName'; // NEW
  static const _kBgGrad  = 'design_bgGradient';
  static const _kDark    = 'design_darkMode';
  static const _kTileSize = 'design_tileIconSize';
  static const _kTileCtr  = 'design_tileCenter';

  static Future<DesignConfig> load() async {
    final p = await SharedPreferences.getInstance();
    const base = DesignConfig();
    return base.copyWith(
      useMono: p.getBool(_kUseMono) ?? base.useMono,
      iconSetName: p.getString(_kIconSet) ?? base.iconSetName,
      svgIconSize: p.getDouble(_kSvgSize) ?? base.svgIconSize,
      monoColor: Color(p.getInt(_kMonoCol) ?? base.monoColor.value),
      glassBlur: p.getDouble(_kBlur) ?? base.glassBlur,
      glassBgOpacity: p.getDouble(_kBgOp) ?? base.glassBgOpacity,
      glassBorderOpacity: p.getDouble(_kBdOp) ?? base.glassBorderOpacity,
      waveEnabled: p.getBool(_kWave) ?? base.waveEnabled,
      bgPaletteName: p.getString(_kBgPal) ?? base.bgPaletteName,
      bgGradient: p.getBool(_kBgGrad) ?? base.bgGradient,
      darkMode: p.getBool(_kDark) ?? base.darkMode,
      tileIconSize: p.getDouble(_kTileSize) ?? base.tileIconSize,
      tileCenter: p.getBool(_kTileCtr) ?? base.tileCenter,
    );
  }

  static Future<void> save(DesignConfig cfg) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kUseMono, cfg.useMono);
    await p.setString(_kIconSet, cfg.iconSetName);
    await p.setDouble(_kSvgSize, cfg.svgIconSize);
    await p.setInt(_kMonoCol, cfg.monoColor.value);
    await p.setDouble(_kBlur, cfg.glassBlur);
    await p.setDouble(_kBgOp, cfg.glassBgOpacity);
    await p.setDouble(_kBdOp, cfg.glassBorderOpacity);
    await p.setBool(_kWave, cfg.waveEnabled);
    await p.setString(_kBgPal, cfg.bgPaletteName);
    await p.setBool(_kBgGrad, cfg.bgGradient);
    await p.setBool(_kDark, cfg.darkMode);
    await p.setDouble(_kTileSize, cfg.tileIconSize);
    await p.setBool(_kTileCtr, cfg.tileCenter);
  }
}
