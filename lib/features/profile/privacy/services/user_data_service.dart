import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/p0_local_data_purge.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/profile/privacy/models/user_data_summary.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/bill_tracker_user_data_purge.dart';
import 'package:raabta/features/quick_actions/scanner/repositories/scanned_document_repository.dart';
import 'package:raabta/models/advanced_profile.dart';
import 'package:raabta/services/ai/ai_thread_repository.dart';
import 'package:raabta/services/intelligence/evidence_repository.dart';
import 'package:raabta/services/intelligence/sensitive_action_audit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PDPPL-oriented export and deletion for the signed-in user's own data.
class UserDataService {
  UserDataService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AiThreadRepository? threads,
    ScannedDocumentRepository? documents,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _threads = threads ?? AiThreadRepository(firestore: firestore),
        _documents = documents ?? ScannedDocumentRepository(firestore: firestore);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final AiThreadRepository _threads;
  final ScannedDocumentRepository _documents;

  Future<UserDataSummary> fetchSummary(String uid) async {
    final profileSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('ai_profile')
        .doc('profile')
        .get();
    final docs = await _countDocuments(uid);
    final threadStats = await _threads.countThreadsAndMessages(uid);
    final prefs = await SharedPreferences.getInstance();
    final eosbRepo = EosbRepository(prefs);
    final eosbHistory = await eosbRepo.loadHistory(uid: uid);
    final overtimeHistory = eosbRepo.loadOvertimeHistory(uid: uid);
    final profileData = profileSnap.data();
    final advanced = profileData != null
        ? AdvancedProfile.fromJson(
            profileData['advancedProfile'] as Map<String, dynamic>?,
          )
        : const AdvancedProfile();
    final advConsent =
        profileData?['advancedProfileConsentGiven'] as bool? ?? false;

    return UserDataSummary(
      profileStored: profileSnap.exists,
      documentCount: docs,
      aiConversationCount: threadStats.$1,
      aiMessageCount: threadStats.$2,
      eosbHistoryCount: eosbHistory.length,
      overtimeHistoryCount: overtimeHistory.length,
      advancedProfileFieldCount:
          advConsent && advanced.hasAnyField ? advanced.filledFieldCount : 0,
    );
  }

  Future<Map<String, dynamic>> exportUserData(String uid) async {
    final profileSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('ai_profile')
        .doc('profile')
        .get();
    final userDoc = await _db.collection('users').doc(uid).get();
    final documents = await _fetchDocumentMetadata(uid);
    final threads = await _fetchThreadExport(uid);
    final prefs = await SharedPreferences.getInstance();
    final eosbRepo = EosbRepository(prefs);
    final buddySnap =
        await _db.collection('buddy_profiles').doc(uid).get();
    final buddyFromRequests = await _db
        .collection('buddy_requests')
        .where('fromUid', isEqualTo: uid)
        .limit(100)
        .get();
    final buddyToRequests = await _db
        .collection('buddy_requests')
        .where('toUid', isEqualTo: uid)
        .limit(100)
        .get();
    final buddyHelperThreads = await _db
        .collection('buddy_threads')
        .where('helperUid', isEqualTo: uid)
        .limit(50)
        .get();
    final buddyNewcomerThreads = await _db
        .collection('buddy_threads')
        .where('newcomerUid', isEqualTo: uid)
        .limit(50)
        .get();

    return {
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'uid': uid,
      'userDocument': userDoc.data(),
      'aiProfile': profileSnap.data(),
      if (buddySnap.exists && buddySnap.data() != null)
        'buddyProfile': buddySnap.data(),
      'buddyRequestsFrom': buddyFromRequests.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(),
      'buddyRequestsTo': buddyToRequests.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(),
      'buddyThreads': await _exportBuddyThreads(
        helperDocs: buddyHelperThreads.docs,
        newcomerDocs: buddyNewcomerThreads.docs,
      ),
      'documents': documents,
      'aiConversations': threads,
      'eosbCalculationHistory': (await eosbRepo.loadHistory(uid: uid))
          .map((e) => {'id': e.id, 'savedAt': e.savedAt.toIso8601String()})
          .toList(),
      'overtimeHistory': eosbRepo
          .loadOvertimeHistory(uid: uid)
          .map((e) => e.toJson())
          .toList(),
      'note':
          'Community posts are not included; on account deletion they are anonymized, not removed.',
    };
  }

  Future<void> deleteAiHistory(String uid) async {
    await _threads.deleteAllThreads(uid);
  }

