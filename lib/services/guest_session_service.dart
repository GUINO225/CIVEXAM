import 'dart:convert';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guest_identity.dart';

/// Manages the lifecycle of the local guest/demo session.
class GuestSessionService {
  GuestSessionService();

  static const _identityKey = 'guest_identity';
  static const _fallbackKey = 'guest_fallback_id';

  /// Current guest identity, if any.
  static final ValueNotifier<GuestIdentity?> notifier =
      ValueNotifier<GuestIdentity?>(null);

  /// Loads an existing guest session from preferences, if it exists.
  Future<GuestIdentity?> loadSaved() async {
    if (notifier.value != null) return notifier.value;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_identityKey);
    if (raw == null) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      final identity = GuestIdentity.fromJson(map);
      notifier.value = identity;
      return identity;
    } catch (_) {
      // If decoding fails, wipe the invalid cache and start fresh.
      await prefs.remove(_identityKey);
      return null;
    }
  }

  /// Creates or retrieves a guest identity based on the device MAC address.
  Future<GuestIdentity> ensureGuest() async {
    final existing = notifier.value ?? await loadSaved();
    if (existing != null) return existing;

    final prefs = await SharedPreferences.getInstance();
    final mac = await _resolveMacAddress();
    final fallback = await _fallbackIdentifier(prefs);

    final sanitized = _sanitize(mac ?? fallback);
    final identity = GuestIdentity(
      id: 'guest-$sanitized',
      macAddress: mac ?? fallback,
      createdAt: DateTime.now(),
    );
    await prefs.setString(_identityKey, json.encode(identity.toJson()));
    notifier.value = identity;
    return identity;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_identityKey);
    notifier.value = null;
  }

  Future<String?> _resolveMacAddress() async {
    if (kIsWeb) return null;
    try {
      final info = NetworkInfo();
      final bssid = await info.getWifiBSSID();
      if (bssid != null && bssid.trim().isNotEmpty) {
        return bssid.toUpperCase();
      }
    } catch (_) {
      // Best effort only. Continue to fallback identifiers.
    }
    return null;
  }

  Future<String> _fallbackIdentifier(SharedPreferences prefs) async {
    final cached = prefs.getString(_fallbackKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final id = await _deviceFingerprint();
    final resolved = id.isNotEmpty ? id : _randomHex();
    await prefs.setString(_fallbackKey, resolved);
    return resolved;
  }

  Future<String> _deviceFingerprint() async {
    try {
      if (kIsWeb) return '';
      final plugin = DeviceInfoPlugin();
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await plugin.androidInfo;
          return info.id ?? info.fingerprint ?? '';
        case TargetPlatform.iOS:
          final info = await plugin.iosInfo;
          return info.identifierForVendor ?? '';
        default:
          break;
      }
    } catch (_) {
      // Ignore and fallback to random.
    }
    return '';
  }

  String _randomHex() {
    const chars = 'ABCDEF0123456789';
    final rand = Random();
    final buffer = StringBuffer();
    for (var i = 0; i < 12; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
      if (i % 2 == 1 && i != 11) buffer.write(':');
    }
    return buffer.toString();
  }

  String _sanitize(String input) {
    final cleaned =
        input.replaceAll(RegExp(r'[^A-Fa-f0-9:]'), '').toUpperCase();
    if (cleaned.isNotEmpty) return cleaned;
    return _randomHex();
  }
}
