import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';

/// Hive cache for Cost of Living snapshots (24h — monthly official data).
class CostOfLivingLocalCache {
  CostOfLivingLocalCache._();
  static final CostOfLivingLocalCache instance = CostOfLivingLocalCache._();

  static const _boxName = 'cost_of_living_cache_v1';
  static const _dataKey = 'latest_snapshot';
  static const _tsKey = 'latest_ts';
  static const cacheTtl = Duration(hours: 24);

  Box<dynamic>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        try {
          await Hive.initFlutter();
        } catch (_) {
          Hive.init('raabta_hive');
        }
        _box = await Hive.openBox<dynamic>(_boxName);
      } else {
        _box = Hive.box<dynamic>(_boxName);
      }
    } catch (_) {
      _box = null;
    }
  }

  bool get isFresh {
    final raw = _box?.get(_tsKey);
    if (raw == null) return false;
    final ts = DateTime.tryParse(raw.toString());
    if (ts == null) return false;
    return DateTime.now().difference(ts) < cacheTtl;
  }

  Future<void> save(CostOfLivingSnapshot snapshot) async {
    await init();
    final box = _box;
    if (box == null) return;
    await box.put(_dataKey, jsonEncode(snapshot.toCacheJson()));
    await box.put(_tsKey, DateTime.now().toIso8601String());
  }

  CostOfLivingSnapshot? load() {
    final raw = _box?.get(_dataKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
      return CostOfLivingSnapshot.fromJson(map, isFromCache: true);
    } catch (_) {
      return null;
    }
  }
}
