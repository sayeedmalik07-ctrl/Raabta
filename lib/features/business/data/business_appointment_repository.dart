import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/data/repositories/businesses_repository.dart';
import 'package:raabta/features/business/domain/business_appointment_lifecycle.dart';
import 'package:raabta/features/business/domain/business_appointment_request.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/domain/business_structured_paths.dart';
import 'package:raabta/features/business/data/business_structured_meta_repository.dart';
import 'package:raabta/features/business/services/business_appointment_notification_service.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/firebase_service.dart';

class BusinessAppointmentRepository {
  BusinessAppointmentRepository({
    FirebaseFirestore? firestore,
    BusinessAppointmentNotificationService? notifications,
    BusinessStructuredMetaRepository? meta,
  })  : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _notifications =
            notifications ?? BusinessAppointmentNotificationService(),
        _meta = meta ?? BusinessStructuredMetaRepository(firestore: firestore);

  final FirebaseFirestore? _db;
  final BusinessAppointmentNotificationService _notifications;
  final BusinessStructuredMetaRepository _meta;

  CollectionReference<Map<String, dynamic>>? _requestsRef(String businessId) {
    if (_db == null) return null;
    return _db!
        .collection(BusinessesRepository.businessesCollection)
        .doc(businessId)
        .collection('appointment_requests');
  }

  DocumentReference<Map<String, dynamic>>? _lockRef(
    String businessId,
    String requesterId,
  ) {
    if (_db == null) return null;
    return _db!
        .collection(BusinessesRepository.businessesCollection)
        .doc(businessId)
        .collection(BusinessStructuredPaths.appointmentLocksCollection)
        .doc(requesterId);
  }

