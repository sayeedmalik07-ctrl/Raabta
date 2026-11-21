import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/visa/data/deadline_tracker_repository.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Merges live app signals into profile interest tags for [ExpatLifeScoreService].
abstract final class ExpatScoreSignalEnricher {
  static const eosbCalculationTag = 'profile:eosb_calculation';
  static const overtimeCalculationTag = 'profile:overtime_calculation';

  static const _salaryInterestTags = {
    eosbCalculationTag,
    overtimeCalculationTag,
  };

  static Future<List<String>> enrichInterests({
    required UserAIProfile profile,
    required String? storageUid,
    SharedPreferences? prefs,
    DeadlineTrackerRepository? deadlineRepo,
    FirebaseFirestore? firestore,
    required EosbRepository eosbRepository,
  }) async {
    final tags = profile.interests.map((e) => e.toLowerCase()).toSet();
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    final db =
        firestore ??
        (FirebaseService.isReady ? FirebaseFirestore.instance : null);

    final salaryConsent =
        storageUid != null &&
        storageUid.isNotEmpty &&
        eosbRepository.salaryConsent(uid: storageUid);
    if (!salaryConsent) {
      tags.removeAll(_salaryInterestTags);
    }

    _applyProfileDerivedSignals(tags, profile);
    if (salaryConsent) {
      _applyEosbSignals(
        tags,
        resolvedPrefs,
        storageUid,
        eosbRepository: eosbRepository,
      );
    }
    _applyMoneyServiceSignals(tags, profile);
    await _applyDeadlineSignals(tags, storageUid ?? '', deadlineRepo);
    if (db != null && storageUid != null && storageUid.isNotEmpty) {
      await _applyVaultSignals(tags, storageUid, db);
      await _applyBillTrackerSignals(tags, storageUid, db);
      await _applyCvSignals(tags, storageUid, resolvedPrefs, db);
    }

    return tags.toList();
  }

  static void _applyProfileDerivedSignals(
    Set<String> tags,
    UserAIProfile profile,
  ) {
    if (profile.savedHousingIds.isNotEmpty) {
      tags.add('profile:housing_confirmed');
    }
    if (profile.communityGroups.isNotEmpty) {
      tags.add('profile:community_posts:1');
    }
  }

  static void _applyMoneyServiceSignals(
    Set<String> tags,
    UserAIProfile profile,
  ) {
    for (final query in profile.searchHistory) {
      final lower = query.toLowerCase();
      if (lower.contains('transfer') ||
          lower.contains('remit') ||
          lower.contains('exchange') ||
          lower.contains('money')) {
        tags.add('profile:money_transfer');
      }
      if (lower.contains('rate') || lower.contains('forex')) {
        tags.add('profile:exchange_alerts');
      }
    }

    for (final interest in profile.interests) {
      final lower = interest.toLowerCase();
      if (lower.contains('money') || lower.contains('transfer')) {
        tags.add('profile:money_transfer');
      }
      if (lower.contains('exchange') || lower.contains('forex')) {
        tags.add('profile:exchange_alerts');
      }
      if (lower.contains('savings') || lower.contains('insurance')) {
        tags.add('profile:savings_goal');
      }
    }
  }

  static void _applyEosbSignals(
    Set<String> tags,
    SharedPreferences prefs,
    String uid, {
    required EosbRepository eosbRepository,
  }) {
    if (uid.isEmpty) return;
    if (!eosbRepository.salaryConsent(uid: uid)) return;
    final eosbHistory = UidScopedPreferences.getString(
      prefs,
      EosbRepository.calculationHistoryKey,
      uid: uid,
    );
    if (_hasStoredList(eosbHistory)) {
      tags.add('profile:eosb_calculation');
    }
    final overtimeHistory = UidScopedPreferences.getString(
      prefs,
      EosbRepository.overtimeHistoryKey,
      uid: uid,
    );
    if (_hasStoredList(overtimeHistory)) {
      tags.add('profile:overtime_calculation');
    }
  }

