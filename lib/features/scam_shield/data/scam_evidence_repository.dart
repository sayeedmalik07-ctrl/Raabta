import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';

/// Local-only evidence locker — UID-isolated, never synced to Firestore.
class ScamEvidenceRepository {
  ScamEvidenceRepository._();
  static final ScamEvidenceRepository instance = ScamEvidenceRepository._();

  static const boxName = 'scam_shield_evidence_v1';
  static const _legacyRecordsKey = 'records';
  static const _recordsBaseKey = 'records';
  static const maxRecords = 30;

  Box<dynamic>? _box;

  @visibleForTesting
  static Future<void> resetForTests() async {
    UidScopedPreferences.forcedUidForTests = null;
    final repo = ScamEvidenceRepository.instance;
    if (repo._box != null && repo._box!.isOpen) {
      await repo._box!.close();
    }
    repo._box = null;
    UidScopedPreferences.forcedUidForTests = 'scam_evidence_test_uid';
  }

  @visibleForTesting
  static void clearForcedUidForTests() {
    UidScopedPreferences.forcedUidForTests = null;
  }

  String _recordsKey(String uid) =>
      UidScopedPreferences.scopedKey(uid, _recordsBaseKey);

  String? _resolveUid([String? uid]) => UidScopedPreferences.resolveUid(uid);

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      Hive.init('raabta_hive');
    }
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<dynamic>(boxName);
    } else {
      _box = Hive.box<dynamic>(boxName);
    }
  }

  Future<List<ScamEvidenceRecord>> loadAll({String? uid}) async {
    await init();
    final resolved = _resolveUid(uid);
    if (resolved == null) return [];
    final raw = _box?.get(_recordsKey(resolved));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw.toString()) as List<dynamic>;
      return list
          .map(
            (e) => ScamEvidenceRecord.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('ScamEvidenceRepository load failed: $e');
      return [];
    }
  }

  Future<void> save(ScamEvidenceRecord record, {String? uid}) async {
    await init();
    final resolved = _resolveUid(uid);
    if (resolved == null) return;
    final existing = await loadAll(uid: resolved);
    final next = [record, ...existing.where((e) => e.id != record.id)]
        .take(maxRecords)
        .toList();
    await _box?.put(
      _recordsKey(resolved),
      jsonEncode(next.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> updateVaultLink({
    required String recordId,
    required String vaultDocumentId,
    String? uid,
  }) async {
    await init();
    final resolved = _resolveUid(uid);
    if (resolved == null) return;

    final all = await loadAll(uid: resolved);
    final updated = all
        .map(
          (r) => r.id == recordId
              ? r.copyWithVaultLink(vaultDocumentId)
              : r,
        )
        .toList();
    await _box?.put(
      _recordsKey(resolved),
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearForUid(String uid) async {
    if (uid.isEmpty) return;
    await init();
    await _box?.delete(_recordsKey(uid));
  }

  /// Discards pre-isolation device-global evidence — never attached to a UID.
  Future<void> purgeLegacyDeviceGlobalRecords() async {
    await init();
    await _box?.delete(_legacyRecordsKey);
  }
}
