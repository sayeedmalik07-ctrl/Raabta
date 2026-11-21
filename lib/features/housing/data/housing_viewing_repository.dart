import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/housing/data/housing_chat_repository.dart';
import 'package:raabta/features/housing/domain/housing_viewing_lifecycle.dart';
import 'package:raabta/features/housing/domain/housing_viewing_request.dart';
import 'package:raabta/features/housing/services/housing_viewing_notification_service.dart';
import 'package:raabta/features/housing/services/housing_viewing_reminder_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/housing_firestore_service.dart';

class HousingViewingRepository {
  HousingViewingRepository({
    FirebaseFirestore? firestore,
    HousingChatRepository? chatRepository,
    HousingViewingNotificationService? notifications,
    HousingViewingReminderService? reminders,
  })  : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _chat = chatRepository ?? HousingChatRepository(),
        _notifications = notifications ?? HousingViewingNotificationService(),
        _reminders = reminders ?? HousingViewingReminderService();

  final FirebaseFirestore? _firestore;
  final HousingChatRepository _chat;
  final HousingViewingNotificationService _notifications;
  final HousingViewingReminderService _reminders;

  CollectionReference<Map<String, dynamic>>? _requestsRef(String listingId) {
    if (_firestore == null) return null;
    return _firestore!
        .collection(HousingFirestoreService.listingsCollection)
        .doc(listingId)
        .collection('viewing_requests');
  }

  Stream<List<HousingViewingRequest>> watchListingRequests(String listingId) {
    final ref = _requestsRef(listingId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: true).snapshots().asyncMap(
      (snap) async {
        final requests = <HousingViewingRequest>[];
        for (final doc in snap.docs) {
          var request = HousingViewingRequest.fromJson(doc.id, doc.data());
          final expired = HousingViewingLifecycle.expireIfNeeded(request);
          if (expired.status == HousingViewingStatus.expired &&
              request.status.isOpen) {
            await doc.reference.update(expired.toJson());
            await _reminders.cancelForViewing(request.id);
            request = expired;
          }
          requests.add(request);
        }
        return requests;
      },
    );
  }

