/// Buddy System Part A — consent version and role/tenure constants.
abstract final class BuddyConstants {
  static const consentVersion = 'buddy_v1';

  static const yearsBandUnder1 = 'under_1_year';
  static const yearsBand1To3 = '1_3_years';
  static const yearsBand3Plus = '3_plus_years';

  static const allYearsBands = [
    yearsBandUnder1,
    yearsBand1To3,
    yearsBand3Plus,
  ];

  static const helperEligibleYearsBands = [
    yearsBand1To3,
    yearsBand3Plus,
  ];

  static const maxSpokenLanguages = 5;
  static const maxInterestTags = 5;
  static const maxNicknameLength = 40;

  // Part B — matching and requests
  static const maxSuggestionCount = 3;
  static const candidateQueryLimit = 50;
  static const matchClientCacheTtl = Duration(minutes: 20);

  static const maxPendingRequestsPerNewcomer = 3;
  static const maxActiveThreadsPerHelper = 3;
  static const maxDailyRequestsPerUser = 5;

  static const requestExpiryDays = 7;
  static const introTextMaxLength = 400;

  static const requestStatusPending = 'pending';
  static const requestStatusAccepted = 'accepted';
  static const requestStatusDeclined = 'declined';
  static const requestStatusExpired = 'expired';
  static const requestStatusCancelled = 'cancelled';

  static const threadStatusActive = 'active';
  static const threadStatusEnded = 'ended';
}