  Future<void> deleteAllDocuments(String uid) async {
    final snap = await _db
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in snap.docs) {
      await _documents.delete(doc.id);
    }
  }

  Future<void> deleteAdvancedProfile(String uid) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('ai_profile')
        .doc('profile')
        .set({
      'advancedProfile': FieldValue.delete(),
      'advancedProfileConsentGiven': false,
      'advancedProfileConsentDate': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteEosbLocalData(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await EosbRepository.purgeLocalDataForUser(prefs, uid);
  }

  /// Deletes user-owned data then Firebase Auth account.
  ///
  /// Community content is **anonymized** (author fields cleared) — flagged for
  /// product review: replies may reference anonymized posts.
  Future<void> deleteAccount({
    required String uid,
    required String phoneConfirmation,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) {
      throw StateError('Not signed in');
    }
    final phone = user.phoneNumber ?? '';
    if (phone.isEmpty || !_phonesMatch(phone, phoneConfirmation)) {
      throw StateError('Phone number does not match your account');
    }

    await deleteAiHistory(uid);
    await deleteAllDocuments(uid);
    await deleteAdvancedProfile(uid);
    await deleteEosbLocalData(uid);
    await P0LocalDataPurge.purgeAllForUid(uid);
    await BillTrackerUserDataPurge.purgeForAccountDeletion(firebaseUid: uid);
    await _deleteUserSubcollection(uid, 'eosb_calculations');
    await _deleteUserSubcollection(uid, 'overtime_calculations');
    await _deleteUserSubcollection(uid, 'transfer_readiness_checks');
    await _deleteUserSubcollection(uid, 'tenancy_records');
    await _deleteUserSubcollection(uid, 'tenancy_dispute_packets');
    await _deleteUserSubcollection(uid, 'tenancy_condition_records');
    await _deleteUserSubcollection(uid, 'health_insurance_compliance_checks');
    await _deleteUserSubcollection(uid, 'health_insurance_claim_disputes');
    await _deleteUserSubcollection(uid, 'cv_documents');
    await _deleteUserSubcollection(uid, SensitiveActionAuditService.collection);
    await _deleteUserSubcollection(uid, EvidenceRepository.collectionName);
    await _deleteUserSubcollection(uid, 'blocked_users');
    await _deleteBuddyData(uid);
    await _anonymizeCommunityContent(uid);
    await _db.collection('users').doc(uid).delete().catchError((_) {});
    await _db
        .collection('users')
        .doc(uid)
        .collection('ai_profile')
        .doc('profile')
        .delete()
        .catchError((_) {});

    await user.delete();
  }

  Future<int> _countDocuments(String uid) async {
    final snap = await _db
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .get();
    return snap.size;
  }

  Future<List<Map<String, dynamic>>> _fetchDocumentMetadata(String uid) async {
    final snap = await _db
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .get();
    return snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data.remove('ocrText');
      data.remove('aiIntelligence');
      return {'id': doc.id, ...data};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchThreadExport(String uid) async {
    final summaries = await _threads.listThreads(uid);
    final out = <Map<String, dynamic>>[];
    for (final summary in summaries) {
      final messages = await _threads.loadMessages(uid, threadId: summary.id);
      out.add({
        'threadId': summary.id,
        'title': summary.title,
        'messageCount': messages.length,
        'messages': messages.map((m) => m.toJson()).toList(),
      });
    }
    return out;
  }

  Future<void> _deleteBuddyData(String uid) async {
    await _db.collection('buddy_profiles').doc(uid).delete().catchError((_) {});
    for (final field in ['fromUid', 'toUid']) {
      try {
        final snap = await _db
            .collection('buddy_requests')
            .where(field, isEqualTo: uid)
            .limit(200)
            .get();
        for (final doc in snap.docs) {
          await doc.reference.delete().catchError((_) {});
        }
      } catch (_) {}
    }
    for (final field in ['helperUid', 'newcomerUid']) {
      try {
        final snap = await _db
            .collection('buddy_threads')
            .where(field, isEqualTo: uid)
            .limit(100)
            .get();
        for (final doc in snap.docs) {
          await _deleteBuddyThreadMessages(doc.reference);
          await doc.reference.delete().catchError((_) {});
        }
      } catch (_) {}
    }
  }

  Future<List<Map<String, dynamic>>> _exportBuddyThreads({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> helperDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> newcomerDocs,
  }) async {
    final byId = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final d in helperDocs) {
      byId[d.id] = d;
    }
    for (final d in newcomerDocs) {
      byId[d.id] = d;
    }
    final out = <Map<String, dynamic>>[];
    for (final d in byId.values) {
      out.add({
        'id': d.id,
        ...d.data(),
        'messages': await _exportBuddyThreadMessages(d.reference),
      });
    }
    out.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    return out;
  }

  Future<List<Map<String, dynamic>>> _exportBuddyThreadMessages(
    DocumentReference<Map<String, dynamic>> threadRef,
  ) async {
    try {
      final snap = await threadRef.collection('messages').limit(500).get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _deleteBuddyThreadMessages(
    DocumentReference<Map<String, dynamic>> threadRef,
  ) async {
    try {
      final snap = await threadRef.collection('messages').limit(500).get();
      for (final doc in snap.docs) {
        await doc.reference.delete().catchError((_) {});
      }
    } catch (_) {}
  }

  Future<void> _deleteUserSubcollection(String uid, String subcollection) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection(subcollection)
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (_) {
      // Subcollection may be absent or rules may block in some environments.
    }
  }

  Future<void> _anonymizeCommunityContent(String uid) async {
    for (final collection in ['ask_qatar', 'community_posts', 'group_posts']) {
      try {
        final snap = await _db
            .collection(collection)
            .where('createdBy', isEqualTo: uid)
            .get();
        for (final doc in snap.docs) {
          await doc.reference.set({
            'createdBy': 'deleted_user',
            'authorDisplayName': 'Former member',
            'authorInitials': '?',
            'anonymizedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (_) {
        // Collection may not exist in this environment.
      }
    }
  }

  bool _phonesMatch(String stored, String entered) {
    return _normalizePhone(stored) == _normalizePhone(entered) ||
        _normalizePhone(stored).endsWith(_normalizePhone(entered)) ||
        _normalizePhone(entered).endsWith(_normalizePhone(stored));
  }

  String _normalizePhone(String value) => value.replaceAll(RegExp(r'\D'), '');
}
