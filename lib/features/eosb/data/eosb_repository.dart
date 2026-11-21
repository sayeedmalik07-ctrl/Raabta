import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_history_storage.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_history_load_outcome.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_storage_policy.dart';
import 'package:raabta/features/eosb/domain/services/overtime_salary_storage_policy.dart';
import 'package:raabta/features/eosb/domain/services/overtime_truth_engine.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef EosbCurrentAuthUserResolver = User? Function();

class EosbRepository {
  EosbRepository(
    this._prefs, {
    FirebaseFirestore? firestore,
    @visibleForTesting this._currentAuthUser,
  }) : _firestoreOverride = firestore;

  final SharedPreferences _prefs;
  final FirebaseFirestore? _firestoreOverride;
  @visibleForTesting
  final EosbCurrentAuthUserResolver? _currentAuthUser;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  User? _readCurrentAuthUser() {
    final resolver = _currentAuthUser;
    if (resolver != null) return resolver();
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// SharedPreferences keys — also read by Expat Score signal enrichment.
  static const calculationHistoryKey =
      LocalDataIsolationKeys.eosbCalculationHistory;
  static const overtimeHistoryKey = LocalDataIsolationKeys.eosbOvertimeHistory;

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    await UidScopedPreferences.removeAllForUid(
      prefs,
      uid,
      LocalDataIsolationKeys.allEosbKeys,
    );
  }

  Future<void> clearOfflineInputCache({String? uid}) async {
    await UidScopedPreferences.remove(
      _prefs,
      LocalDataIsolationKeys.eosbOfflineCache,
      uid: uid,
    );
  }

