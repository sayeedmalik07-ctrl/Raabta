import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';

/// Neutral outcome for optional employer-termination dismissal review.
/// Does not affect gratuity calculation — informational only.
enum EosbDismissalReviewOutcome {
  notApplicable,
  skipped,
  incomplete,
  noReviewFlags,
  factsWorthReviewing,
}

abstract final class DismissalDisputeAssessment {
  /// Deterministic review from user answers — never estimates compensation
  /// or determines arbitrary dismissal.
  static EosbDismissalReviewOutcome evaluate(EosbEmployeeInput input) {
    if (input.terminationType != EosbTerminationType.employerTermination) {
      return EosbDismissalReviewOutcome.notApplicable;
    }

    if (input.dismissalReviewSkipped) {
      return EosbDismissalReviewOutcome.skipped;
    }

    if (!_isComplete(input)) {
      return EosbDismissalReviewOutcome.incomplete;
    }

    if (_factsWorthReviewing(input)) {
      return EosbDismissalReviewOutcome.factsWorthReviewing;
    }

    return EosbDismissalReviewOutcome.noReviewFlags;
  }

  static bool _isComplete(EosbEmployeeInput input) {
    final reasonGiven = input.dismissalReviewReasonGiven;
    if (reasonGiven == null) return false;

    if (reasonGiven && input.dismissalReviewMatchesArt61Ground == null) {
      return false;
    }

    return input.dismissalReviewProcessFollowed != null;
  }

  /// Flags facts worth reviewing — not arbitrary dismissal, not a legal claim.
  static bool _factsWorthReviewing(EosbEmployeeInput input) {
    final reasonGiven = input.dismissalReviewReasonGiven!;
    final processFollowed = input.dismissalReviewProcessFollowed!;

    // Q1 = No alone must not trigger review.
    if (!reasonGiven) {
      return !processFollowed;
    }

    final matchesArt61 = input.dismissalReviewMatchesArt61Ground!;
    if (!matchesArt61) {
      return true;
    }

    return !processFollowed;
  }
}
