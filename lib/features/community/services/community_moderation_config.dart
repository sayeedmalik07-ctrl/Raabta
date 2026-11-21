/// Tunable knobs for community submission pre-filter and dedup.
abstract final class CommunityModerationConfig {
  static const int eventTitleMinLength = 5;
  static const int eventDescriptionMinLength = 10;
  static const int eventLocationMinLength = 3;

  static const int lostFoundTitleMinLength = 4;
  static const int lostFoundDescriptionMinLength = 8;
  static const int lostFoundLocationMinLength = 3;
  static const int lostFoundContactMinLength = 5;

  static const int maxTitleLength = 120;
  static const int maxDescriptionLength = 2500;
  static const int maxLocationLength = 200;

  /// Reuse moderation decisions for identical resubmissions within this window.
  static const Duration dedupTtl = Duration(hours: 4);

  /// Client-side news cache aligned with backend TTL.
  static const Duration newsClientCacheTtl = Duration(minutes: 20);

  // ─── Group post / comment moderation ─────────────────────────────────────

  static const int groupPostMinLength = 2;
  static const int groupPostMaxLength = 2000;
  static const int groupCommentMinLength = 1;
  static const int groupCommentMaxLength = 800;

  /// Max Claude moderation calls per user per rolling hour.
  static const int maxAiModerationCallsPerUserPerHour = 24;

  /// Moderation block categories — adjust labels here without touching call logic.
  static const String categoryProfanity = 'profanity';
  static const String categoryHateSpeechPerson = 'hate-speech-person';
  static const String categoryHateSpeechReligion = 'hate-speech-religion';
  static const String categoryHateSpeechNationality = 'hate-speech-nationality';
  static const String categoryAntiStateContent = 'anti-state-content';
  static const String categorySexualContent = 'sexual-content';
  static const String categoryInvestmentFinancialOpportunity =
      'investment-financial-opportunity';
  static const String categoryFundraisingSolicitation =
      'fundraising-solicitation';

  /// When true, [moderationWarnCategories] use confirm interstitial; when false, hard block.
  static const bool moderationWarnCategoriesUseSoftInterstitial = true;

  /// Hard-block categories — auto-block before posting.
  static const List<String> moderationBlockCategories = [
    categoryProfanity,
    categoryHateSpeechPerson,
    categoryHateSpeechReligion,
    categoryHateSpeechNationality,
    categoryAntiStateContent,
    categorySexualContent,
  ];

  /// Warn-then-confirm categories — interstitial, not hard block.
  static const List<String> moderationWarnCategories = [
    categoryInvestmentFinancialOpportunity,
    categoryFundraisingSolicitation,
  ];

  static bool isWarnCategory(String? category) =>
      category != null && moderationWarnCategories.contains(category);

  /// Hard-block categories eligible for respectful rewrite (Part B). Part A uses
  /// this only to decide guidelines vs. message-only block UI.
  static const List<String> rephraseEligibleCategories = [
    categoryProfanity,
    categoryHateSpeechPerson,
  ];

  static bool isRephraseEligibleCategory(String? category) =>
      category != null && rephraseEligibleCategories.contains(category);

  /// Part B — respectful rewrite via Claude (separate daily server quota).
  static const String rephraseRequestType = 'community_content_rephrase';

  /// Max AI rewrite attempts per blocked draft session (client guard).
  static const int maxRephraseAttemptsPerDraft = 2;

  /// Max length for an AI rewrite suggestion.
  static const int maxRephraseRewriteLength = groupPostMaxLength;

  /// All categories sent to Claude classification (block + warn).
  static const List<String> moderationAiCategories = [
    ...moderationBlockCategories,
    ...moderationWarnCategories,
  ];
}
