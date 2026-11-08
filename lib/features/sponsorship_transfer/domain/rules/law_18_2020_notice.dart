/// Law No. 18 of 2020 — amends Labour Law 14/2004 (termination notice).
/// NOT Law 19/2020 (sponsorship) or Law 17/2020 (minimum wage).
abstract final class Law182020Notice {
  static const lawIdentifier = 'Law No. 18 of 2020';
  static const amends = 'Law No. 14 of 2004 (Labour Law)';

  /// Written notice if resigning/terminating: 1 month if employed under 2 years,
  /// 2 months if employed 2+ years with current employer.
  static const int noticeMonthsUnderTwoYears = 1;
  static const int noticeMonthsTwoYearsPlus = 2;
  static const int twoYearsThresholdMonths = 24;
}