  Stream<List<HousingViewingRequest>> watchOwnerRequests(String ownerId) {
    if (_firestore == null) return Stream.value(const []);

    return _firestore!
        .collectionGroup('viewing_requests')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      final requests = <HousingViewingRequest>[];
      for (final doc in snap.docs) {
        var request = HousingViewingRequest.fromJson(doc.id, doc.data());
        final expired = HousingViewingLifecycle.expireIfNeeded(request);
        if (expired.status == HousingViewingStatus.expired &&
            request.status.isOpen) {
          await doc.reference.update(expired.toJson());
          await _reminders.cancelForViewing(request.id);
          request = expired;
        }
        requests.add(request);
      }
      return requests;
    });
  }

  Future<HousingViewingRequest?> createRequest({
    required String listingId,
    required String ownerId,
    required List<DateTime> proposedSlots,
    required String listingTitle,
    required String locale,
    String? note,
  }) async {
    ComplianceFlagsGate.requireViewings();
    final ref = _requestsRef(listingId);
    final viewerId = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || viewerId == null || viewerId == ownerId) return null;
    if (proposedSlots.isEmpty) return null;

    final now = DateTime.now();
    final doc = ref.doc(viewerId);
    final request = HousingViewingRequest(
      id: viewerId,
      listingId: listingId,
      viewerId: viewerId,
      ownerId: ownerId,
      proposedSlots: proposedSlots,
      status: HousingViewingStatus.pending,
      createdAt: now,
      expiresAt: HousingViewingLifecycle.expiryFromNow(now),
      note: note,
    );

    await doc.set(request.toJson());

    final slotsSummary =
        HousingViewingReminderService.summarizeSlots(proposedSlots, locale);
    await _notifications.notifyViewingReceived(
      recipientUserId: ownerId,
      listingId: listingId,
      listingTitle: listingTitle,
      requestId: request.id,
      slotsSummary: slotsSummary,
      locale: locale,
    );
    return request;
  }

  Future<HousingViewingRequest?> ownerConfirm({
    required HousingViewingRequest request,
    required DateTime slot,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        request: request,
        next: HousingViewingLifecycle.ownerConfirm(request, slot),
        systemMessageKey: 'hv_chat_confirmed',
        locale: locale,
        listingTitle: listingTitle,
        notifyViewer: true,
        notifyKind: HousingViewingNotificationKind.confirmed,
        detail: HousingViewingReminderService.formatSlot(slot, locale),
        scheduleReminders: true,
        confirmedSlot: slot,
      );

  Future<HousingViewingRequest?> ownerDecline({
    required HousingViewingRequest request,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        request: request,
        next: HousingViewingLifecycle.ownerDecline(request),
        systemMessageKey: 'hv_chat_declined',
        locale: locale,
        listingTitle: listingTitle,
        notifyViewer: true,
        notifyKind: HousingViewingNotificationKind.declined,
        detail: '',
      );

  Future<HousingViewingRequest?> ownerCounter({
    required HousingViewingRequest request,
    required List<DateTime> counterSlots,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        request: request,
        next: HousingViewingLifecycle.ownerCounter(request, counterSlots),
        systemMessageKey: 'hv_chat_countered',
        locale: locale,
        listingTitle: listingTitle,
        notifyViewer: true,
        notifyKind: HousingViewingNotificationKind.countered,
        detail: HousingViewingReminderService.summarizeSlots(counterSlots, locale),
      );

  Future<HousingViewingRequest?> viewerAcceptCounter({
    required HousingViewingRequest request,
    required DateTime slot,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        request: request,
        next: HousingViewingLifecycle.viewerAcceptCounter(request, slot),
        systemMessageKey: 'hv_chat_confirmed',
        locale: locale,
        listingTitle: listingTitle,
        notifyViewer: false,
        notifyKind: HousingViewingNotificationKind.confirmed,
        detail: HousingViewingReminderService.formatSlot(slot, locale),
        scheduleReminders: true,
        confirmedSlot: slot,
      );

  Future<HousingViewingRequest?> viewerDeclineCounter({
    required HousingViewingRequest request,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        request: request,
        next: HousingViewingLifecycle.viewerDeclineCounter(request),
        systemMessageKey: 'hv_chat_declined',
        locale: locale,
        listingTitle: listingTitle,
        notifyViewer: false,
        notifyKind: HousingViewingNotificationKind.declined,
        detail: '',
      );

  Future<HousingViewingRequest?> _applyTransition({
    required HousingViewingRequest request,
    required HousingViewingRequest? next,
    required String systemMessageKey,
    required String locale,
    required String listingTitle,
    required bool notifyViewer,
    required HousingViewingNotificationKind notifyKind,
    required String detail,
    bool scheduleReminders = false,
    DateTime? confirmedSlot,
  }) async {
    ComplianceFlagsGate.requireViewings();
    if (next == null) return null;
    final ref = _requestsRef(request.listingId)?.doc(request.id);
    if (ref == null) return null;

    await ref.update(next.toJson());

    final slotText = confirmedSlot != null
        ? HousingViewingReminderService.formatSlot(confirmedSlot, locale)
        : detail;
    final confirmedAtIso = next.confirmedAt?.toIso8601String();
    await _chat.sendViewingSystemMessage(
      listingId: request.listingId,
      viewingRequestId: request.id,
      viewingSystemEvent: _systemEventForKey(systemMessageKey),
      messageKey: systemMessageKey,
      locale: locale,
      params: {'slot': slotText, 'detail': detail},
      confirmedAtIso: confirmedAtIso,
    );

    final recipient = notifyViewer ? request.viewerId : request.ownerId;
    await _notifications.notifyViewingUpdated(
      recipientUserId: recipient,
      listingId: request.listingId,
      listingTitle: listingTitle,
      requestId: request.id,
      kind: notifyKind,
      detail: detail.isNotEmpty ? detail : slotText,
      locale: locale,
    );

    if (next.status == HousingViewingStatus.declined ||
        next.status == HousingViewingStatus.expired) {
      await _reminders.cancelForViewing(request.id);
    } else if (scheduleReminders && confirmedSlot != null) {
      await _reminders.scheduleForConfirmedViewing(
        requestId: request.id,
        listingId: request.listingId,
        listingTitle: listingTitle,
        confirmedAt: confirmedSlot,
        locale: locale,
      );
    }

    return next;
  }

  static String _systemEventForKey(String messageKey) {
    return switch (messageKey) {
      'hv_chat_confirmed' => 'confirmed',
      'hv_chat_declined' => 'declined',
      'hv_chat_countered' => 'countered',
      _ => 'confirmed',
    };
  }
}
