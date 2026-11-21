import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_storage_policy.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/bill_tracker_repository.dart';
import 'package:raabta/features/visa/data/deadline_tracker_repository.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/ai/expat_score_live_calculator.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads live repository snapshots for [ExpatScoreLiveCalculator].
abstract final class ExpatScoreLiveInputsLoader {
  static Future<ExpatScoreLiveInputs> load({
    required UserAIProfile profile,
    required String? storageUid,
    required EosbRepository eosbRepository,
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
    BillTrackerRepository? billRepository,
    DeadlineTrackerRepository? deadlineRepo,
  }) async {
    final db =
        firestore ??
        (FirebaseService.isReady ? FirebaseFirestore.instance : null);
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    final billsRepo = billRepository ?? BillTrackerRepository(firestore: db);

    final hasStorageUid = storageUid != null && storageUid.isNotEmpty;
    final salaryConsent =
        hasStorageUid && eosbRepository.salaryConsent(uid: storageUid);

    final documents = hasStorageUid
        ? await _loadDocuments(storageUid, db)
        : const <DocumentVaultRecord>[];
    final bills = hasStorageUid
        ? await _loadBills(storageUid, billsRepo)
        : const <BillDueRecord>[];
    final cv = hasStorageUid
        ? await _loadCv(storageUid, resolvedPrefs, db)
        : null;
    final eosbHistory = hasStorageUid
        ? await eosbRepository.loadHistory(uid: storageUid)
        : const <CalculationHistoryEntry>[];
    final latestEosb = EosbSalaryStoragePolicy.pickSalaryAwareHistoryEntry(
      eosbHistory,
      salaryStorageConsent: salaryConsent,
    );
    final overtimeInput = salaryConsent
        ? eosbRepository.loadCachedOvertimeInput(uid: storageUid)
        : null;

    return ExpatScoreLiveInputs(
      profile: profile,
      documents: documents,
      bills: bills,
      eosbInput: latestEosb?.input,
      eosbBreakdown: latestEosb?.result.breakdown,
      eosbCalculationId: latestEosb?.id,
      eosbSavedAt: latestEosb?.savedAt,
      overtimeCompanyName: salaryConsent
          ? (overtimeInput?.companyName ?? '')
          : '',
      overtimeBasicSalary: salaryConsent
          ? (overtimeInput?.basicSalary ?? 0)
          : 0,
      cvDocument: cv,
    );
  }

  static Future<List<DocumentVaultRecord>> _loadDocuments(
    String uid,
    FirebaseFirestore? db,
  ) async {
    if (uid.isEmpty || db == null) return const [];

    try {
      final snapshot = await db
          .collection('scanned_documents')
          .where('userId', isEqualTo: uid)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DocumentVaultRecord(
          id: doc.id,
          displayName:
              data['displayName'] as String? ?? data['holderName'] as String?,
          docType: data['docType'] as String?,
          expiryDate: _parseExpiry(data['expiryDate']),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<List<BillDueRecord>> _loadBills(
    String uid,
    BillTrackerRepository billsRepo,
  ) async {
    if (uid.isEmpty) return const [];

    try {
      final bills = await billsRepo.watchBills(uid).first;
      return bills
          .map(
            (bill) => BillDueRecord(
              id: bill.id,
              provider: bill.provider,
              dueDate: bill.dueDate,
              isPaid: bill.isPaid,
              amount: bill.amount,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<CvDocument?> _loadCv(
    String uid,
    SharedPreferences prefs,
    FirebaseFirestore? db,
  ) async {
    if (uid.isNotEmpty && db != null) {
      try {
        final snapshot = await db
            .collection('users')
            .doc(uid)
            .collection('cv_documents')
            .orderBy('updatedAt', descending: true)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          return CvDocument.fromJson({...doc.data(), 'id': doc.id});
        }
      } catch (_) {}
    }

    if (uid.isEmpty) return null;
    return _loadCvFromPrefs(prefs, uid);
  }

  static Future<CvDocument?> _loadCvFromPrefs(
    SharedPreferences prefs,
    String uid,
  ) async {
    final latestId = UidScopedPreferences.getString(
      prefs,
      CvRepository.latestIdKey,
      uid: uid,
    );
    if (latestId != null) {
      final cv = _parseCvPrefs(prefs, latestId, uid);
      if (cv != null) return cv;
    }

    final ids =
        UidScopedPreferences.getStringList(
          prefs,
          CvRepository.indexKey,
          uid: uid,
        ) ??
        [];
    for (final id in ids) {
      final cv = _parseCvPrefs(prefs, id, uid);
      if (cv != null) return cv;
    }
    return null;
  }

  static CvDocument? _parseCvPrefs(
    SharedPreferences prefs,
    String id,
    String uid,
  ) {
    final raw = prefs.getString(
      UidScopedPreferences.scopedKey(uid, CvRepository.documentBaseKey(id)),
    );
    if (raw == null) return null;
    try {
      return CvDocument.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseExpiry(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