  Stream<List<BusinessAppointmentRequest>> watchBusinessRequests(
    String businessId,
  ) {
    final ref = _requestsRef(businessId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: true).snapshots().asyncMap(
      (snap) async {
        final requests = <BusinessAppointmentRequest>[];
        for (final doc in snap.docs) {
          var request =
              BusinessAppointmentRequest.fromJson(doc.id, doc.data());
          final expired = BusinessAppointmentLifecycle.expireIfNeeded(request);
          if (expired.status == BusinessAppointmentStatus.expired &&
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

  Stream<List<BusinessAppointmentRequest>> watchOwnerRequests(String ownerId) {
    if (_db == null) return Stream.value(const []);

    return _db!
        .collectionGroup('appointment_requests')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      final requests = <BusinessAppointmentRequest>[];
      for (final doc in snap.docs) {
        var request = BusinessAppointmentRequest.fromJson(doc.id, doc.data());
        final expired = BusinessAppointmentLifecycle.expireIfNeeded(request);
        if (expired.status == BusinessAppointmentStatus.expired &&
            request.status.isOpen) {
          await _applyTerminal(doc.reference, expired, releaseLock: true);
          request = expired;
        }
        requests.add(request);
      }
      return requests;
    });
  }

  Stream<List<BusinessAppointmentRequest>> watchRequesterRequests(
    String requesterId,
  ) {
    if (_db == null) return Stream.value(const []);

    return _db!
        .collectionGroup('appointment_requests')
        .where('requesterId', isEqualTo: requesterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => BusinessAppointmentRequest.fromJson(d.id, d.data()))
              .map(BusinessAppointmentLifecycle.expireIfNeeded)
              .toList(),
        );
  }

  Future<BusinessAppointmentRequest?> createRequest({
    required String businessId,
    required List<DateTime> proposedSlots,
    required String businessName,
    String? note,
    String locale = 'English',
  }) async {
    ComplianceFlagsGate.requireBusinessAppointments();
    if (_db == null) return null;
    final requesterId = FirebaseAuth.instance.currentUser?.uid;
    if (requesterId == null || proposedSlots.isEmpty) return null;

    final businessRef =
        _db.collection(BusinessesRepository.businessesCollection).doc(businessId);
    final businessSnap = await businessRef.get();
    if (!businessSnap.exists) return null;
    final business = businessSnap.data() ?? {};

    final ownerId = business['ownerUserId'] as String? ?? '';
    if (ownerId.isEmpty || ownerId == requesterId) return null;
    if (business['status'] != 'active') return null;
    if (BusinessContactModeX.fromStorage(business['contactMode'] as String?) !=
        BusinessContactMode.appointment) {
      return null;
    }

    final trimmedNote = note?.trim();
    if (trimmedNote != null &&
        trimmedNote.length > BusinessAppointmentLifecycle.maxNoteLength) {
      return null;
    }

    final lockRef = _lockRef(businessId, requesterId);
    final requestsRef = _requestsRef(businessId);
    if (lockRef == null || requestsRef == null) return null;

    final lockSnap = await lockRef.get();
    if (lockSnap.exists) return null;

    final now = DateTime.now();
    final requestRef = requestsRef.doc();
    final request = BusinessAppointmentRequest(
      id: requestRef.id,
      businessId: businessId,
      requesterId: requesterId,
      ownerId: ownerId,
      proposedSlots: proposedSlots,
      status: BusinessAppointmentStatus.pending,
      createdAt: now,
      updatedAt: now,
      expiresAtMs: BusinessAppointmentLifecycle.expiryFromNowMs(now),
      note: trimmedNote,
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
      await _meta.incrementAppointmentCount(tx, businessId);
    });

    await _notifications.notifyReceived(
      recipientUserId: ownerId,
      businessId: businessId,
      businessName: businessName,
      requestId: request.id,
      slotsSummary: _summarizeSlots(proposedSlots, locale),
      locale: locale,
    );
    return request;
  }

  Future<BusinessAppointmentRequest?> ownerConfirm({
    required BusinessAppointmentRequest request,
    required DateTime slot,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessAppointmentLifecycle.ownerConfirm(request, slot),
        businessName: businessName,
        locale: locale,
        notifyRequester: true,
        kind: BusinessAppointmentNotificationKind.confirmed,
        detail: _formatSlot(slot, locale),
        releaseLock: true,
      );

  Future<BusinessAppointmentRequest?> ownerDecline({
    required BusinessAppointmentRequest request,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessAppointmentLifecycle.ownerDecline(request),
        businessName: businessName,
        locale: locale,
        notifyRequester: true,
        kind: BusinessAppointmentNotificationKind.declined,
        releaseLock: true,
      );

  Future<BusinessAppointmentRequest?> ownerCounter({
    required BusinessAppointmentRequest request,
    required List<DateTime> counterSlots,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessAppointmentLifecycle.ownerCounter(request, counterSlots),
        businessName: businessName,
        locale: locale,
        notifyRequester: true,
        kind: BusinessAppointmentNotificationKind.countered,
        detail: _summarizeSlots(counterSlots, locale),
        releaseLock: false,
      );

  Future<BusinessAppointmentRequest?> requesterAcceptCounter({
    required BusinessAppointmentRequest request,
    required DateTime slot,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessAppointmentLifecycle.requesterAcceptCounter(request, slot),
        businessName: businessName,
        locale: locale,
        notifyRequester: false,
        kind: BusinessAppointmentNotificationKind.confirmed,
        detail: _formatSlot(slot, locale),
        releaseLock: true,
      );

  Future<BusinessAppointmentRequest?> requesterDeclineCounter({
    required BusinessAppointmentRequest request,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessAppointmentLifecycle.requesterDeclineCounter(request),
        businessName: businessName,
        locale: locale,
        notifyRequester: false,
        kind: BusinessAppointmentNotificationKind.declined,
        releaseLock: true,
      );

  Future<BusinessAppointmentRequest?> requesterCancel({
    required BusinessAppointmentRequest request,
    required String businessName,
    String locale = 'English',
  }) =>
      _transition(
        request: request,
        next: BusinessAppointmentLifecycle.requesterCancel(request),
        businessName: businessName,
        locale: locale,
        notifyRequester: false,
        notifyOwner: true,
        kind: BusinessAppointmentNotificationKind.cancelled,
        releaseLock: true,
      );

  Future<BusinessAppointmentRequest?> _transition({
    required BusinessAppointmentRequest request,
    required BusinessAppointmentRequest? next,
    required String businessName,
    required String locale,
    required BusinessAppointmentNotificationKind kind,
    required bool releaseLock,
    bool notifyRequester = false,
    bool notifyOwner = false,
    String detail = '',
  }) async {
    ComplianceFlagsGate.requireBusinessAppointments();
    if (next == null) return null;
    final ref = _requestsRef(request.businessId)?.doc(request.id);
    if (ref == null) return null;

    await _applyTerminal(ref, next, releaseLock: releaseLock);

    final recipient = notifyRequester ? request.requesterId : request.ownerId;
    if (notifyRequester || notifyOwner) {
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
    BusinessAppointmentRequest next, {
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
      await _meta.decrementAppointmentCount(
        tx,
        next.businessId,
        releasedRequesterId: next.requesterId,
      );
    });
  }

  static String _formatSlot(DateTime slot, String locale) {
    return BusinessAppointmentStringsHelper.formatSlot(slot, locale);
  }

  static String _summarizeSlots(List<DateTime> slots, String locale) {
    if (slots.isEmpty) return '';
    if (slots.length == 1) return _formatSlot(slots.first, locale);
    return slots.map((s) => _formatSlot(s, locale)).join('; ');
  }
}

/// Slot formatting helper shared with UI strings file.
abstract final class BusinessAppointmentStringsHelper {
  static String formatSlot(DateTime slot, String locale) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final wd = weekdays[slot.weekday - 1];
    final mo = months[slot.month - 1];
    final hour = slot.hour.toString().padLeft(2, '0');
    final minute = slot.minute.toString().padLeft(2, '0');
    return '$wd $mo ${slot.day}, $hour:$minute';
  }
}