  static bool _hasStoredList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return false;
    return raw.trim() != '[]';
  }

  static Future<void> _applyDeadlineSignals(
    Set<String> tags,
    String uid,
    DeadlineTrackerRepository? deadlineRepo,
  ) async {
    if (deadlineRepo == null || uid.isEmpty) return;

    try {
      final deadlines = await deadlineRepo.watchDeadlines(uid).first;
      _tagDocumentationFromDeadlines(tags, deadlines);
    } catch (_) {
      // Offline / permission errors should not block score calculation.
    }
  }

  static void _tagDocumentationFromDeadlines(
    Set<String> tags,
    List<DocumentDeadline> deadlines,
  ) {
    for (final deadline in deadlines) {
      final type = deadline.documentType.toLowerCase();
      if (type.contains('iqama') || type.contains('residence')) {
        tags.add('profile:iqama_expiry');
      }
      if (type.contains('passport')) {
        tags.add('profile:passport_expiry');
      }
      if (type.contains('qid')) {
        tags.add('profile:qid_info');
      }
      if (type.contains('work') && type.contains('permit')) {
        tags.add('profile:work_permit');
      }
      if (type.contains('driving') || type.contains('license')) {
        tags.add('profile:vault_driving');
      }
      if (deadline.vaultDocumentId != null &&
          deadline.vaultDocumentId!.isNotEmpty) {
        tags.add('profile:vault_document');
      }
    }
  }

  static Future<void> _applyVaultSignals(
    Set<String> tags,
    String uid,
    FirebaseFirestore db,
  ) async {
    if (uid.isEmpty) return;

    try {
      final snapshot = await db
          .collection('scanned_documents')
          .where('userId', isEqualTo: uid)
          .limit(50)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final type = (data['docType'] as String? ?? '').toLowerCase();
        if (!_documentStillValid(data['expiryDate'])) continue;

        if (type.contains('passport')) tags.add('profile:vault_passport');
        if (type.contains('visa') || type.contains('iqama')) {
          tags.add('profile:vault_visa');
        }
        if (type.contains('qid')) tags.add('profile:vault_qid');
        if (type.contains('driving') || type.contains('license')) {
          tags.add('profile:vault_driving');
        }
        if (type.contains('labour') || type.contains('work')) {
          tags.add('profile:work_permit');
        }
      }
    } catch (_) {}
  }

  static bool _documentStillValid(dynamic expiry) {
    if (expiry == null) return true;
    if (expiry is Timestamp) {
      return expiry.toDate().isAfter(DateTime.now());
    }
    if (expiry is DateTime) {
      return expiry.isAfter(DateTime.now());
    }
    return true;
  }

  static Future<void> _applyBillTrackerSignals(
    Set<String> tags,
    String uid,
    FirebaseFirestore db,
  ) async {
    if (uid.isEmpty) return;

    try {
      final snapshot = await db
          .collection('bill_tracker')
          .where('userId', isEqualTo: uid)
          .limit(100)
          .get();
      final count = snapshot.docs.length;
      if (count > 0) {
        tags.add('profile:bill_tracker');
        tags.add('profile:bills:$count');
      }
    } catch (_) {}
  }

  static Future<void> _applyCvSignals(
    Set<String> tags,
    String uid,
    SharedPreferences prefs,
    FirebaseFirestore db,
  ) async {
    CvDocument? cv;

    if (uid.isNotEmpty) {
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
          cv = CvDocument.fromJson({...doc.data(), 'id': doc.id});
        }
      } catch (_) {}
    }

    cv ??= uid.isNotEmpty ? await _loadCvFromPrefs(prefs, uid) : null;
    if (cv == null) return;

    tags.add('profile:cv_started');
    if (_cvIsComplete(cv)) {
      tags.add('profile:cv_complete');
    }
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

  static bool _cvIsComplete(CvDocument cv) {
    final hasExperience = cv.experience.any(
      (entry) => entry.jobTitle.trim().isNotEmpty,
    );
    final hasSkills =
        cv.skills.hardSkills.isNotEmpty ||
        cv.skills.softSkills.isNotEmpty ||
        cv.skills.toolsSoftware.isNotEmpty;

    return cv.fullName.trim().isNotEmpty &&
        cv.professionalSummary.trim().isNotEmpty &&
        hasExperience &&
        hasSkills;
  }
}
