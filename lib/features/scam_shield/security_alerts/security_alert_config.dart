/// Phase 30 defaults — Sayeed may flip [kSecurityTipDefaultEnabled] after review.
abstract final class SecurityAlertConfig {
  static const kSecurityTipDefaultEnabled = true;

  static const minTipIntervalDays = 28;
  static const maxTipIntervalDays = 35;
  static const tipPostponeDays = 14;
  static const maxConsecutiveUnopenedTips = 3;
  static const maxSecurityPushesPerWeek = 1;

  static const advisoryCampaignDays = 5;
  static const monthlyTipCampaignDays = 2;
  static const postIncidentCampaignDays = 3;

  /// Attention scorer composite cap — never outrank bill/legal deadlines.
  static const todayCardMaxComposite = 0.32;

  static const localNotificationIdTip = 8830101;
}
