import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';

/// Local-only draft payload stored in Hive.
class DraftRecord {
  const DraftRecord({
    required this.data,
    required this.savedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final Map<String, dynamic> data;
  final DateTime savedAt;
  final int schemaVersion;

  Map<String, dynamic> toJson() => {
        'data': data,
        'savedAt': savedAt.toIso8601String(),
        'schemaVersion': schemaVersion,
      };

  static DraftRecord? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final savedAt = DateTime.tryParse(map['savedAt']?.toString() ?? '');
    if (savedAt == null) return null;
    final schema = map['schemaVersion'] as int? ?? 1;
    if (schema != currentSchemaVersion) return null;
    final dataRaw = map['data'];
    if (dataRaw is! Map) return null;
    return DraftRecord(
      data: Map<String, dynamic>.from(dataRaw),
      savedAt: savedAt,
      schemaVersion: schema,
    );
  }

  bool get isExpired =>
      DateTime.now().difference(savedAt) > DraftService.defaultExpiry;
}

/// Generic save/restore/clear for multi-field form drafts (device-local Hive).
///
/// Keys are scoped per signed-in user so drafts do not leak across accounts.
/// Drafts are kept on sign-out (same user id when they sign back in).
class DraftService {
  DraftService._();
  static final DraftService instance = DraftService._();

  static const Duration defaultExpiry = Duration(days: 7);
  static const Duration defaultDebounce = Duration(milliseconds: 1200);

  Box<dynamic>? _box;
  static bool _hiveCoreReady = false;

  /// Override for tests.
  @visibleForTesting
  static String Function()? userIdResolver;

  /// When set, [init] uses this directory instead of [Hive.initFlutter].
  @visibleForTesting
  static String? hivePathOverride;

  /// Closes the box and resets init flags (tests only).
  @visibleForTesting
  static Future<void> resetForTests() async {
    final instance = DraftService.instance;
    if (instance._box != null && instance._box!.isOpen) {
      await instance._box!.close();
    }
    instance._box = null;
    _hiveCoreReady = false;
    hivePathOverride = null;
  }

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    try {
      await _ensureHiveInitialized();
      if (!Hive.isBoxOpen(DraftBoxKeys.boxName)) {
        _box = await Hive.openBox<dynamic>(DraftBoxKeys.boxName);
      } else {
        _box = Hive.box<dynamic>(DraftBoxKeys.boxName);
      }
    } catch (e) {
      debugPrint('DraftService Hive init failed: $e');
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
      try {
        Hive.init('raabta_hive');
      } catch (_) {
        // Hive already initialized (e.g. in unit tests).
      }
    }
  }

  /// `{uid}::{formId}` — anonymous users use `guest`.
  String storageKey(String formId) {
    final uid = userIdResolver?.call() ??
        FirebaseAuth.instance.currentUser?.uid ??
        'guest';
    return '$uid::$formId';
  }

  Future<void> saveDraft(String formId, Map<String, dynamic> data) async {
    if (data.isEmpty || _isEffectivelyEmpty(data)) return;
    await init();
    final box = _box;
    if (box == null) return;
    try {
      final record = DraftRecord(
        data: data,
        savedAt: DateTime.now(),
      );
      await box.put(storageKey(formId), record.toJson());
    } catch (e) {
      debugPrint('DraftService save failed ($formId): $e');
    }
  }

  Future<DraftRecord?> getDraft(String formId) async {
    await init();
    final box = _box;
    if (box == null) return null;
    try {
      final raw = box.get(storageKey(formId));
      if (raw == null) return null;
      Map<String, dynamic>? parsed;
      if (raw is Map) {
        parsed = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        parsed = jsonDecode(raw) as Map<String, dynamic>?;
      }
      final record = DraftRecord.fromJson(parsed);
      if (record == null) {
        await clearDraft(formId);
        return null;
      }
      if (record.isExpired) {
        await clearDraft(formId);
        return null;
      }
      return record;
    } catch (e) {
      debugPrint('DraftService read failed ($formId): $e');
      await clearDraft(formId);
      return null;
    }
  }

  Future<void> clearDraft(String formId) async {
    await init();
    final box = _box;
    if (box == null) return;
    try {
      await box.delete(storageKey(formId));
    } catch (e) {
      debugPrint('DraftService clear failed ($formId): $e');
    }
  }

  /// All non-expired drafts for the current user (optionally filtered by [formIdPrefix]).
  Future<List<({String formId, DraftRecord record})>> listDraftsForUser({
    String? formIdPrefix,
  }) async {
    await init();
    final box = _box;
    if (box == null) return const [];

    final uid = userIdResolver?.call() ??
        FirebaseAuth.instance.currentUser?.uid ??
        'guest';
    final prefix = '$uid::';
    final results = <({String formId, DraftRecord record})>[];

    for (final key in box.keys) {
      final keyStr = key.toString();
      if (!keyStr.startsWith(prefix)) continue;
      final formId = keyStr.substring(prefix.length);
      if (formIdPrefix != null && !formId.startsWith(formIdPrefix)) continue;
      final raw = box.get(key);
      Map<String, dynamic>? parsed;
      if (raw is Map) {
        parsed = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        parsed = jsonDecode(raw) as Map<String, dynamic>?;
      }
      final record = DraftRecord.fromJson(parsed);
      if (record == null || record.isExpired) {
        await box.delete(key);
        continue;
      }
      results.add((formId: formId, record: record));
    }

    results.sort(
      (a, b) => b.record.savedAt.compareTo(a.record.savedAt),
    );
    return results;
  }

  /// Drops file paths that no longer exist on disk (e.g. deleted vault docs).
  static List<String> filterExistingPaths(List<dynamic>? paths) {
    if (paths == null) return const [];
    return paths
        .map((e) => e.toString())
        .where((p) => p.isNotEmpty)
        .where((p) => p.startsWith('http') || File(p).existsSync())
        .toList();
  }

  static bool _isEffectivelyEmpty(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      final v = entry.value;
      if (v == null) continue;
      if (v is String && v.trim().isEmpty) continue;
      if (v is List && v.isEmpty) continue;
      if (v is Map && v.isEmpty) continue;
      if (v is bool && !v) continue;
      if (v is num && v == 0) continue;
      return false;
    }
    return true;
  }
}
