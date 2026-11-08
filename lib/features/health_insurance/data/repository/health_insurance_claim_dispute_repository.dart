import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline-first persistence for claim denial disputes.
class HealthInsuranceClaimDisputeRepository {
  HealthInsuranceClaimDisputeRepository(this._prefs);

  final SharedPreferences _prefs;

  static const cacheKey = LocalDataIsolationKeys.hiClaimDispute;
  static const activeIdKey = LocalDataIsolationKeys.hiClaimDisputeActiveId;

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    await UidScopedPreferences.remove(prefs, cacheKey, uid: uid);
    await UidScopedPreferences.remove(prefs, activeIdKey, uid: uid);
  }

  HealthInsuranceClaimDispute? loadCached({String? uid}) {
    final raw = UidScopedPreferences.getString(_prefs, cacheKey, uid: uid);
    if (raw == null || raw.isEmpty) return null;
    try {
      return HealthInsuranceClaimDispute.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  String? activeDisputeId({String? uid}) =>
      UidScopedPreferences.getString(_prefs, activeIdKey, uid: uid);

  Future<void> saveLocal(
    HealthInsuranceClaimDispute dispute, {
    String? uid,
  }) async {
    await UidScopedPreferences.setString(
      _prefs,
      cacheKey,
      jsonEncode(dispute.toJson()),
      uid: uid,
    );
    await UidScopedPreferences.setString(
      _prefs,
      activeIdKey,
      dispute.disputeId,
      uid: uid,
    );
  }

  Future<void> clearLocal({String? uid}) async {
    await UidScopedPreferences.remove(_prefs, cacheKey, uid: uid);
    await UidScopedPreferences.remove(_prefs, activeIdKey, uid: uid);
  }

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('health_insurance_claim_disputes');

  Future<HealthInsuranceClaimDispute> upsert(
    HealthInsuranceClaimDispute dispute,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? dispute.userId;
    if (uid.isEmpty) {
      await saveLocal(dispute);
      return dispute;
    }

    final ref = dispute.disputeId.isNotEmpty
        ? _collection(uid).doc(dispute.disputeId)
        : _collection(uid).doc();
    final now = DateTime.now();
    final saved = dispute.copyWith(
      disputeId: ref.id,
      userId: uid,
      updatedAt: now,
      createdAt: dispute.disputeId.isEmpty ? now : dispute.createdAt,
    );

    await ref.set(saved.toJson(), SetOptions(merge: true));
    await saveLocal(saved, uid: uid);
    return saved;
  }

  Future<HealthInsuranceClaimDispute?> fetchLatest(String userId) async {
    if (userId.isEmpty) return loadCached();

    try {
      final snapshot = await _collection(userId)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return loadCached(uid: userId);
      final remote = HealthInsuranceClaimDispute.fromJson({
        ...snapshot.docs.first.data(),
        'disputeId': snapshot.docs.first.id,
      });
      await saveLocal(remote, uid: userId);
      return remote;
    } catch (_) {
      return loadCached(uid: userId);
    }
  }

  Future<HealthInsuranceClaimDispute> toggleStep({
    required HealthInsuranceClaimDispute dispute,
    required String stepId,
    required bool complete,
  }) async {
    final steps = Map<String, String>.from(dispute.completedSteps);
    if (complete) {
      steps[stepId] = DateTime.now().toIso8601String();
    } else {
      steps.remove(stepId);
    }
    return upsert(
      dispute.copyWith(
        completedSteps: steps,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<HealthInsuranceClaimDispute> attachDocument({
    required HealthInsuranceClaimDispute dispute,
    required String checklistItemId,
    required String documentId,
  }) async {
    final refs = Map<String, String>.from(dispute.documentRefs);
    refs[checklistItemId] = documentId;
    return upsert(
      dispute.copyWith(
        documentRefs: refs,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
