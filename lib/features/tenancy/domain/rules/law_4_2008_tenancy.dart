/// Law No. (4) of 2008 Regarding Property Leasing — verified tenancy facts.
///
/// Amended by Law No. (8) of 2026 (tenancy). Law No. (9) of 2026 is labour law (EOSB).
abstract final class Law42008Tenancy {
  static const lawIdentifier = 'Law No. 4 of 2008';
  static const amendedBy = 'Law No. 8 of 2026';

  /// Article 3 — unregistered lease blocks Committee/court applications.
  static const registrationArticle = 'Art. 3';

  /// Residential security deposit cap — two months' rent.
  static const depositCapMonthsResidential = 2;

  /// Rent must be paid no later than 7 days after due date.
  static const rentPaymentGraceDays = 7;

  /// Maintenance-based rent reduction claim lapses after 30 days of continued
  /// occupation without objection.
  static const maintenanceClaimLapseDays = 30;

  /// New owner must notify tenant and Office within 30 days (registered letter).
  static const ownershipTransferNotifyDays = 30;

  /// Rental Dispute Committee jurisdiction (Art. 22, as amended by Law 8/2026).
  /// Expanded to all landlord–tenant lease disputes, including Art. 2 exempt cases.
  static const committeeJurisdictionArticle = 'Art. 22';

  /// Court filing requires Committee ruling first (Law 8/2026 amendment).
  static const committeeMandatoryBeforeCourt = true;

  /// Appeal window — 15 days from in-person decision or day after absentia notification.
  static const appealWindowDays = 15;
  static const appealArticle = 'Art. 24';

  /// Statutory Committee decision ceiling (Cabinet Resolution 37/2008 Art. 2).
  static const committeeStatutoryMinMonths = 3;
  static const committeeStatutoryMaxMonths = 6;
}
