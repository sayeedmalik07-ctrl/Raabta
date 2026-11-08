import 'dart:convert';

import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for warranty items (UID-scoped SharedPreferences).
abstract final class WarrantyStorage {
  static const legacyGlobalKey = LocalDataIsolationKeys.warrantyItems;
  static const itemsKey = legacyGlobalKey;

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    await UidScopedPreferences.remove(prefs, itemsKey, uid: uid);
  }

  static Future<List<WarrantyItem>> load({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = UidScopedPreferences.getString(prefs, itemsKey, uid: uid);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WarrantyItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<WarrantyItem> items, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await UidScopedPreferences.setString(prefs, itemsKey, encoded, uid: uid);
  }
}
