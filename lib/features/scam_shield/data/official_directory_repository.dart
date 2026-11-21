import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_models.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bundled asset + optional Firestore override (`official_directory/config`).
class OfficialDirectoryRepository {
  OfficialDirectoryRepository({
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _firestore = firestore,
        _prefs = prefs;

  final FirebaseFirestore? _firestore;
  SharedPreferences? _prefs;

  static const assetPath = 'assets/official_directory.json';
  static const firestoreDocPath = 'official_directory/config';
  static const cacheKey = 'official_directory_cache_v1';
  static const cacheVersionKey = 'official_directory_cache_version_v1';
  static const cacheExpiryKey = 'official_directory_cache_expiry_v1';
  static const cacheTtl = Duration(hours: 24);

  Future<OfficialDirectorySnapshot> loadEffectiveSnapshot() async {
    final bundled = await _loadBundled();
    OfficialDirectory.applySnapshot(bundled);

    _prefs ??= await SharedPreferences.getInstance();
    final cached = _readCachedSnapshot();
    if (cached != null && cached.version > bundled.version) {
      OfficialDirectory.applySnapshot(cached);
    }

    final remote = await _fetchRemoteIfStale();
    if (remote != null) {
      OfficialDirectory.applySnapshot(remote);
      await _writeCache(remote);
    }

    return OfficialDirectory.snapshot;
  }

  Future<OfficialDirectorySnapshot> _loadBundled() async {
    final raw = await rootBundle.loadString(assetPath);
    return _parseSnapshot(jsonDecode(raw) as Map<String, dynamic>);
  }

  OfficialDirectorySnapshot? _readCachedSnapshot() {
    final prefs = _prefs;
    if (prefs == null) return null;
    final expiryMs = prefs.getInt(cacheExpiryKey);
    if (expiryMs == null || DateTime.now().millisecondsSinceEpoch > expiryMs) {
      return null;
    }
    final jsonStr = prefs.getString(cacheKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return _parseSnapshot(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(OfficialDirectorySnapshot snapshot) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(
      cacheKey,
      jsonEncode({
        'version': snapshot.version,
        'entries': snapshot.entries.map((e) => e.toJson()).toList(),
      }),
    );
    await prefs.setInt(cacheVersionKey, snapshot.version);
    await prefs.setInt(
      cacheExpiryKey,
      DateTime.now().add(cacheTtl).millisecondsSinceEpoch,
    );
  }

  Future<OfficialDirectorySnapshot?> _fetchRemoteIfStale() async {
    if (!FirebaseService.isReady) return null;
    final db = _firestore ?? FirebaseFirestore.instance;
    try {
      final doc = await db.doc(firestoreDocPath).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return _parseSnapshot(data);
    } catch (_) {
      return null;
    }
  }

  OfficialDirectorySnapshot _parseSnapshot(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt() ?? 0;
    final entriesRaw = json['entries'] as List<dynamic>? ?? [];
    final entries = entriesRaw
        .whereType<Map<String, dynamic>>()
        .map(OfficialDirectoryEntry.fromJson)
        .where((e) => e.id.isNotEmpty)
        .toList();
    return OfficialDirectorySnapshot(version: version, entries: entries);
  }
}
