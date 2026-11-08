import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:raabta/features/scam_shield/data/scam_evidence_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UID-namespaced SharedPreferences access — `{uid}::{baseKey}`.
abstract final class UidScopedPreferences {
  /// Set by [ScamEvidenceRepository.resetForTests] for Hive unit tests.
  @visibleForTesting
  static String? forcedUidForTests;

  static String scopedKey(String uid, String baseKey) => '$uid::$baseKey';

  /// Returns null for guest / signed-out — never reads legacy global keys.
  static String? resolveUid([String? uid]) {
    if (uid != null && uid.isNotEmpty) return uid;
    if (forcedUidForTests != null &&
        forcedUidForTests!.isNotEmpty &&
        Hive.isBoxOpen(ScamEvidenceRepository.boxName)) {
      return forcedUidForTests;
    }
    try {
      final resolved = FirebaseAuth.instance.currentUser?.uid;
      if (resolved == null || resolved.isEmpty) return null;
      return resolved;
    } catch (_) {
      return null;
    }
  }

  static String? getString(
    SharedPreferences prefs,
    String baseKey, {
    String? uid,
  }) {
    final resolved = resolveUid(uid);
    if (resolved == null) return null;
    return prefs.getString(scopedKey(resolved, baseKey));
  }

  static Future<bool> setString(
    SharedPreferences prefs,
    String baseKey,
    String value, {
    String? uid,
  }) async {
    final resolved = resolveUid(uid);
    if (resolved == null) return false;
    await prefs.setString(scopedKey(resolved, baseKey), value);
    return true;
  }

  static bool? getBool(
    SharedPreferences prefs,
    String baseKey, {
    String? uid,
  }) {
    final resolved = resolveUid(uid);
    if (resolved == null) return null;
    return prefs.getBool(scopedKey(resolved, baseKey));
  }

  static Future<bool> setBool(
    SharedPreferences prefs,
    String baseKey,
    bool value, {
    String? uid,
  }) async {
    final resolved = resolveUid(uid);
    if (resolved == null) return false;
    await prefs.setBool(scopedKey(resolved, baseKey), value);
    return true;
  }

  static List<String>? getStringList(
    SharedPreferences prefs,
    String baseKey, {
    String? uid,
  }) {
    final resolved = resolveUid(uid);
    if (resolved == null) return null;
    return prefs.getStringList(scopedKey(resolved, baseKey));
  }

  static Future<bool> setStringList(
    SharedPreferences prefs,
    String baseKey,
    List<String> value, {
    String? uid,
  }) async {
    final resolved = resolveUid(uid);
    if (resolved == null) return false;
    await prefs.setStringList(scopedKey(resolved, baseKey), value);
    return true;
  }

  static Future<bool> remove(
    SharedPreferences prefs,
    String baseKey, {
    String? uid,
  }) async {
    final resolved = resolveUid(uid);
    if (resolved == null) return false;
    return prefs.remove(scopedKey(resolved, baseKey));
  }

  /// Removes all UID-scoped keys matching `{uid}::{baseKey}` for deletion flows.
  static Future<void> removeAllForUid(
    SharedPreferences prefs,
    String uid,
    Iterable<String> baseKeys,
  ) async {
    if (uid.isEmpty) return;
    for (final baseKey in baseKeys) {
      await prefs.remove(scopedKey(uid, baseKey));
    }
  }

  /// Removes `{uid}::{baseKeyPrefix}*` keys (e.g. per-lease tenancy condition caches).
  static Future<void> removeAllWithBasePrefixForUid(
    SharedPreferences prefs,
    String uid,
    String baseKeyPrefix,
  ) async {
    if (uid.isEmpty) return;
    final prefix = scopedKey(uid, baseKeyPrefix);
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(prefix)) {
        await prefs.remove(key);
      }
    }
  }
}
