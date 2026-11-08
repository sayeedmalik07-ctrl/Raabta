import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/overtime_truth_engine.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EosbRepository {
  EosbRepository(this._prefs);

  final SharedPreferences _prefs;

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

  Future<void> cacheInput(EosbEmployeeInput input, {String? uid}) async {
    if (!input.storeSalaryWithConsent) {
      await UidScopedPreferences.remove(
        _prefs,
        LocalDataIsolationKeys.eosbOfflineCache,
        uid: uid,
      );
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

  Future<List<CalculationHistoryEntry>> loadHistory({String? uid}) async {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.eosbCalculationHistory,
      uid: uid,
    );
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return CalculationHistoryEntry(
          id: map['id'] as String? ?? '',
          input: EosbEmployeeInput.fromJson(
            map['input'] as Map<String, dynamic>,
          ),
          result: EosbResult.fromJson(
            map['result'] as Map<String, dynamic>,
          ),
          savedAt: DateTime.tryParse(map['savedAt'] as String? ?? '') ??
              DateTime.now(),
          label: map['label'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists locally under UID-scoped [calculationHistoryKey].
  ///
  /// Returns `false` when no UID is available or SharedPreferences write fails.
  Future<bool> saveHistoryEntry(
    CalculationHistoryEntry entry, {
    String? uid,
  }) async {
    final persisted = CalculationHistoryEntry(
      id: entry.id,
      input: entry.input.forPersistence(),
      result: entry.result,
      savedAt: entry.savedAt,
      label: entry.label,
    );
    final history = await loadHistory(uid: uid);
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
              },
            )
            .toList(),
      ),
      uid: uid,
    );
    if (!saved) return false;

    await _syncToFirestore(persisted, uid: uid);
    return true;
  }

  Future<void> deleteHistoryEntry(String id, {String? uid}) async {
    final history = await loadHistory(uid: uid);
    history.removeWhere((e) => e.id == id);
    await UidScopedPreferences.setString(
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
              },
            )
            .toList(),
      ),
      uid: uid,
    );
  }

  Future<void> _syncToFirestore(
    CalculationHistoryEntry entry, {
    String? uid,
  }) async {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      return;
    }
    final resolvedUid = UidScopedPreferences.resolveUid(uid);
    if (user == null || resolvedUid == null || user.uid != resolvedUid) {
      return;
    }

    final history = await loadHistory(uid: uid);
    final legalVerified =
        LegalSourcesSeedCatalog.seedLatestVerified.toIso8601String();

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.collection('eosb_calculations').doc(entry.id).set({
        'companyName': entry.input.companyName,
        'normalizedEmployerKey': entry.input.effectiveNormalizedEmployerKey,
        'totalEntitlement': entry.result.totalEntitlement,
        'calculatedAt': entry.result.calculatedAt.toIso8601String(),
        'legalVersionVerifiedAt': legalVerified,
        'contractType': entry.input.contractType.name,
        'contractEndDate': entry.input.lastWorkingDate?.toIso8601String(),
        'joiningDate': entry.input.joiningDate?.toIso8601String(),
        'employerOffer': entry.input.employerOffer,
        'label': entry.label,
        'hasSalaryData': entry.input.storeSalaryWithConsent,
        'violationRuleKeys':
            entry.result.violations.map((v) => v.ruleKey).toList(),
        'violationTitleKeys':
            entry.result.violations.map((v) => v.titleKey).toList(),
        'engineSource': 'eosb',
      }, SetOptions(merge: true));

      await userRef.set({
        'eosbSummary': {
          'calculationCount': history.length,
          'latestCalculationId': entry.id,
          'latestCalculatedAt': entry.result.calculatedAt.toIso8601String(),
          'legalVersionVerifiedAt': legalVerified,
          'contractEndDate': entry.input.lastWorkingDate?.toIso8601String(),
          'contractType': entry.input.contractType.name,
          'joiningDate': entry.input.joiningDate?.toIso8601String(),
        },
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Forward-only Firestore sync for Employer Track Record aggregation (Part B).
  Future<void> syncOvertimeCalculation(OvertimeTruthResult result) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final record = result.record.forPersistence();
    final profile = record.profile;
    final employerKey = profile.effectiveNormalizedEmployerKey;
    if (employerKey.isEmpty) return;

    try {
      final calculatedAt =
          record.updatedAt ?? record.createdAt ?? DateTime.now();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('overtime_calculations')
          .doc(record.id)
          .set({
        'companyName': profile.companyName,
        'normalizedEmployerKey': employerKey,
        'calculatedAt': calculatedAt.toIso8601String(),
        'violationFlagged': result.comparison.isUnderpaid,
        'engineSource': 'overtime',
        'year': record.year,
        'month': record.month,
      }, SetOptions(merge: true));
    } catch (_) {}
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
  }

  String locale({String? uid}) =>
      UidScopedPreferences.getString(
        _prefs,
        LocalDataIsolationKeys.eosbLocale,
        uid: uid,
      ) ??
      '';

  Future<void> setLocale(String locale, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbLocale,
      locale,
      uid: uid,
    );
  }

  Future<void> cacheOvertimeInput(
    OvertimeTruthInput input, {
    String? uid,
  }) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeInput,
      jsonEncode(input.forPersistence().toJson()),
      uid: uid,
    );
  }

  OvertimeTruthInput? loadCachedOvertimeInput({String? uid}) {
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
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeResult,
      jsonEncode(result.toJson()),
      uid: uid,
    );
  }

  OvertimeTruthResult? loadCachedOvertimeResult({String? uid}) {
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

  Future<void> saveOvertimeHistory(
    List<OvertimeMonthlyRecord> records, {
    String? uid,
  }) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeHistory,
      jsonEncode(records.map((r) => r.forPersistence().toJson()).toList()),
      uid: uid,
    );
  }

  List<OvertimeMonthlyRecord> loadOvertimeHistory({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.eosbOvertimeHistory,
      uid: uid,
    );
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => OvertimeMonthlyRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
