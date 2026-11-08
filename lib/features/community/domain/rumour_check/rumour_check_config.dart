/// Rumour Check domain constants (Part A0 — no persistence or UI).
abstract final class RumourCheckConfig {
  /// Firestore / model discriminator for ordinary Ask Qatar questions.
  static const String standardQuestionKind = 'standard';

  /// Discriminator for forwarded-claim rumour threads.
  static const String rumourCheckKind = 'rumour_check';

  /// Matches Ask Qatar title minimum and Firestore create rule.
  static const int minClaimLength = 8;

  /// Matches Ask Qatar composer title [maxLength].
  static const int maxTitleLength = 200;

  /// Matches [CommunityModerationConfig.groupPostMaxLength] for combined post text.
  static const int maxClaimTextLength = 2000;

  /// Context note max length (Ask Qatar answers use comment moderation limits).
  static const int maxContextNoteLength = 800;

  static const List<String> rumourCategoryIds = [
    'visa',
    'labour',
    'housing',
    'fees',
    'health',
    'other',
  ];

  /// Display status string tokens for UI / Firestore read models (Part A1+).
  static const String statusOpen = 'open';
  static const String statusContextAdded = 'context_added';
  static const String statusCommunityVerified = 'community_verified';
}
