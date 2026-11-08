import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';

/// Signed-in UID required before writing indexed temp report files.
class ReportPackTempException implements Exception {
  const ReportPackTempException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Tracks on-device temp pack files; purge after share or 24 hours.
abstract final class ReportPackTempFiles {
  static const _indexKey = 'ss_report_pack_temp_index_v1';
  static const maxAge = Duration(hours: 24);

  @visibleForTesting
  static String? forcedUidForTests;

  static String? _uid([String? uid]) {
    if (uid != null && uid.isNotEmpty) return uid;
    if (forcedUidForTests != null) return forcedUidForTests;
    return UidScopedPreferences.resolveUid();
  }

  /// Fails before any filesystem write when no UID is available.
  static String requireUidOrThrow({String? uid}) {
    final resolved = _uid(uid);
    if (resolved == null) {
      throw const ReportPackTempException(
        'Report pack files require a signed-in account.',
      );
    }
    return resolved;
  }

  static Future<File> writeTemp({
    required List<int> bytes,
    required String suffix,
    String? uid,
  }) async {
    final resolved = requireUidOrThrow(uid: uid);
    await purgeExpired(uid: resolved);
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/raabta_report_pack_${DateTime.now().millisecondsSinceEpoch}.$suffix';
    final file = File(path);
    await file.writeAsBytes(bytes);
    await _register(path, uid: resolved);
    return file;
  }

  /// Removes temp file and index entry. Returns false if file delete failed.
  static Future<bool> discard(String path, {String? uid}) async {
    if (path.isEmpty) return true;
    var fileOk = true;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      fileOk = false;
    }
    try {
      await _unregister(path, uid: uid);
    } catch (_) {
      return false;
    }
    return fileOk;
  }

  static Future<bool> markShared(String path, {String? uid}) =>
      discard(path, uid: uid);

  /// Deletes all indexed temp pack files for the current UID.
  static Future<void> purgeAll({String? uid}) async {
    final resolved = _uid(uid);
    if (resolved == null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = UidScopedPreferences.getString(prefs, _indexKey, uid: resolved);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    for (final entry in list) {
      final path = entry['path']?.toString() ?? '';
      if (path.isEmpty) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await UidScopedPreferences.setString(
      prefs,
      _indexKey,
      jsonEncode([]),
      uid: resolved,
    );
  }

  static Future<void> purgeExpired({String? uid}) async {
    final resolved = _uid(uid);
    if (resolved == null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = UidScopedPreferences.getString(prefs, _indexKey, uid: resolved);
    if (raw == null) return;
    final now = DateTime.now();
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final keep = <Map<String, dynamic>>[];
    for (final entry in list) {
      final path = entry['path']?.toString() ?? '';
      final at = DateTime.tryParse(entry['at']?.toString() ?? '') ?? now;
      final file = File(path);
      final expired = now.difference(at) > maxAge;
      if (expired || !await file.exists()) {
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {}
      } else {
        keep.add(entry);
      }
    }
    await UidScopedPreferences.setString(
      prefs,
      _indexKey,
      jsonEncode(keep),
      uid: resolved,
    );
  }

  static Future<void> _register(String path, {required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = UidScopedPreferences.getString(prefs, _indexKey, uid: uid);
    final list = raw == null
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
    list.add({'path': path, 'at': DateTime.now().toIso8601String()});
    await UidScopedPreferences.setString(
      prefs,
      _indexKey,
      jsonEncode(list),
      uid: uid,
    );
  }

  static Future<void> _unregister(String path, {String? uid}) async {
    final resolved = _uid(uid);
    if (resolved == null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = UidScopedPreferences.getString(prefs, _indexKey, uid: resolved);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((e) => e['path']?.toString() != path)
        .toList();
    await UidScopedPreferences.setString(
      prefs,
      _indexKey,
      jsonEncode(list),
      uid: resolved,
    );
  }
}
