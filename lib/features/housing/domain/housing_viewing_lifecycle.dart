import 'package:raabta/features/housing/domain/housing_viewing_request.dart';

/// Deterministic viewing-request state machine — no AI.
abstract final class HousingViewingLifecycle {
  HousingViewingLifecycle._();

  static const requestValidity = Duration(hours: 48);

  static DateTime expiryFromNow([DateTime? from]) =>
      (from ?? DateTime.now()).add(requestValidity);

  static HousingViewingRequest expireIfNeeded(HousingViewingRequest request) {
    if (!request.isExpired) return request;
    return request.copyWith(status: HousingViewingStatus.expired);
  }

  static HousingViewingRequest? ownerConfirm(
    HousingViewingRequest request,
    DateTime slot,
  ) {
    if (request.status != HousingViewingStatus.pending) return null;
    if (request.isExpired) {
      return request.copyWith(status: HousingViewingStatus.expired);
    }
    if (!_containsSlot(request.proposedSlots, slot)) return null;
    return request.copyWith(
      status: HousingViewingStatus.confirmed,
      confirmedAt: slot,
    );
  }

  static HousingViewingRequest? ownerDecline(HousingViewingRequest request) {
    if (request.status != HousingViewingStatus.pending &&
        request.status != HousingViewingStatus.awaitingViewer) {
      return null;
    }
    if (request.isExpired) {
      return request.copyWith(status: HousingViewingStatus.expired);
    }
    return request.copyWith(status: HousingViewingStatus.declined);
  }

  static HousingViewingRequest? ownerCounter(
    HousingViewingRequest request,
    List<DateTime> counterSlots,
  ) {
    if (request.status != HousingViewingStatus.pending) return null;
    if (request.hasOwnerCountered) return null;
    if (counterSlots.isEmpty) return null;
    if (request.isExpired) {
      return request.copyWith(status: HousingViewingStatus.expired);
    }
    return request.copyWith(
      proposedSlots: counterSlots,
      status: HousingViewingStatus.awaitingViewer,
      expiresAt: expiryFromNow(),
      hasOwnerCountered: true,
    );
  }

  static HousingViewingRequest? viewerAcceptCounter(
    HousingViewingRequest request,
    DateTime slot,
  ) {
    if (request.status != HousingViewingStatus.awaitingViewer) return null;
    if (request.isExpired) {
      return request.copyWith(status: HousingViewingStatus.expired);
    }
    if (!_containsSlot(request.proposedSlots, slot)) return null;
    return request.copyWith(
      status: HousingViewingStatus.confirmed,
      confirmedAt: slot,
    );
  }

  static HousingViewingRequest? viewerDeclineCounter(
    HousingViewingRequest request,
  ) {
    if (request.status != HousingViewingStatus.awaitingViewer) return null;
    if (request.isExpired) {
      return request.copyWith(status: HousingViewingStatus.expired);
    }
    return request.copyWith(status: HousingViewingStatus.declined);
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
