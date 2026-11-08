import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed recent global search queries (local only).
class RecentSearchesCache {
  RecentSearchesCache._();
  static final RecentSearchesCache instance = RecentSearchesCache._();

  static const boxName = 'global_search_recent_v1';
  static const _entriesKey = 'entries';
  static const maxEntries = 8;

  Box<dynamic>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    try {
      if (!Hive.isBoxOpen(boxName)) {
        try {
          await Hive.initFlutter();
        } catch (_) {
          Hive.init('raabta_hive');
        }
        _box = await Hive.openBox<dynamic>(boxName);
      } else {
        _box = Hive.box<dynamic>(boxName);
      }
    } catch (_) {
      _box = null;
    }
  }

  List<String> load() {
    final raw = _box?.get(_entriesKey);
    if (raw == null) return <String>[];
    try {
      final list = jsonDecode(raw.toString()) as List;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> add(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 2) return Future.value();
    final current = List<String>.from(load())
      ..removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    final trimmedList = current.take(maxEntries).toList();
    return _box?.put(_entriesKey, jsonEncode(trimmedList)) ?? Future.value();
  }

  Future<void> remove(String query) {
    final current = List<String>.from(load())..removeWhere((e) => e == query);
    return _box?.put(_entriesKey, jsonEncode(current)) ?? Future.value();
  }

  Future<void> clear() => _box?.delete(_entriesKey) ?? Future.value();

  /// Test-only reset.
  Future<void> resetForTests() async {
    await _box?.clear();
  }

  static String? hivePathOverride;

  Future<void> initForTests() async {
    if (hivePathOverride != null) {
      Hive.init(hivePathOverride!);
    }
    await init();
  }
}
