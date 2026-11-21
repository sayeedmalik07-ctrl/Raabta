import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';

/// Local-only Hive storage for guest prospective migrant data.
class ProspectiveProfileRepository {
  ProspectiveProfileRepository._();
  static final ProspectiveProfileRepository instance =
      ProspectiveProfileRepository._();

  static const boxName = 'prospective_profile';
  static const _recordKey = 'profile';

  Box<dynamic>? _box;
  static bool _hiveCoreReady = false;

  @visibleForTesting
  static String? hivePathOverride;

  @visibleForTesting
  static Future<void> resetForTests() async {
    final repo = ProspectiveProfileRepository.instance;
    if (repo._box != null && repo._box!.isOpen) {
      await repo._box!.close();
    }
    repo._box = null;
    _hiveCoreReady = false;
    hivePathOverride = null;
  }

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

  Future<ProspectiveProfile?> load() async {
    await init();
    final raw = _box?.get(_recordKey);
    if (raw == null) return null;
    try {
      if (raw is Map) {
        return ProspectiveProfile.fromJson(Map<String, dynamic>.from(raw));
      }
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return ProspectiveProfile.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('ProspectiveProfileRepository load failed: $e');
    }
    return null;
  }

  Future<void> save(ProspectiveProfile profile) async {
    await init();
    final record = profile.copyWith(updatedAt: DateTime.now());
    await _box?.put(_recordKey, record.toJson());
  }

  Future<bool> hasProfile() async {
    final profile = await load();
    return profile != null && profile.hasCountry;
  }

  Future<void> clear() async {
    await init();
    await _box?.delete(_recordKey);
  }
}