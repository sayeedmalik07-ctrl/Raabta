import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/scam_shield/data/scam_advisory_firestore.dart';
import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/services/firebase_service.dart';

/// One Firestore query + Hive cache (6h TTL), stale-while-revalidate.
class ScamAdvisoryRepository {
  ScamAdvisoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  static const collection = 'scam_advisories';
  static const boxName = 'scam_advisories_cache_v1';
  static const seenBoxName = 'scam_advisories_seen_v1';
  static const cachePayloadKey = 'payload_v1';
  static const cacheFetchedAtKey = 'fetched_at_v1';
  static const cacheTtl = Duration(hours: 6);
  static const queryLimit = 20;

  Box<dynamic>? _cacheBox;
  Box<dynamic>? _seenBox;
  static bool _hiveReady = false;

  @visibleForTesting
  static String? hivePathOverride;

  @visibleForTesting
  static Future<void> resetForTests() async {
    if (ScamAdvisoryRepository._hiveReady) {
      try {
        if (Hive.isBoxOpen(boxName)) await Hive.box(boxName).close();
        if (Hive.isBoxOpen(seenBoxName)) await Hive.box(seenBoxName).close();
      } catch (_) {}
    }
    _hiveReady = false;
    hivePathOverride = null;
  }

  Future<void> _ensureHive() async {
    if (_cacheBox != null && _seenBox != null) return;
    if (!_hiveReady) {
      _hiveReady = true;
      if (hivePathOverride != null) {
        Hive.init(hivePathOverride!);
      } else {
        try {
          await Hive.initFlutter();
        } catch (_) {
          Hive.init('raabta_hive');
        }
      }
    }
    if (!Hive.isBoxOpen(boxName)) {
      _cacheBox = await Hive.openBox<dynamic>(boxName);
    } else {
      _cacheBox = Hive.box(boxName);
    }
    if (!Hive.isBoxOpen(seenBoxName)) {
      _seenBox = await Hive.openBox<dynamic>(seenBoxName);
    } else {
      _seenBox = Hive.box(seenBoxName);
    }
  }

  List<ScamAdvisory> _filterActive(List<ScamAdvisory> raw) {
    final now = DateTime.now();
    return raw
        .where(
          (a) =>
              a.status == ScamAdvisoryStatus.published &&
              a.expiresAt.isAfter(now),
        )
        .toList()
      ..sort((a, b) {
        final ap = a.publishedAt ?? a.expiresAt;
        final bp = b.publishedAt ?? b.expiresAt;
        return bp.compareTo(ap);
      });
  }

  /// Hive cache only — no Firestore fetch (Phase 31 shield status).
  Future<List<ScamAdvisory>> readCachedAdvisoriesOnly() async {
    await _ensureHive();
    return _readCache() ?? const [];
  }

  Future<List<ScamAdvisory>> loadActiveAdvisories({
    bool forceRefresh = false,
  }) async {
    await _ensureHive();

    final cached = _readCache();
    final cacheFresh = cached != null && !_cacheExpired();

    if (cached != null && cacheFresh && !forceRefresh) {
      unawaited(_refreshInBackground());
      return _filterActive(cached);
    }

    if (cached != null && !forceRefresh) {
      unawaited(_refreshInBackground());
      return _filterActive(cached);
    }

    final remote = await _fetchRemote();
    if (remote != null) {
      await _writeCache(remote);
      return _filterActive(remote);
    }

    return cached != null ? _filterActive(cached) : const [];
  }

  Future<void> _refreshInBackground() async {
    try {
      final remote = await _fetchRemote();
      if (remote != null) await _writeCache(remote);
    } catch (_) {}
  }

  bool _cacheExpired() {
    final fetchedMs = _cacheBox?.get(cacheFetchedAtKey) as int?;
    if (fetchedMs == null) return true;
    return DateTime.now().millisecondsSinceEpoch - fetchedMs >
        cacheTtl.inMilliseconds;
  }

  List<ScamAdvisory>? _readCache() {
    final raw = _cacheBox?.get(cachePayloadKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw.toString()) as List<dynamic>;
      return list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        final id = map.remove('id')?.toString() ?? '';
        return ScamAdvisoryFirestore.fromDocument(id, map);
      }).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<ScamAdvisory> advisories) async {
    await _ensureHive();
    final encoded = jsonEncode(
      advisories.map((a) => {...a.toJson(), 'id': a.id}).toList(),
    );
    await _cacheBox?.put(cachePayloadKey, encoded);
    await _cacheBox?.put(
      cacheFetchedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<ScamAdvisory>?> _fetchRemote() async {
    if (!FirebaseService.isReady) return null;
    final db = _firestore ?? FirebaseFirestore.instance;
    final now = Timestamp.now();
    try {
      final snap = await db
          .collection(collection)
          .where('status', isEqualTo: 'published')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .orderBy('publishedAt', descending: true)
          .limit(queryLimit)
          .get();
      return snap.docs
          .map((d) => ScamAdvisoryFirestore.fromDocument(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('ScamAdvisoryRepository fetch failed: $e');
      return null;
    }
  }

  Future<Set<String>> loadSeenIds() async {
    await _ensureHive();
    final raw = _seenBox?.get('ids');
    if (raw is List) return raw.map((e) => e.toString()).toSet();
    return {};
  }

  Future<void> markSeen(String advisoryId) async {
    await _ensureHive();
    final seen = await loadSeenIds();
    seen.add(advisoryId);
    await _seenBox?.put('ids', seen.toList());
  }

  @visibleForTesting
  Future<void> seedCacheForTests(List<ScamAdvisory> advisories) async {
    await _writeCache(advisories);
  }
}
