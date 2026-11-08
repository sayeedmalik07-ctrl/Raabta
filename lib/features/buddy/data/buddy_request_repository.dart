import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/buddy/data/buddy_profile_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_communication_policy.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_intro_templates.dart';
import 'package:raabta/features/buddy/domain/buddy_request_transitions.dart';
import 'package:raabta/features/buddy/domain/buddy_thread_ids.dart';
import 'package:raabta/features/buddy/models/buddy_request.dart';
import 'package:raabta/services/classifieds/block_user_repository.dart';
import 'package:raabta/services/firebase_service.dart';

enum BuddyRequestCreateError {
  unavailable,
  invalidIntro,
  invalidTemplate,
  capPending,
  capDaily,
  duplicatePending,
  invalidHelper,
  blocked,
}

typedef BuddyRequestCreateOutcome = ({
  BuddyRequestCreateError? error,
  String? requestId,
});

class BuddyRequestRepository {
  BuddyRequestRepository({FirebaseFirestore? firestore})
      : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _db;

  static const collection = 'buddy_requests';
  static const threadsCollection = 'buddy_threads';

  CollectionReference<Map<String, dynamic>>? get _requests =>
      _db?.collection(collection);

  Future<int> countPendingForNewcomer(String fromUid) async {
    final col = _requests;
    if (col == null) return 0;
    final snap = await col
        .where('fromUid', isEqualTo: fromUid)
        .where('status', isEqualTo: BuddyConstants.requestStatusPending)
        .limit(BuddyConstants.maxPendingRequestsPerNewcomer + 1)
        .get();
    return snap.size;
  }

