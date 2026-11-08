import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared Document Vault lock — one PIN gate for the vault, toggled from Privacy.
///
/// Audit note: no prior vault lock existed in the codebase; this is the single
/// implementation surfaced from Privacy → Account & Security.
class VaultLockService {
  VaultLockService(this._prefs);

  final SharedPreferences _prefs;

  static const enabledKey = 'vault_lock_enabled';
  static const pinHashKey = 'vault_pin_hash';

  /// In-memory session unlock (cleared on app restart).
  static bool sessionUnlocked = false;

  bool get isEnabled => _prefs.getBool(enabledKey) ?? false;

  bool get isSessionUnlocked => !isEnabled || sessionUnlocked;

  Future<void> enableWithPin(String pin) async {
    final normalized = pin.trim();
    if (normalized.length < 4) {
      throw ArgumentError('PIN must be at least 4 digits');
    }
    await _prefs.setString(pinHashKey, _hashPin(normalized));
    await _prefs.setBool(enabledKey, true);
    sessionUnlocked = true;
  }

  Future<void> disable({required String pin}) async {
    if (!verifyPin(pin)) {
      throw StateError('Incorrect PIN');
    }
    await _prefs.setBool(enabledKey, false);
    await _prefs.remove(pinHashKey);
    sessionUnlocked = true;
  }

  bool verifyPin(String pin) {
    final stored = _prefs.getString(pinHashKey);
    if (stored == null || stored.isEmpty) return false;
    return stored == _hashPin(pin.trim());
  }

  void unlockSession(String pin) {
    if (!isEnabled || verifyPin(pin)) {
      sessionUnlocked = true;
    }
  }

  void lockSession() {
    if (isEnabled) sessionUnlocked = false;
  }

  @visibleForTesting
  static String hashPinForTest(String pin) {
    return sha256.convert(utf8.encode(pin.trim())).toString();
  }

  String _hashPin(String pin) => hashPinForTest(pin);
}
