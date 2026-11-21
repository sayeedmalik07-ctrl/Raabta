import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_models.dart';

/// Local-only secure storage for optional hint and opted-in known numbers.
/// The secret word itself is never stored.
abstract final class FamilyVerificationSecureStore {
  static const hintKey = 'ss_family_verification_hint_v1';
  static const contactsKey = 'ss_family_verification_contacts_v1';

  @visibleForTesting
  static Future<String?> Function(String key)? readOverride;

  @visibleForTesting
  static Future<void> Function(String key, String? value)? writeOverride;

  @visibleForTesting
  static Future<void> Function(String key)? deleteOverride;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _read(String key) async {
    if (readOverride != null) return readOverride!(key);
    return _storage.read(key: key);
  }

  static Future<void> _write(String key, String? value) async {
    if (writeOverride != null) {
      await writeOverride!(key, value);
      return;
    }
    if (value == null || value.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<void> _delete(String key) async {
    if (deleteOverride != null) {
      await deleteOverride!(key);
      return;
    }
    await _storage.delete(key: key);
  }

  static Future<String?> readHint() => _read(hintKey);

  static Future<void> saveHint(String hint) async {
    await _write(hintKey, hint.trim());
  }

  static Future<void> clearHint() => _delete(hintKey);

  static Future<List<FamilyKnownContact>> readContacts() async {
    final raw = await _read(contactsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is Map<String, dynamic>)
            FamilyKnownContact.fromJson(item),
      ];
    } catch (_) {
      return const [];
    }
  }

  static Future<void> saveContacts(List<FamilyKnownContact> contacts) async {
    if (contacts.isEmpty) {
      await _delete(contactsKey);
      return;
    }
    final encoded = jsonEncode(contacts.map((c) => c.toJson()).toList());
    await _write(contactsKey, encoded);
  }

  static Future<void> deleteAllSensitive() async {
    await _delete(hintKey);
    await _delete(contactsKey);
  }
}
