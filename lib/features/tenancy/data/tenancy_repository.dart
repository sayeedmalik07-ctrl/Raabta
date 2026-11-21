import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/tenancy/data/tenancy_dispute_checklist_catalog.dart';
import 'package:raabta/features/tenancy/data/tenancy_firestore_payload.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_claim_basis_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for tenancy lease entries (SharedPreferences — EOSB pattern).
class TenancyRepository {
  TenancyRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    await UidScopedPreferences.removeAllForUid(
      prefs,
      uid,
      LocalDataIsolationKeys.allTenancyKeys,
    );
  }

  String locale({String? uid}) =>
      UidScopedPreferences.getString(
        _prefs,
        LocalDataIsolationKeys.tenancyLocale,
        uid: uid,
      ) ??
      '';

  Future<void> saveLocale(String locale, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.tenancyLocale,
      locale,
      uid: uid,
    );
  }

  TenancyLeaseInput? loadCachedInput({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.tenancyLeaseInput,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return TenancyLeaseInput.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveInput(TenancyLeaseInput input, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.tenancyLeaseInput,
      jsonEncode(input.toJson()),
      uid: uid,
    );
  }

  TenancyComplianceResult? loadCachedResult({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.tenancyComplianceResult,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return TenancyComplianceResult.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveResult(
    TenancyComplianceResult result, {
    required TenancyLeaseInput input,
    String? uid,
  }) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.tenancyComplianceResult,
      jsonEncode(result.toJson()),
      uid: uid,
    );
    await UidScopedPreferences.setBool(
      _prefs,
      LocalDataIsolationKeys.tenancyCheckCompleted,
      true,
      uid: uid,
    );
    await _syncRecordToFirestore(input: input, result: result, uid: uid);
  }

  bool hasCompletedCheck({String? uid}) =>
      UidScopedPreferences.getBool(
        _prefs,
        LocalDataIsolationKeys.tenancyCheckCompleted,
        uid: uid,
      ) ??
      false;

  Set<String> loadChecklistCollected({String? uid}) {
    final raw = UidScopedPreferences.getStringList(
      _prefs,
      LocalDataIsolationKeys.tenancyChecklist,
      uid: uid,
    );
    if (raw == null) return {};
    return raw.toSet();
  }

  Future<void> saveChecklistCollected(Set<String> ids, {String? uid}) async {
    await UidScopedPreferences.setStringList(
      _prefs,
      LocalDataIsolationKeys.tenancyChecklist,
      ids.toList(),
      uid: uid,
    );
  }

  DisputePacketMetadata? loadLastPacketMetadata({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.tenancyPacketMeta,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return DisputePacketMetadata.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> savePacketMetadata(
    DisputePacketMetadata meta, {
    String? uid,
  }) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.tenancyPacketMeta,
      jsonEncode(meta.toJson()),
      uid: uid,
    );
    await _syncPacketToFirestore(meta, uid: uid);
  }

  Future<void> _syncRecordToFirestore({
    required TenancyLeaseInput input,
    required TenancyComplianceResult result,
    String? uid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (user == null || resolvedUid == null || user.uid != resolvedUid) {
      return;
    }

    final legalVerified =
        LegalSourcesSeedCatalog.seedLatestVerified.toIso8601String();
    final recordId = TenancyFirestorePayload.recordIdFor(result);
    final checklist = loadChecklistCollected(uid: uid);

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.collection('tenancy_records').doc(recordId).set(
            TenancyFirestorePayload.record(
              input: input,
              result: result,
              legalVersionVerifiedAt: legalVerified,
            ),
            SetOptions(merge: true),
          );

      await userRef.set({
        'tenancySummary': TenancyFirestorePayload.userSummary(
          latestRecordId: recordId,
          input: input,
          result: result,
          legalVersionVerifiedAt: legalVerified,
          checklistCollectedCount: checklist.length,
          checklistTotalCount: TenancyDisputeChecklistCatalog.items.length,
          latestPacketGeneratedAt: loadLastPacketMetadata(uid: uid)?.generatedAt,
        ),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _syncPacketToFirestore(
    DisputePacketMetadata meta, {
    String? uid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (user == null || resolvedUid == null || user.uid != resolvedUid) {
      return;
    }

    final legalVerified =
        LegalSourcesSeedCatalog.seedLatestVerified.toIso8601String();
    final packetId = TenancyFirestorePayload.packetIdFor(meta);

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.collection('tenancy_dispute_packets').doc(packetId).set(
            TenancyFirestorePayload.disputePacket(
              meta: meta,
              legalVersionVerifiedAt: legalVerified,
            ),
            SetOptions(merge: true),
          );

      final input = loadCachedInput(uid: uid);
      final result = loadCachedResult(uid: uid);
      if (input != null && result != null) {
        await userRef.set({
          'tenancySummary': TenancyFirestorePayload.userSummary(
            latestRecordId: TenancyFirestorePayload.recordIdFor(result),
            input: input,
            result: result,
            legalVersionVerifiedAt: legalVerified,
            checklistCollectedCount: meta.collectedItemIds.length,
            checklistTotalCount: TenancyDisputeChecklistCatalog.items.length,
            latestPacketGeneratedAt: meta.generatedAt,
          ),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }
}
