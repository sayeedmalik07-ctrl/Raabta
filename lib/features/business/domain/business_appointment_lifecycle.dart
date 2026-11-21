import 'package:raabta/features/business/domain/business_appointment_request.dart';

abstract final class BusinessAppointmentLifecycle {
  BusinessAppointmentLifecycle._();

  static const requestValidity = Duration(hours: 48);
  static const maxNoteLength = 500;

  static int expiryFromNowMs([DateTime? from]) =>
      (from ?? DateTime.now()).add(requestValidity).millisecondsSinceEpoch;

  static BusinessAppointmentRequest expireIfNeeded(
    BusinessAppointmentRequest request,
  ) {
    if (!request.isExpired) return request;
    return request.copyWith(
      status: BusinessAppointmentStatus.expired,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessAppointmentRequest? ownerConfirm(
    BusinessAppointmentRequest request,
    DateTime slot,
  ) {
    if (request.status != BusinessAppointmentStatus.pending) return null;
    if (request.isExpired) return _expired(request);
    if (!_containsSlot(request.proposedSlots, slot)) return null;
    final now = DateTime.now();
    return request.copyWith(
      status: BusinessAppointmentStatus.confirmed,
      selectedSlot: slot,
      confirmedAt: slot,
      updatedAt: now,
    );
  }

  static BusinessAppointmentRequest? ownerDecline(
    BusinessAppointmentRequest request,
  ) {
    if (request.status != BusinessAppointmentStatus.pending &&
        request.status != BusinessAppointmentStatus.awaitingRequester) {
      return null;
    }
    if (request.isExpired) return _expired(request);
    return request.copyWith(
      status: BusinessAppointmentStatus.declined,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessAppointmentRequest? ownerCounter(
    BusinessAppointmentRequest request,
    List<DateTime> counterSlots,
  ) {
    if (request.status != BusinessAppointmentStatus.pending) return null;
    if (request.hasOwnerCountered) return null;
    if (counterSlots.isEmpty) return null;
    if (request.isExpired) return _expired(request);
    return request.copyWith(
      proposedSlots: counterSlots,
      status: BusinessAppointmentStatus.awaitingRequester,
      expiresAtMs: expiryFromNowMs(),
      hasOwnerCountered: true,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessAppointmentRequest? requesterAcceptCounter(
    BusinessAppointmentRequest request,
    DateTime slot,
  ) {
    if (request.status != BusinessAppointmentStatus.awaitingRequester) {
      return null;
    }
    if (request.isExpired) return _expired(request);
    if (!_containsSlot(request.proposedSlots, slot)) return null;
    return request.copyWith(
      status: BusinessAppointmentStatus.confirmed,
      selectedSlot: slot,
      confirmedAt: slot,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessAppointmentRequest? requesterDeclineCounter(
    BusinessAppointmentRequest request,
  ) {
    if (request.status != BusinessAppointmentStatus.awaitingRequester) {
      return null;
    }
    if (request.isExpired) return _expired(request);
    return request.copyWith(
      status: BusinessAppointmentStatus.declined,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessAppointmentRequest? requesterCancel(
    BusinessAppointmentRequest request,
  ) {
    if (!request.status.isOpen) return null;
    if (request.isExpired) return _expired(request);
    return request.copyWith(
      status: BusinessAppointmentStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessAppointmentRequest _expired(
    BusinessAppointmentRequest request,
  ) {
    return request.copyWith(
      status: BusinessAppointmentStatus.expired,
      updatedAt: DateTime.now(),
    );
  }

  static bool _containsSlot(List<DateTime> slots, DateTime slot) {
    return slots.any(
      (s) =>
          s.year == slot.year &&
          s.month == slot.month &&
          s.day == slot.day &&
          s.hour == slot.hour &&
          s.minute == slot.minute,
    );
  }
}