  Future<int> countRequestsToday(String fromUid) async {
    final col = _requests;
    if (col == null) return 0;
    final start = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    final snap = await col
        .where('fromUid', isEqualTo: fromUid)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(start))
        .limit(BuddyConstants.maxDailyRequestsPerUser + 1)
        .get();
    return snap.size;
  }

  Future<bool> hasPendingPair({
    required String fromUid,
    required String toUid,
  }) async {
    final col = _requests;
    if (col == null) return false;
    final snap = await col
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: toUid)
        .where('status', isEqualTo: BuddyConstants.requestStatusPending)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<BuddyRequestCreateOutcome> createRequest({
    required String fromUid,
    required String toUid,
    required String introTemplateId,
    required String introText,
  }) async {
    final col = _requests;
    if (col == null) {
      return (error: BuddyRequestCreateError.unavailable, requestId: null);
    }

    final trimmed = introText.trim();
    if (trimmed.isEmpty ||
        trimmed.length > BuddyConstants.introTextMaxLength) {
      return (error: BuddyRequestCreateError.invalidIntro, requestId: null);
    }
    if (BuddyIntroTemplates.byId(introTemplateId) == null) {
      return (error: BuddyRequestCreateError.invalidTemplate, requestId: null);
    }
    if (fromUid == toUid) {
      return (error: BuddyRequestCreateError.invalidHelper, requestId: null);
    }

    final blocks = BlockUserRepository(firestore: _db);
    if (await BuddyCommunicationPolicy.isLocallyBlocked(
      blocks: blocks,
      actorUid: fromUid,
      otherUid: toUid,
    )) {
      return (error: BuddyRequestCreateError.blocked, requestId: null);
    }

    final helperSnap = await _db!
        .collection(BuddyProfileRepository.collection)
        .doc(toUid)
        .get();
    final helperData = helperSnap.data();
    if (!helperSnap.exists ||
        helperData?['isHelper'] != true ||
        helperData?['paused'] == true) {
      return (error: BuddyRequestCreateError.invalidHelper, requestId: null);
    }

    if (await countPendingForNewcomer(fromUid) >=
        BuddyConstants.maxPendingRequestsPerNewcomer) {
      return (error: BuddyRequestCreateError.capPending, requestId: null);
    }
    if (await countRequestsToday(fromUid) >=
        BuddyConstants.maxDailyRequestsPerUser) {
      return (error: BuddyRequestCreateError.capDaily, requestId: null);
    }
    if (await hasPendingPair(fromUid: fromUid, toUid: toUid)) {
      return (error: BuddyRequestCreateError.duplicatePending, requestId: null);
    }

    final now = DateTime.now();
    final expires = now.add(const Duration(days: BuddyConstants.requestExpiryDays));

    final docRef = col.doc();
    await docRef.set({
      'fromUid': fromUid,
      'toUid': toUid,
      'introTemplateId': introTemplateId,
      'introText': trimmed,
      'status': BuddyConstants.requestStatusPending,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expires),
    });
    return (error: null, requestId: docRef.id);
  }

  Future<List<BuddyRequest>> fetchIncomingForHelper(String helperUid) async {
    final col = _requests;
    if (col == null) return const [];
    final snap = await col
        .where('toUid', isEqualTo: helperUid)
        .where('status', isEqualTo: BuddyConstants.requestStatusPending)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs
        .map((d) => BuddyRequest.fromFirestore(d.id, d.data()))
        .where((r) => !r.isExpired)
        .toList();
  }

  Future<List<BuddyRequest>> fetchOutgoingForNewcomer(String fromUid) async {
    final col = _requests;
    if (col == null) return const [];
    final snap = await col
        .where('fromUid', isEqualTo: fromUid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => BuddyRequest.fromFirestore(d.id, d.data())).toList();
  }

  Future<void> respondToRequest({
    required String requestId,
    required BuddyRequestAction action,
    required String actorUid,
  }) async {
    if (_db == null) throw StateError('Firebase unavailable');

    final ref = _requests!.doc(requestId);
    final preSnap = await ref.get();
    if (!preSnap.exists || preSnap.data() == null) {
      throw StateError('Request not found');
    }
    final preview = BuddyRequest.fromFirestore(preSnap.id, preSnap.data()!);
    final peerUid = switch (action) {
      BuddyRequestAction.accept ||
      BuddyRequestAction.decline =>
        preview.fromUid,
      BuddyRequestAction.cancel => preview.toUid,
    };
    await BuddyCommunicationPolicy.ensureLocallyAllowed(
      blocks: BlockUserRepository(firestore: _db),
      actorUid: actorUid,
      otherUid: peerUid,
    );

    if (action == BuddyRequestAction.accept) {
      await _acceptInTransaction(requestId: requestId, actorUid: actorUid);
      return;
    }

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists || snap.data() == null) {
        throw StateError('Request not found');
      }
      final request = BuddyRequest.fromFirestore(snap.id, snap.data()!);
      if (!BuddyRequestTransitions.canTransition(
        request: request,
        action: action,
        actorUid: actorUid,
      )) {
        throw StateError('Invalid transition');
      }
      if (request.isExpired) throw StateError('Request expired');
      tx.update(ref, {
        'status': BuddyRequestTransitions.statusForAction(action),
        'respondedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _acceptInTransaction({
    required String requestId,
    required String actorUid,
  }) async {
    final db = _db!;
    final reqRef = _requests!.doc(requestId);

    final preActiveSnap = await db
        .collection(threadsCollection)
        .where('helperUid', isEqualTo: actorUid)
        .where('status', isEqualTo: BuddyConstants.threadStatusActive)
        .limit(BuddyConstants.maxActiveThreadsPerHelper + 1)
        .get();

    await db.runTransaction((tx) async {
      final reqSnap = await tx.get(reqRef);
      if (!reqSnap.exists || reqSnap.data() == null) {
        throw StateError('Request not found');
      }
      final request = BuddyRequest.fromFirestore(reqSnap.id, reqSnap.data()!);
      if (!BuddyRequestTransitions.canTransition(
        request: request,
        action: BuddyRequestAction.accept,
        actorUid: actorUid,
      )) {
        throw StateError('Invalid transition');
      }
      if (request.isExpired) throw StateError('Request expired');

      final newcomerUid = request.fromUid;
      final helperUid = request.toUid;
      final threadId =
          BuddyThreadIds.forParticipants(newcomerUid, helperUid);
      final threadRef = db.collection(threadsCollection).doc(threadId);
      final threadSnap = await tx.get(threadRef);

      if (!threadSnap.exists) {
        var activeCount = 0;
        for (final doc in preActiveSnap.docs) {
          final fresh = await tx.get(doc.reference);
          if (fresh.exists &&
              fresh.data()?['status'] == BuddyConstants.threadStatusActive) {
            activeCount++;
          }
        }
        if (activeCount >= BuddyConstants.maxActiveThreadsPerHelper) {
          throw StateError('Helper buddy cap reached');
        }

        tx.set(threadRef, {
          'participantUids':
              BuddyThreadIds.sortedParticipantUids(newcomerUid, helperUid),
          'newcomerUid': newcomerUid,
          'helperUid': helperUid,
          'requestId': requestId,
          'status': BuddyConstants.threadStatusActive,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final status = threadSnap.data()?['status'] as String?;
        if (status != BuddyConstants.threadStatusActive) {
          throw StateError('Thread not active');
        }
      }

      tx.update(reqRef, {
        'status': BuddyConstants.requestStatusAccepted,
        'respondedAt': FieldValue.serverTimestamp(),
        'threadId': threadId,
      });

      final helperProfileRef =
          db.collection(BuddyProfileRepository.collection).doc(helperUid);
      tx.set(
        helperProfileRef,
        {'lastMatchedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    });
  }
}
