import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/data/repositories/businesses_repository.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/domain/business_quote_lifecycle.dart';
import 'package:raabta/features/business/domain/business_quote_request.dart';
import 'package:raabta/features/business/domain/business_structured_paths.dart';
import 'package:raabta/features/business/data/business_structured_meta_repository.dart';
import 'package:raabta/features/business/services/business_quote_notification_service.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/firebase_service.dart';

class BusinessQuoteRepository {
  BusinessQuoteRepository({
    FirebaseFirestore? firestore,
    BusinessQuoteNotificationService? notifications,
    BusinessStructuredMetaRepository? meta,
  })  : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _notifications = notifications ?? BusinessQuoteNotificationService(),
        _meta = meta ?? BusinessStructuredMetaRepository(firestore: firestore);

  final FirebaseFirestore? _db;
  final BusinessQuoteNotificationService _notifications;
  final BusinessStructuredMetaRepository _meta;

  CollectionReference<Map<String, dynamic>>? _requestsRef(String businessId) {
    if (_db == null) return null;
    return _db!
        .collection(BusinessesRepository.businessesCollection)
        .doc(businessId)
        .collection('quote_requests');
  }

  DocumentReference<Map<String, dynamic>>? _lockRef(
    String businessId,
    String requesterId,
  ) {
    if (_db == null) return null;
    return _db!
        .collection(BusinessesRepository.businessesCollection)
        .doc(businessId)
        .collection(BusinessStructuredPaths.quoteLocksCollection)
        .doc(requesterId);
  }

  Stream<List<BusinessQuoteRequest>> watchBusinessRequests(String businessId) {
    final ref = _requestsRef(businessId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: true).snapshots().asyncMap(
      (snap) async {
        final requests = <BusinessQuoteRequest>[];
        for (final doc in snap.docs) {
          var request = BusinessQuoteRequest.fromJson(doc.id, doc.data());
          final expired = BusinessQuoteLifecycle.expireIfNeeded(request);
          if (expired.status == BusinessQuoteStatus.expired &&
              request.status.isOpen) {
            await _applyTerminal(doc.reference, expired, releaseLock: true);
            request = expired;
          }
          requests.add(request);
        }
        return requests;
      },
    );
  }

