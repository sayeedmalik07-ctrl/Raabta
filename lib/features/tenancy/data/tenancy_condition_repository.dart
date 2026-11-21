import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline-first persistence for property condition records.
class TenancyConditionRepository {
  TenancyConditionRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    await UidScopedPreferences.removeAllWithBasePrefixForUid(
      prefs,
      uid,
      'tenancy_condition_records_v1_',
    );
  }

  String _cacheKey(String uid, String leaseId) =>
      UidScopedPreferences.scopedKey(
        uid,
        LocalDataIsolationKeys.tenancyConditionRecords(leaseId),
      );

  List<TenancyConditionRecord> loadLocalForLease(
    String leaseId, {
    String? uid,
  }) {
    final resolved = UidScopedPreferences.resolveUid(uid);
    if (resolved == null || leaseId.isEmpty) return [];
    final raw = _prefs.getString(_cacheKey(resolved, leaseId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TenancyConditionRecord.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalForLease(
    String leaseId,
    List<TenancyConditionRecord> records, {
    String? uid,
  }) async {
    final resolved = UidScopedPreferences.resolveUid(uid);
    if (resolved == null || leaseId.isEmpty) return;
    await _prefs.setString(
      _cacheKey(resolved, leaseId),
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tenancy_condition_records');

  Future<List<TenancyConditionRecord>> fetchForLease(String leaseId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || leaseId.isEmpty) {
      return loadLocalForLease(leaseId, uid: uid);
    }

    try {
      final snap = await _collection(uid)
          .where('leaseId', isEqualTo: leaseId)
          .get();
      final records = snap.docs
          .map(
            (doc) => TenancyConditionRecord.fromJson({
              ...doc.data(),
              'recordId': doc.id,
            }),
          )
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      await _saveLocalForLease(leaseId, records, uid: uid);
      return records;
    } catch (_) {
      return loadLocalForLease(leaseId, uid: uid);
    }
  }

  TenancyConditionRecord? findByType(
    List<TenancyConditionRecord> records,
    TenancyConditionRecordType type,
  ) {
    for (final r in records.reversed) {
      if (r.recordType == type) return r;
    }
    return null;
  }

  Future<TenancyConditionRecord> upsert(TenancyConditionRecord record) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? record.userId;
    if (uid.isEmpty) throw StateError('User must be signed in');

    final ref = record.recordId.isNotEmpty
        ? _collection(uid).doc(record.recordId)
        : _collection(uid).doc();
    final now = DateTime.now();
    final saved = record.copyWith(
      recordId: ref.id,
      userId: uid,
      updatedAt: now,
      createdAt: record.recordId.isEmpty ? now : record.createdAt,
    );

    await ref.set(saved.toJson(), SetOptions(merge: true));

    final local = loadLocalForLease(saved.leaseId, uid: uid);
    local.removeWhere((r) => r.recordId == saved.recordId);
    local.add(saved);
    local.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    await _saveLocalForLease(saved.leaseId, local, uid: uid);

    return saved;
  }

  Future<void> updateComparisonNotes({
    required TenancyConditionRecord moveOutRecord,
    required Map<String, String> notes,
  }) async {
    await upsert(
      moveOutRecord.copyWith(
        roomComparisonNotes: notes,
        updatedAt: DateTime.now(),
      ),
    );
  }

  bool hasRecordForLease(
    List<TenancyConditionRecord> records,
    TenancyConditionRecordType type,
  ) =>
      findByType(records, type) != null;
}
