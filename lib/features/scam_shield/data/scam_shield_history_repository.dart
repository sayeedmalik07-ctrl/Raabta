import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';

/// Local-only Hive scan log — UID-isolated, never cloud-synced.
class ScamShieldHistoryRepository {
  ScamShieldHistoryRepository._();
  static final ScamShieldHistoryRepository instance =
      ScamShieldHistoryRepository._();

  static const boxName = 'scam_shield_history_v1';
  static const _legacyEntriesKey = 'entries';
  static const _entriesBaseKey = 'entries';
  static const maxEntries = 50;

  Box<dynamic>? _box;
  static bool _hiveCoreReady = false;

  @visibleForTesting
  static String? hivePathOverride;

  @visibleForTesting
  static Future<void> resetForTests() async {
    final repo = ScamShieldHistoryRepository.instance;
    if (repo._box != null && repo._box!.isOpen) {
      await repo._box!.close();
    }
    repo._box = null;
    _hiveCoreReady = false;
    hivePathOverride = null;
  }

  String _entriesKey(String uid) =>
      UidScopedPreferences.scopedKey(uid, _entriesBaseKey);

  String? _resolveUid([String? uid]) => UidScopedPreferences.resolveUid(uid);

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    await _ensureHiveInitialized();
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<dynamic>(boxName);
    } else {
      _box = Hive.box<dynamic>(boxName);
    }
  }

  static Future<void> _ensureHiveInitialized() async {
    if (_hiveCoreReady) return;
    _hiveCoreReady = true;
    if (hivePathOverride != null) {
      Hive.init(hivePathOverride!);
      return;
    }
    try {
      await Hive.initFlutter();
    } catch (_) {
      Hive.init('raabta_hive');
    }
  }

  Future<List<ScamShieldHistoryEntry>> loadAll({String? uid}) async {
    final resolved = _resolveUid(uid);
    if (resolved == null) return [];

    await init();
    final raw = _box?.get(_entriesKey(resolved));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw.toString()) as List<dynamic>;
      return list
          .map(
            (e) => ScamShieldHistoryEntry.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList()
        ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    } catch (e) {
      debugPrint('ScamShieldHistoryRepository load failed: $e');
      return [];
    }
  }

  Future<void> saveEntry(ScamShieldHistoryEntry entry, {String? uid}) async {
    final resolved = _resolveUid(uid);
    if (resolved == null) return;

    await init();
    final existing = await loadAll(uid: resolved);
    final next = [entry, ...existing.where((e) => e.id != entry.id)]
        .take(maxEntries)
        .toList();
    await _box?.put(
      _entriesKey(resolved),
      jsonEncode(next.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearAll({String? uid}) async {
    final resolved = _resolveUid(uid);
    if (resolved == null) return;
    await init();
    await _box?.delete(_entriesKey(resolved));
  }

  Future<void> clearForUid(String uid) async {
    if (uid.isEmpty) return;
    await init();
    await _box?.delete(_entriesKey(uid));
  }

  /// Discards pre-isolation device-global history — never attached to a UID.
  Future<void> purgeLegacyDeviceGlobalEntries() async {
    await init();
    await _box?.delete(_legacyEntriesKey);
  }
}
