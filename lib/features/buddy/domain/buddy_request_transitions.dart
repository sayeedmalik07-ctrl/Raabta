import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/models/buddy_request.dart';

enum BuddyRequestAction {
  accept,
  decline,
  cancel,
}

abstract final class BuddyRequestTransitions {
  static bool canTransition({
    required BuddyRequest request,
    required BuddyRequestAction action,
    required String actorUid,
  }) {
    if (request.effectiveStatus != BuddyConstants.requestStatusPending) {
      return false;
    }
    return switch (action) {
      BuddyRequestAction.accept => request.toUid == actorUid,
      BuddyRequestAction.decline => request.toUid == actorUid,
      BuddyRequestAction.cancel => request.fromUid == actorUid,
    };
  }

  static String statusForAction(BuddyRequestAction action) {
    return switch (action) {
      BuddyRequestAction.accept => BuddyConstants.requestStatusAccepted,
      BuddyRequestAction.decline => BuddyConstants.requestStatusDeclined,
      BuddyRequestAction.cancel => BuddyConstants.requestStatusCancelled,
    };
  }
}