  Stream<List<BusinessQuoteRequest>> watchOwnerRequests(String ownerId) {
    if (_db == null) return Stream.value(const []);

    return _db!
        .collectionGroup('quote_requests')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      final requests = <BusinessQuoteRequest>[];
      for (final doc in snap.docs) {
        var request = BusinessQuoteRequest.fromJson(doc.id, doc.data());
        final expired = BusinessQuoteLifecycle.expireIfNeeded(request);
        if (expired.status == BusinessQuoteStatus.expired &&
            request.status.isOpen) {
          await _applyTerminal(doc.reference, expired, releaseLock: true);
          request = expired;
        }
        requests.add(request);
      }
      return requests;
    });
  }

  Stream<List<BusinessQuoteRequest>> watchRequesterRequests(String requesterId) {
    if (_db == null) return Stream.value(const []);

    return _db!
        .collectionGroup('quote_requests')
        .where('requesterId', isEqualTo: requesterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => BusinessQuoteRequest.fromJson(d.id, d.data()))
              .map(BusinessQuoteLifecycle.expireIfNeeded)
              .toList(),
        );
  }

  Future<BusinessQuoteRequest?> createRequest({
    required String businessId,
    required String description,
    double? budgetQar,
    required String businessName,
    String locale = 'English',
  }) async {
    ComplianceFlagsGate.requireBusinessQuotes();
    if (_db == null) return null;
    final requesterId = FirebaseAuth.instance.currentUser?.uid;
    if (requesterId == null) return null;

    final trimmed = description.trim();
    if (trimmed.isEmpty ||
        trimmed.length > BusinessQuoteLifecycle.maxDescriptionLength) {
      return null;
    }
    if (budgetQar != null && budgetQar < 0) return null;

    final businessRef =
        _db.collection(BusinessesRepository.businessesCollection).doc(businessId);
    final businessSnap = await businessRef.get();
    if (!businessSnap.exists) return null;
    final business = businessSnap.data() ?? {};

    final ownerId = business['ownerUserId'] as String? ?? '';
    if (ownerId.isEmpty || ownerId == requesterId) return null;
    if (business['status'] != 'active') return null;
    if (BusinessContactModeX.fromStorage(business['contactMode'] as String?) !=
        BusinessContactMode.quote) {
      return null;
    }

    final lockRef = _lockRef(businessId, requesterId);
    final requestsRef = _requestsRef(businessId);
    if (lockRef == null || requestsRef == null) return null;

    final lockSnap = await lockRef.get();
    if (lockSnap.exists) return null;

    final now = DateTime.now();
    final requestRef = requestsRef.doc();
    final request = BusinessQuoteRequest(
      id: requestRef.id,
      businessId: businessId,
      requesterId: requesterId,
      ownerId: ownerId,
      description: trimmed,
      status: BusinessQuoteStatus.pending,
      createdAt: now,
      updatedAt: now,
      expiresAtMs: BusinessQuoteLifecycle.expiryFromNowMs(now),
      budgetQar: budgetQar,
    );

    // Lock must be committed before request — Firestore rules require an authoritative lock.
    await _db.runTransaction((tx) async {
      final lockCheck = await tx.get(lockRef);
      if (lockCheck.exists) throw StateError('open_request_exists');
      tx.set(lockRef, {
        'requestId': requestRef.id,
        'requesterId': requesterId,
        'businessId': businessId,
      });
    });

    await _db.runTransaction((tx) async {
      final lockCheck = await tx.get(lockRef);
      final lockData = lockCheck.data();
      if (!lockCheck.exists ||
          lockData?['requestId'] != requestRef.id ||
          lockData?['requesterId'] != requesterId) {
        throw StateError('lock_missing');
      }
      tx.set(requestRef, request.toJson());
      await _meta.incrementQuoteCount(tx, businessId);
    });

    await _notifications.notifyReceived(
      recipientUserId: ownerId,
      businessId: businessId,
      businessName: businessName,
      requestId: request.id,
      locale: locale,
    );
    return request;
  }

  Future<BusinessQuoteRequest?> ownerSubmitQuote({
    required BusinessQuoteRequest request,
    required double price,
    required String description,
    String? note,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessQuoteLifecycle.ownerSubmitQuote(
          request,
          price: price,
          description: description,
          note: note,
        ),
        businessName: businessName,
        locale: locale,
        notifyRequester: true,
        kind: BusinessQuoteNotificationKind.quoted,
        detail: price.toStringAsFixed(0),
        releaseLock: true,
      );

  Future<BusinessQuoteRequest?> ownerDecline({
    required BusinessQuoteRequest request,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessQuoteLifecycle.ownerDecline(request),
        businessName: businessName,
        locale: locale,
        notifyRequester: true,
        kind: BusinessQuoteNotificationKind.declined,
        releaseLock: true,
      );

  Future<BusinessQuoteRequest?> requesterCancel({
    required BusinessQuoteRequest request,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessQuoteLifecycle.requesterCancel(request),
        businessName: businessName,
        locale: locale,
        notifyRequester: false,
        notifyOwner: true,
        kind: BusinessQuoteNotificationKind.cancelled,
        releaseLock: true,
      );

  Future<BusinessQuoteRequest?> _transition({
    required BusinessQuoteRequest request,
    required BusinessQuoteRequest? next,
    required String businessName,
    required String locale,
    required BusinessQuoteNotificationKind kind,
    required bool releaseLock,
    bool notifyRequester = false,
    bool notifyOwner = false,
    String detail = '',
  }) async {
    ComplianceFlagsGate.requireBusinessQuotes();
    if (next == null) return null;
    final ref = _requestsRef(request.businessId)?.doc(request.id);
    if (ref == null) return null;

    await _applyTerminal(ref, next, releaseLock: releaseLock);

    if (notifyRequester || notifyOwner) {
      final recipient = notifyRequester ? request.requesterId : request.ownerId;
      await _notifications.notifyUpdated(
        recipientUserId: recipient,
        businessId: request.businessId,
        businessName: businessName,
        requestId: request.id,
        kind: kind,
        detail: detail,
        locale: locale,
      );
    }
    return next;
  }

  Future<void> _applyTerminal(
    DocumentReference<Map<String, dynamic>> ref,
    BusinessQuoteRequest next, {
    required bool releaseLock,
  }) async {
    if (_db == null) return;

    await ref.update(next.toJson());

    if (!releaseLock || !next.status.isTerminal) return;

    final lockRef = _lockRef(next.businessId, next.requesterId);
    if (lockRef == null) return;

    final lockSnap = await lockRef.get();
    if (!lockSnap.exists) return;

    // Terminal request must be committed before lock delete (rules require terminal/missing request).
    await lockRef.delete();
    await _db.runTransaction((tx) async {
      await _meta.decrementQuoteCount(
        tx,
        next.businessId,
        releasedRequesterId: next.requesterId,
      );
    });
  }
}
