import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';

/// Inputs for rumour card display state (Part A0 — no Firestore).
class RumourDisplayStatusInput {
  const RumourDisplayStatusInput({
    required this.contextNoteCount,
    required this.trustedCommunityVerified,
    this.hasOfficialSourceOnAnyNote = false,
  });

  final int contextNoteCount;

  /// Must be supplied only from server-side verification (Part C). When false,
  /// [RumourDisplayStatus.communityVerified] is never returned regardless of notes
  /// or official URLs.
  final bool trustedCommunityVerified;

  /// Informational only — must not affect verification status in this resolver.
  final bool hasOfficialSourceOnAnyNote;
}

abstract final class RumourDisplayStatusResolver {
  static RumourDisplayStatus resolve(RumourDisplayStatusInput input) {
    if (input.trustedCommunityVerified) {
      return RumourDisplayStatus.communityVerified;
    }
    if (input.contextNoteCount > 0) {
      return RumourDisplayStatus.contextAdded;
    }
    return RumourDisplayStatus.open;
  }
}
