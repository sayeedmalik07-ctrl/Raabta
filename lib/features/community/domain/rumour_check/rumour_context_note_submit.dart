import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_official_source_validator.dart';

/// UI label derived from literal URL validation — never persisted as trusted state.
enum RumourContextSourceDisplay {
  none,
  officialAllowlisted,
  sourceNotVerified,
}

class RumourContextNoteSubmitDecision {
  const RumourContextNoteSubmitDecision({
    required this.canSubmit,
    this.officialSourceUrlToStore,
    this.blockReasonKey,
  });

  final bool canSubmit;
  final String? officialSourceUrlToStore;
  final String? blockReasonKey;
}

abstract final class RumourContextNoteSubmit {
  static RumourContextNoteSubmitDecision evaluateSourceUrl(String rawSourceUrl) {
    final trimmed = rawSourceUrl.trim();
    if (trimmed.isEmpty) {
      return const RumourContextNoteSubmitDecision(canSubmit: true);
    }

    final validation = RumourOfficialSourceValidator.validate(trimmed);
    if (validation.shouldBlockSubmission) {
      final key = validation.outcome ==
              RumourOfficialSourceOutcome.rejectedDeceptive
          ? 'community_rumour_source_deceptive'
          : 'community_rumour_source_invalid';
      return RumourContextNoteSubmitDecision(
        canSubmit: false,
        blockReasonKey: key,
      );
    }

    return RumourContextNoteSubmitDecision(
      canSubmit: true,
      officialSourceUrlToStore: trimmed,
    );
  }

  static RumourContextSourceDisplay sourceDisplayForUrl(String? storedUrl) {
    final trimmed = storedUrl?.trim() ?? '';
    if (trimmed.isEmpty) {
      return RumourContextSourceDisplay.none;
    }
    final validation = RumourOfficialSourceValidator.validate(trimmed);
    if (validation.isOfficialAllowlisted) {
      return RumourContextSourceDisplay.officialAllowlisted;
    }
    if (validation.outcome == RumourOfficialSourceOutcome.unverified) {
      return RumourContextSourceDisplay.sourceNotVerified;
    }
    return RumourContextSourceDisplay.sourceNotVerified;
  }
}
