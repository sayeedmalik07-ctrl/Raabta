import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/personal_context_models.dart';

/// Hive-only storage for Phase 35 personal providers — never synced.
abstract final class PersonalContextHiveStore {
  static const boxName = 'ss_personal_context_v1';
  static const dataKey = 'snapshot_v1';

  @visibleForTesting
  static String? hivePathOverride;

  static Future<Box<dynamic>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      if (hivePathOverride != null) {
        Hive.init(hivePathOverride);
      }
      return Hive.openBox<dynamic>(boxName);
    }
    return Hive.box<dynamic>(boxName);
  }

  static Future<PersonalContextSnapshot> loadSnapshot() async {
    final box = await _openBox();
    final raw = box.get(dataKey);
    if (raw is! String || raw.isEmpty) return PersonalContextSnapshot.empty;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PersonalContextSnapshot(
        bankDirectoryIds: _stringList(map['bankDirectoryIds']),
        telecomDirectoryIds: _stringList(map['telecomDirectoryIds']),
        noBankInQatar: map['noBankInQatar'] == true,
      );
    } catch (_) {
      return PersonalContextSnapshot.empty;
    }
  }

  static Future<void> saveSnapshot(PersonalContextSnapshot snapshot) async {
    final box = await _openBox();
    await box.put(
      dataKey,
      jsonEncode({
        'bankDirectoryIds': snapshot.bankDirectoryIds,
        'telecomDirectoryIds': snapshot.telecomDirectoryIds,
        'noBankInQatar': snapshot.noBankInQatar,
      }),
    );
  }

  static Future<void> deleteAll() async {
    final box = await _openBox();
    await box.delete(dataKey);
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
}
