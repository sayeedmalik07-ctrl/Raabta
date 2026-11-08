import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/data/moph_insurer_lookup_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local + optional Firestore persistence for health insurance compliance data.
class HealthInsuranceRepository {
  HealthInsuranceRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<void> purgeLocalDataForUser(
    SharedPreferences prefs,
    String uid,
  ) async {
    await UidScopedPreferences.removeAllForUid(
      prefs,
      uid,
      LocalDataIsolationKeys.allHealthInsuranceKeys,
    );
  }

  String locale({String? uid}) =>
      UidScopedPreferences.getString(
        _prefs,
        LocalDataIsolationKeys.hiLocale,
        uid: uid,
      ) ??
      '';

  Future<void> saveLocale(String locale, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.hiLocale,
      locale,
      uid: uid,
    );
  }

  InsuranceComplianceInput? loadCachedInput({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.hiComplianceInput,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return InsuranceComplianceInput.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveInput(InsuranceComplianceInput input, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.hiComplianceInput,
      jsonEncode(input.toJson()),
      uid: uid,
    );
  }

  ComplianceCheckResult? loadCachedResult({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.hiComplianceResult,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return ComplianceCheckResult.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveResult(ComplianceCheckResult result, {String? uid}) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.hiComplianceResult,
      jsonEncode(result.toJson()),
      uid: uid,
    );
    await UidScopedPreferences.setBool(
      _prefs,
      LocalDataIsolationKeys.hiComplianceDone,
      true,
      uid: uid,
    );
  }

  /// Forward-only Firestore sync for Employer Track Record aggregation (Part B).
  Future<void> syncComplianceCheckToFirestore({
    required ComplianceCheckResult result,
    required String companyName,
    required String normalizedEmployerKey,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final employerKey = normalizedEmployerKey.trim();
    if (employerKey.isEmpty) return;

    try {
      final checkId = result.checkedAt.toUtc().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_insurance_compliance_checks')
          .doc(checkId)
          .set({
        'companyName': companyName.trim(),
        'normalizedEmployerKey': employerKey,
        'calculatedAt': result.checkedAt.toIso8601String(),
        'violationFlagged': result.hasUnresolvedViolation,
        'hasUnresolvedViolation': result.hasUnresolvedViolation,
        'engineSource': 'health_insurance',
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  bool hasCompletedComplianceCheck({String? uid}) =>
      UidScopedPreferences.getBool(
        _prefs,
        LocalDataIsolationKeys.hiComplianceDone,
        uid: uid,
      ) ??
      false;

  /// Last time the user opened the Health Insurance dashboard (instrumentation).
  DateTime? lastOpenedAt({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.hiLastOpened,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> recordLastOpened([DateTime? when, String? uid]) async {
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.hiLastOpened,
      (when ?? DateTime.now()).toIso8601String(),
      uid: uid,
    );
  }

  /// Best available "last reviewed" signal for cross-engine correlation.
  DateTime? lastReviewedAt({String? uid}) {
    final opened = lastOpenedAt(uid: uid);
    final checked = loadCachedResult(uid: uid)?.checkedAt;
    if (opened == null) return checked;
    if (checked == null) return opened;
    return opened.isAfter(checked) ? opened : checked;
  }

  bool hasUnresolvedViolation({String? uid}) {
    final result = loadCachedResult(uid: uid);
    return result?.hasUnresolvedViolation ?? false;
  }

  List<InsurerSwitchRecord> loadInsurerHistory({String? uid}) {
    final raw = UidScopedPreferences.getString(
      _prefs,
      LocalDataIsolationKeys.hiInsurerHistory,
      uid: uid,
    );
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => InsurerSwitchRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertInsurerHistory(
    InsurerSwitchRecord record, {
    String? uid,
  }) async {
    final history = loadInsurerHistory(uid: uid);
    history.removeWhere((r) => r.renewalYear == record.renewalYear);
    history.add(record);
    history.sort((a, b) => b.renewalYear.compareTo(a.renewalYear));
    await UidScopedPreferences.setString(
      _prefs,
      LocalDataIsolationKeys.hiInsurerHistory,
      jsonEncode(history.map((e) => e.toJson()).toList()),
      uid: uid,
    );
  }

  /// Firestore override for MOPH insurer + TPA/plan lookup (legal_sources pattern).
  Future<MophInsurerLookupSnapshot> fetchMophInsurerSnapshot({
    FirebaseFirestore? firestore,
  }) async {
    try {
      final doc = await (firestore ?? FirebaseFirestore.instance)
          .collection('legal_sources')
          .doc(MophInsurerLookupCatalog.firestoreDocId)
          .get();
      if (!doc.exists) {
        return _seedSnapshot();
      }
      final data = doc.data() ?? {};
      final insurers = (data['insurers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          MophInsurerLookupCatalog.defaultInsurers;

      final aliasesRaw = data['insurerAliases'] as Map<String, dynamic>?;
      final aliases = aliasesRaw != null
          ? aliasesRaw.map((k, v) => MapEntry(k.toString(), v.toString()))
          : Map<String, String>.from(MophInsurerLookupCatalog.defaultInsurerAliases);

      final tpaRaw = data['tpaMappings'] as List<dynamic>? ?? [];
      final tpaMappings = tpaRaw.isNotEmpty
          ? tpaRaw
              .map((e) => TpaOrPlanMapping.fromFirestore(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : MophInsurerLookupCatalog.defaultTpaMappings;

      final verified = _parseVerifiedDate(data['dateLastVerified']);

      final regulatoryRaw = data['insurerRegulatoryBodies'] as Map<String, dynamic>?;
      final regulatoryBodies = regulatoryRaw != null
          ? regulatoryRaw.map((k, v) => MapEntry(k.toString(), v.toString()))
          : Map<String, String>.from(
              MophInsurerLookupCatalog.defaultInsurerRegulatoryBodies,
            );

      final qfcRaw = data['qfcRegisteredInsurers'] as List<dynamic>?;
      final qfcInsurers = qfcRaw?.map((e) => e.toString()).toList() ??
          MophInsurerLookupCatalog.defaultQfcRegisteredInsurers;

      return MophInsurerLookupSnapshot(
        insurers: insurers,
        insurerAliases: aliases,
        tpaMappings: tpaMappings,
        lastVerified: verified ?? MophInsurerLookupCatalog.seedLastVerified,
        insurerRegulatoryBodies: regulatoryBodies,
        qfcRegisteredInsurers: qfcInsurers,
      );
    } catch (_) {
      return _seedSnapshot();
    }
  }

  Future<void> saveMophInsurerSnapshot(MophInsurerLookupSnapshot snapshot) async {
    await FirebaseFirestore.instance
        .collection('legal_sources')
        .doc(MophInsurerLookupCatalog.firestoreDocId)
        .set({
      'insurers': snapshot.insurers,
      'insurerAliases': snapshot.insurerAliases,
      'tpaMappings': snapshot.tpaMappings.map((e) => e.toFirestore()).toList(),
      'insurerRegulatoryBodies': snapshot.insurerRegulatoryBodies,
      'qfcRegisteredInsurers': snapshot.qfcRegisteredInsurers,
      'dateLastVerified': snapshot.lastVerified.toIso8601String(),
    }, SetOptions(merge: true));
  }

  MophInsurerLookupSnapshot _seedSnapshot() => MophInsurerLookupSnapshot(
        insurers: MophInsurerLookupCatalog.defaultInsurers,
        insurerAliases: Map<String, String>.from(
          MophInsurerLookupCatalog.defaultInsurerAliases,
        ),
        tpaMappings: MophInsurerLookupCatalog.defaultTpaMappings,
        lastVerified: MophInsurerLookupCatalog.seedLastVerified,
        insurerRegulatoryBodies: Map<String, String>.from(
          MophInsurerLookupCatalog.defaultInsurerRegulatoryBodies,
        ),
        qfcRegisteredInsurers:
            MophInsurerLookupCatalog.defaultQfcRegisteredInsurers,
      );

  DateTime? _parseVerifiedDate(Object? verifiedRaw) {
    if (verifiedRaw is Timestamp) return verifiedRaw.toDate();
    if (verifiedRaw is String) return DateTime.tryParse(verifiedRaw);
    return null;
  }
}
