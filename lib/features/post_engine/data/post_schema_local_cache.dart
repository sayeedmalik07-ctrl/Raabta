import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';

/// Hive cache for Firestore post schemas (stale-but-usable offline).
class PostSchemaLocalCache {
  PostSchemaLocalCache._();
  static final PostSchemaLocalCache instance = PostSchemaLocalCache._();

  static const _boxName = 'post_schemas_cache_v1';
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

  String _dataKey(String verticalId) => 'schema_$verticalId';
  String _tsKey(String verticalId) => 'schema_${verticalId}_ts';
  String _versionKey(String verticalId) => 'schema_${verticalId}_version';

  bool isFresh(String verticalId) {
    final raw = _box?.get(_tsKey(verticalId));
    if (raw == null) return false;
    final ts = DateTime.tryParse(raw.toString());
    if (ts == null) return false;
    return DateTime.now().difference(ts) < cacheTtl;
  }

  int? cachedVersion(String verticalId) {
    final raw = _box?.get(_versionKey(verticalId));
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  Future<void> save(PostVerticalSchema schema) async {
    await init();
    final box = _box;
    if (box == null) return;
    await box.put(_dataKey(schema.verticalId), jsonEncode(schema.toJson()));
    await box.put(
      _tsKey(schema.verticalId),
      DateTime.now().toIso8601String(),
    );
    await box.put(_versionKey(schema.verticalId), schema.version);
  }

  PostVerticalSchema? load(String verticalId) {
    final raw = _box?.get(_dataKey(verticalId));
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
      return PostVerticalSchema.fromJson(map, fromCache: true);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String verticalId) async {
    await init();
    final box = _box;
    if (box == null) return;
    await box.delete(_dataKey(verticalId));
    await box.delete(_tsKey(verticalId));
    await box.delete(_versionKey(verticalId));
  }
}
