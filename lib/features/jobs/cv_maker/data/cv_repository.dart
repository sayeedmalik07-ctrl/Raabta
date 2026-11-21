import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CvRepository {
  CvRepository({FirebaseFirestore? firestore, this._prefs})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  SharedPreferences? _prefs;

  static const indexKey = LocalDataIsolationKeys.cvDocumentIds;
  static const latestIdKey = LocalDataIsolationKeys.cvLatestId;
  static const documentKeyPrefix = LocalDataIsolationKeys.cvDocumentPrefix;

  static String documentBaseKey(String cvId) => '$documentKeyPrefix$cvId';

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    if (uid.isEmpty) return;
    await UidScopedPreferences.removeAllForUid(
      prefs,
      uid,
      LocalDataIsolationKeys.allCvIndexKeys,
    );
    final docPrefix = UidScopedPreferences.scopedKey(uid, documentKeyPrefix);
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(docPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  String? _resolveUid([String? uid]) => UidScopedPreferences.resolveUid(uid);

  String _localKey(String cvId, String uid) =>
      UidScopedPreferences.scopedKey(uid, documentBaseKey(cvId));

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  CollectionReference<Map<String, dynamic>>? _cvCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('cv_documents');

  Future<void> _saveLocal(CvDocument cv, {String? uid}) async {
    final resolved = _resolveUid(uid);
    if (resolved == null) return;

    final prefs = await _preferences;
    await prefs.setString(
      _localKey(cv.id, resolved),
      jsonEncode(cv.toJson()),
    );
    final ids = UidScopedPreferences.getStringList(prefs, indexKey, uid: resolved) ??
        [];
    if (!ids.contains(cv.id)) {
      ids.insert(0, cv.id);
      await UidScopedPreferences.setStringList(
        prefs,
        indexKey,
        ids.take(20).toList(),
        uid: resolved,
      );
    }
    await UidScopedPreferences.setString(
      prefs,
      latestIdKey,
      cv.id,
      uid: resolved,
    );
  }

  Future<CvDocument?> _loadLocal(String cvId, {String? uid}) async {
    final resolved = _resolveUid(uid);
    if (resolved == null) return null;

    final prefs = await _preferences;
    final raw = prefs.getString(_localKey(cvId, resolved));
    if (raw == null) return null;
    try {
      return CvDocument.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[CvRepository] local parse failed: $e');
      return null;
    }
  }

  Future<CvDocument?> load(String cvId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await _cvCollection(uid)!.doc(cvId).get();
        if (doc.exists) {
          final cv = CvDocument.fromJson({...doc.data()!, 'id': doc.id});
          await _saveLocal(cv, uid: uid);
          return cv;
        }
      } catch (e) {
        debugPrint('[CvRepository] firestore load failed: $e');
      }
    }
    return _loadLocal(cvId, uid: uid);
  }

  Future<CvDocument?> loadLatest() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final snap = await _cvCollection(uid)!
            .orderBy('updatedAt', descending: true)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          final doc = snap.docs.first;
          final cv = CvDocument.fromJson({...doc.data(), 'id': doc.id});
          await _saveLocal(cv, uid: uid);
          return cv;
        }
      } catch (e) {
        debugPrint('[CvRepository] firestore loadLatest failed: $e');
      }
    }

    if (uid == null) return null;

    final prefs = await _preferences;
    final latestId =
        UidScopedPreferences.getString(prefs, latestIdKey, uid: uid);
    if (latestId != null) {
      final local = await _loadLocal(latestId, uid: uid);
      if (local != null) return local;
    }

    final ids =
        UidScopedPreferences.getStringList(prefs, indexKey, uid: uid) ?? [];
    for (final id in ids) {
      final local = await _loadLocal(id, uid: uid);
      if (local != null) return local;
    }
    return null;
  }

  Future<void> save(CvDocument cv) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _saveLocal(cv, uid: uid);

    try {
      await _cvCollection(uid)!
          .doc(cv.id)
          .set(cv.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[CvRepository] firestore save failed (local copy kept): $e');
    }
  }

  Future<List<CvDocument>> listAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final results = <CvDocument>[];
    final seen = <String>{};

    try {
      final snap = await _cvCollection(uid)!
          .orderBy('updatedAt', descending: true)
          .get();
      for (final doc in snap.docs) {
        final cv = CvDocument.fromJson({...doc.data(), 'id': doc.id});
        results.add(cv);
        seen.add(cv.id);
        await _saveLocal(cv, uid: uid);
      }
    } catch (e) {
      debugPrint('[CvRepository] firestore listAll failed: $e');
    }

    final prefs = await _preferences;
    for (final id
        in UidScopedPreferences.getStringList(prefs, indexKey, uid: uid) ??
            []) {
      if (seen.contains(id)) continue;
      final local = await _loadLocal(id, uid: uid);
      if (local != null) results.add(local);
    }

    results.sort(
      (a, b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
    return results;
  }

  /// Saved CV PDFs in Document Vault (tagged cv/resume).
  Future<List<Map<String, dynamic>>> listVaultCvs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _firestore
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .where((d) {
          final tags = d['tags'];
          return tags is List && tags.map((e) => e.toString()).contains('cv');
        })
        .toList();
  }

  Future<bool> hasSavedCvInVault() async {
    final vault = await listVaultCvs();
    return vault.isNotEmpty;
  }

  Future<bool> hasDraftCv() async {
    final latest = await loadLatest();
    return latest != null && latest.fullName.isNotEmpty;
  }
}

final cvRepositoryProvider = Provider((ref) => CvRepository());