  Future<void> cacheInput(EosbEmployeeInput input, {String? uid}) async {
    if (!salaryConsent(uid: uid)) {
      await clearOfflineInputCache(uid: uid);
      return;
    }
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbOfflineCache,
      jsonEncode(input.forPersistence().toJson()),
      uid: uid,
    );
  }

  EosbEmployeeInput? loadCachedInput({String? uid}) {
    if (!salaryConsent(uid: uid)) return null;
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.eosbOfflineCache,
      uid: uid,
    );
    if (raw == null) return null;
    try {
      return EosbEmployeeInput.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<EosbCalculationHistoryLoadOutcome> loadHistoryOutcome({
    String? uid,
  }) async {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.eosbCalculationHistory,
      uid: uid,
    );
    return EosbHistoryStorage.parseCalculationHistory(raw);
  }

  Future<List<CalculationHistoryEntry>> loadHistory({String? uid}) async {
    final outcome = await loadHistoryOutcome(uid: uid);
    return outcome.records;
  }

  /// Returns [EosbHistorySaveOutcome.saved] false when no UID or write fails.
  Future<EosbHistorySaveOutcome> saveHistoryEntry(
    CalculationHistoryEntry entry, {
    String? uid,
  }) async {
    final includeSalary = salaryConsent(uid: uid);
    final persisted = EosbSalaryStoragePolicy.prepareHistoryEntry(
      entry: entry,
      includeSalaryDetails: includeSalary,
    );
    final loadOutcome = await loadHistoryOutcome(uid: uid);
    if (loadOutcome.isStorageCorrupt) {
      return const EosbHistorySaveOutcome(
        saved: false,
        includesSalaryDetails: false,
        blockedByCorruptStorage: true,
      );
    }
    final history = List<CalculationHistoryEntry>.from(loadOutcome.records);
    history.insert(0, persisted);
    final trimmed = history.take(50).toList();
    final saved = await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbCalculationHistory,
      jsonEncode(
        trimmed
            .map(
              (e) => {
                'id': e.id,
                'input': e.input.toJson(),
                'result': e.result.toJson(),
                'savedAt': e.savedAt.toIso8601String(),
                'label': e.label,
                'salaryDetailsStored': e.salaryDetailsStored,
              },
            )
            .toList(),
      ),
      uid: uid,
    );
    if (!saved) {
      return const EosbHistorySaveOutcome(
        saved: false,
        includesSalaryDetails: false,
      );
    }

    final cloudSync = await _syncToFirestore(
      persisted,
      uid: uid,
      includeSalaryDetails: includeSalary,
    );
    return EosbHistorySaveOutcome(
      saved: true,
      includesSalaryDetails: includeSalary,
      cloudSync: cloudSync,
    );
  }

  Future<EosbHistorySaveOutcome> deleteHistoryEntry(
    String id, {
    String? uid,
  }) async {
    final loadOutcome = await loadHistoryOutcome(uid: uid);
    if (loadOutcome.isStorageCorrupt) {
      return const EosbHistorySaveOutcome(
        saved: false,
        includesSalaryDetails: false,
        blockedByCorruptStorage: true,
      );
    }
    final history = List<CalculationHistoryEntry>.from(loadOutcome.records);
    history.removeWhere((e) => e.id == id);
    final saved = await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbCalculationHistory,
      jsonEncode(
        history
            .map(
              (e) => {
                'id': e.id,
                'input': e.input.toJson(),
                'result': e.result.toJson(),
                'savedAt': e.savedAt.toIso8601String(),
                'label': e.label,
                'salaryDetailsStored': e.salaryDetailsStored,
              },
            )
            .toList(),
      ),
      uid: uid,
    );
    if (!saved) {
      return const EosbHistorySaveOutcome(
        saved: false,
        includesSalaryDetails: false,
      );
    }
    return const EosbHistorySaveOutcome(
      saved: true,
      includesSalaryDetails: false,
    );
  }

  Future<EosbCloudSyncOutcome> _syncToFirestore(
    CalculationHistoryEntry entry, {
    String? uid,
    required bool includeSalaryDetails,
  }) async {
    final user = _readCurrentAuthUser();
    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (user == null || resolvedUid == null || user.uid != resolvedUid) {
      return EosbCloudSyncOutcome.skipped;
    }

    final history = (await loadHistoryOutcome(uid: uid)).records;
    final legalVerified = LegalSourcesSeedCatalog.seedLatestVerified
        .toIso8601String();

    try {
      final userRef = _firestore.collection('users').doc(user.uid);

      await userRef
          .collection('eosb_calculations')
          .doc(entry.id)
          .set(
            EosbSalaryStoragePolicy.firestoreCalculationDoc(
              entry: entry,
              legalVersionVerifiedAt: legalVerified,
              includeSalaryDetails: includeSalaryDetails,
            ),
            SetOptions(merge: true),
          );

      await userRef.set({
        'eosbSummary': EosbSalaryStoragePolicy.firestoreUserSummary(
          calculationCount: history.length,
          entry: entry,
          legalVersionVerifiedAt: legalVerified,
          includeSalaryDetails: includeSalaryDetails,
        ),
      }, SetOptions(merge: true));
      return EosbCloudSyncOutcome.succeeded;
    } catch (_) {
      return EosbCloudSyncOutcome.failed;
    }
  }

  /// Forward-only Firestore sync for Employer Track Record aggregation (Part B).
  Future<EosbCloudSyncOutcome> syncOvertimeCalculation(
    OvertimeTruthResult result, {
    String? uid,
  }) async {
    final user = _readCurrentAuthUser();
    if (user == null) return EosbCloudSyncOutcome.skipped;

    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (resolvedUid == null || user.uid != resolvedUid) {
      return EosbCloudSyncOutcome.skipped;
    }

    final includeSalary = salaryConsent(uid: uid);
    final record = result.record.forPersistence();
    final profile = record.profile;
    final employerKey = profile.effectiveNormalizedEmployerKey;
    if (includeSalary && employerKey.isEmpty) {
      return EosbCloudSyncOutcome.skipped;
    }

    try {
      final calculatedAt =
          record.updatedAt ?? record.createdAt ?? DateTime.now();
      final payload = OvertimeSalaryStoragePolicy.firestoreOvertimeDoc(
        record: record,
        calculatedAt: calculatedAt,
        violationFlagged: result.comparison.isUnderpaid,
        includeSalaryDetails: includeSalary,
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('overtime_calculations')
          .doc(record.id)
          .set(payload, SetOptions(merge: true));
      return EosbCloudSyncOutcome.succeeded;
    } catch (_) {
      return EosbCloudSyncOutcome.failed;
    }
  }

  bool salaryConsent({String? uid}) =>
      UidScopedPreferences.getBool(
        _prefs,
        LocalDataIsolationKeys.eosbSalaryConsent,
        uid: uid,
      ) ??
      false;

  Future<void> setSalaryConsent(bool value, {String? uid}) async {
    await UidScopedPreferences.setBool(
      _prefs,
      LocalDataIsolationKeys.eosbSalaryConsent,
      value,
      uid: uid,
    );
    if (!value) {
      await clearOfflineInputCache(uid: uid);
      await clearOvertimeOfflineCaches(uid: uid);
      final resolved = UidScopedPreferences.resolveUid(uid);
      if (resolved != null) {
        await DraftService.instance.clearSalarySensitiveEosbDraftsForUid(
          resolved,
        );
      }
      await _redactLocalSalaryHistories(uid: uid);
      await _redactCloudSalaryFields(uid: uid);
    }
  }

  Future<void> _redactLocalSalaryHistories({String? uid}) async {
    final calcOutcome = await loadHistoryOutcome(uid: uid);
    if (!calcOutcome.isStorageCorrupt &&
        calcOutcome.records.any((e) => e.salaryDetailsStored)) {
      final redacted = calcOutcome.records
          .map(
            (e) => EosbSalaryStoragePolicy.prepareHistoryEntry(
              entry: e,
              includeSalaryDetails: false,
            ),
          )
          .toList();
      await UidScopedPreferences.setString(
        _prefs,
        LocalDataIsolationKeys.eosbCalculationHistory,
        jsonEncode(
          redacted
              .map(
                (e) => {
                  'id': e.id,
                  'input': e.input.toJson(),
                  'result': e.result.toJson(),
                  'savedAt': e.savedAt.toIso8601String(),
                  'label': e.label,
                  'salaryDetailsStored': e.salaryDetailsStored,
                },
              )
              .toList(),
        ),
        uid: uid,
      );
    }

    final otOutcome = loadOvertimeHistoryOutcome(uid: uid);
    if (!otOutcome.isStorageCorrupt &&
        otOutcome.records.any((r) => r.salaryDetailsStored)) {
      final redacted = otOutcome.records
          .map(
            (r) => OvertimeSalaryStoragePolicy.redactRecord(
              r.forPersistence(),
            ).copyWith(isFavorite: r.isFavorite, updatedAt: r.updatedAt),
          )
          .toList();
      await UidScopedPreferences.setString(
        _prefs,
        LocalDataIsolationKeys.eosbOvertimeHistory,
        jsonEncode(redacted.map((r) => r.toJson()).toList()),
        uid: uid,
      );
    }
  }

  Future<void> _redactCloudSalaryFields({String? uid}) async {
    final user = _readCurrentAuthUser();
    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (user == null || resolvedUid == null || user.uid != resolvedUid) {
      return;
    }

    final legalVerified = LegalSourcesSeedCatalog.seedLatestVerified
        .toIso8601String();
    final userRef = _firestore.collection('users').doc(user.uid);

    final calcOutcome = await loadHistoryOutcome(uid: uid);
    if (!calcOutcome.isStorageCorrupt && calcOutcome.records.isNotEmpty) {
      try {
        for (final entry in calcOutcome.records) {
          await userRef
              .collection('eosb_calculations')
              .doc(entry.id)
              .set(
                EosbSalaryStoragePolicy.firestoreCalculationDoc(
                  entry: entry,
                  legalVersionVerifiedAt: legalVerified,
                  includeSalaryDetails: false,
                ),
                SetOptions(merge: true),
              );
        }
        await userRef.set({
          'eosbSummary': EosbSalaryStoragePolicy.firestoreUserSummary(
            calculationCount: calcOutcome.records.length,
            entry: calcOutcome.records.first,
            legalVersionVerifiedAt: legalVerified,
            includeSalaryDetails: false,
          ),
        }, SetOptions(merge: true));
      } catch (_) {
        // Best-effort cloud redaction; local history already redacted.
      }
    }

    final otOutcome = loadOvertimeHistoryOutcome(uid: uid);
    if (!otOutcome.isStorageCorrupt && otOutcome.records.isNotEmpty) {
      try {
        for (final record in otOutcome.records) {
          await userRef
              .collection('overtime_calculations')
              .doc(record.id)
              .set(
                OvertimeSalaryStoragePolicy.firestoreOvertimeSalaryRevocationPatch(),
                SetOptions(merge: true),
              );
        }
      } catch (_) {
        // Best-effort cloud redaction.
      }
    }
  }

  Future<void> clearOvertimeOfflineCaches({String? uid}) async {
    await UidScopedPreferences.remove(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeInput,
      uid: uid,
    );
    await UidScopedPreferences.remove(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeResult,
      uid: uid,
    );
  }

  Future<void> cacheOvertimeInput(
    OvertimeTruthInput input, {
    String? uid,
  }) async {
    if (!salaryConsent(uid: uid)) {
      await clearOvertimeOfflineCaches(uid: uid);
      return;
    }
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeInput,
      jsonEncode(input.forPersistence().toJson()),
      uid: uid,
    );
  }

  OvertimeTruthInput? loadCachedOvertimeInput({String? uid}) {
    if (!salaryConsent(uid: uid)) return null;
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeInput,
      uid: uid,
    );
    if (raw == null) return null;
    try {
      return OvertimeTruthInput.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOvertimeResult(
    OvertimeTruthResult result, {
    String? uid,
  }) async {
    if (!salaryConsent(uid: uid)) {
      await UidScopedPreferences.remove(
        _prefs,
        LocalDataIsolationKeys.eosbOvertimeResult,
        uid: uid,
      );
      return;
    }
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeResult,
      jsonEncode(result.toJson()),
      uid: uid,
    );
  }

  OvertimeTruthResult? loadCachedOvertimeResult({String? uid}) {
    if (!salaryConsent(uid: uid)) return null;
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeResult,
      uid: uid,
    );
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['record'] != null) {
        final record = OvertimeMonthlyRecord.fromJson(
          map['record'] as Map<String, dynamic>,
        );
        return OvertimeTruthEngine.calculateRecord(record);
      }
      final input = loadCachedOvertimeInput(uid: uid);
      if (input != null) return OvertimeTruthEngine.calculate(input);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns [EosbHistorySaveOutcome.saved] false when no UID or write fails.
  Future<EosbHistorySaveOutcome> saveOvertimeHistory(
    List<OvertimeMonthlyRecord> records, {
    String? uid,
  }) async {
    final includeSalary = salaryConsent(uid: uid);
    final existingOutcome = loadOvertimeHistoryOutcome(uid: uid);
    if (existingOutcome.isStorageCorrupt) {
      return const EosbHistorySaveOutcome(
        saved: false,
        includesSalaryDetails: false,
        blockedByCorruptStorage: true,
      );
    }
    final existing = existingOutcome.records;
    final existingById = {for (final r in existing) r.id: r};
    final persisted = OvertimeSalaryStoragePolicy.prepareHistoryList(
      records: records,
      includeSalaryDetails: includeSalary,
      existingById: existingById,
    );
    final saved = await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeHistory,
      jsonEncode(persisted.map((r) => r.toJson()).toList()),
      uid: uid,
    );
    if (!saved) {
      return const EosbHistorySaveOutcome(
        saved: false,
        includesSalaryDetails: false,
      );
    }
    return EosbHistorySaveOutcome(
      saved: true,
      includesSalaryDetails: includeSalary,
    );
  }

  OvertimeHistoryLoadOutcome loadOvertimeHistoryOutcome({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeHistory,
      uid: uid,
    );
    return EosbHistoryStorage.parseOvertimeHistory(raw);
  }

  List<OvertimeMonthlyRecord> loadOvertimeHistory({String? uid}) {
    return loadOvertimeHistoryOutcome(uid: uid).records;
  }
}
