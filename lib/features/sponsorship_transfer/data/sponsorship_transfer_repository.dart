import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/sponsorship_transfer/data/sponsorship_transfer_firestore_payload.dart';
import 'package:raabta/features/sponsorship_transfer/data/transfer_document_checklist_catalog.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for transfer readiness (SharedPreferences — EOSB pattern).
class SponsorshipTransferRepository {
  SponsorshipTransferRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    await UidScopedPreferences.removeAllForUid(
      prefs,
      uid,
      LocalDataIsolationKeys.allSponsorshipKeys,
    );
  }

  String locale({String? uid}) =>
      UidScopedPreferences.getString(
        _prefs,
        LocalDataIsolationKeys.sponsorshipLocale,
        uid: uid,
      ) ??
      '';

  Future<void> saveLocale(String locale, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.sponsorshipLocale,
      locale,
      uid: uid,
    );
  }

  TransferReadinessInput? loadCachedInput({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.sponsorshipInput,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return TransferReadinessInput.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveInput(TransferReadinessInput input, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.sponsorshipInput,
      jsonEncode(input.toJson()),
      uid: uid,
    );
  }

  TransferReadinessResult? loadCachedResult({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.sponsorshipResult,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return TransferReadinessResult.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveResult(
    TransferReadinessResult result, {
    required TransferReadinessInput input,
    String? uid,
  }) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.sponsorshipResult,
      jsonEncode(result.toJson()),
      uid: uid,
    );
    await UidScopedPreferences.setBool(
      _prefs,
      LocalDataIsolationKeys.sponsorshipCheckDone,
      true,
      uid: uid,
    );
    await _syncRecordToFirestore(input: input, result: result, uid: uid);
  }

  bool hasCompletedCheck({String? uid}) {
    final resolved = UidScopedPreferences.resolveUid(uid);
    if (resolved == null) return false;

    final scopedKey = UidScopedPreferences.scopedKey(
      resolved,
      LocalDataIsolationKeys.sponsorshipCheckDone,
    );
    if (_prefs.containsKey(scopedKey)) {
      return _prefs.getBool(scopedKey) ?? false;
    }
    // Pre–UID-isolation installs (and unit tests seeding the legacy key).
    return _prefs.getBool(LocalDataIsolationKeys.sponsorshipCheckDone) ?? false;
  }

  Set<String> loadChecklistCollected({String? uid}) {
    final raw = UidScopedPreferences.getStringList(
      _prefs,
      LocalDataIsolationKeys.sponsorshipChecklist,
      uid: uid,
    );
    if (raw == null) return {};
    return raw.toSet();
  }

  Future<void> saveChecklistCollected(Set<String> ids, {String? uid}) async {
    await UidScopedPreferences.setStringList(
      _prefs,
      LocalDataIsolationKeys.sponsorshipChecklist,
      ids.toList(),
      uid: uid,
    );
    await _syncSummaryToFirestore(uid: uid);
  }

  Future<void> _syncRecordToFirestore({
    required TransferReadinessInput input,
    required TransferReadinessResult result,
    String? uid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (user == null || resolvedUid == null || user.uid != resolvedUid) {
      return;
    }

    final legalVerified =
        LegalSourcesSeedCatalog.seedLatestVerified.toIso8601String();
    final recordId = SponsorshipTransferFirestorePayload.recordIdFor(result);
    final checklist = loadChecklistCollected(uid: uid);

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.collection('transfer_readiness_checks').doc(recordId).set(
            SponsorshipTransferFirestorePayload.record(
              input: input,
              result: result,
              legalVersionVerifiedAt: legalVerified,
            ),
            SetOptions(merge: true),
          );

      await userRef.set({
        'sponsorshipTransferSummary':
            SponsorshipTransferFirestorePayload.userSummary(
          latestRecordId: recordId,
          input: input,
          result: result,
          legalVersionVerifiedAt: legalVerified,
          checklistCollectedCount: checklist.length,
          checklistTotalCount: TransferDocumentChecklistCatalog.all.length,
        ),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _syncSummaryToFirestore({String? uid}) async {
    final user = FirebaseAuth.instance.currentUser;
    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (user == null || resolvedUid == null || user.uid != resolvedUid) {
      return;
    }

    final input = loadCachedInput(uid: uid);
    final result = loadCachedResult(uid: uid);
    if (input == null || result == null) return;

    final legalVerified =
        LegalSourcesSeedCatalog.seedLatestVerified.toIso8601String();
    final checklist = loadChecklistCollected(uid: uid);

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.set({
        'sponsorshipTransferSummary':
            SponsorshipTransferFirestorePayload.userSummary(
          latestRecordId:
              SponsorshipTransferFirestorePayload.recordIdFor(result),
          input: input,
          result: result,
          legalVersionVerifiedAt: legalVerified,
          checklistCollectedCount: checklist.length,
          checklistTotalCount: TransferDocumentChecklistCatalog.all.length,
        ),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
