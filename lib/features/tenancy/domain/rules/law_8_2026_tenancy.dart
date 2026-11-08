/// Law No. (8) of 2026 — amendments to property leasing (Law 4/2008).
///
/// DISAMBIGUATION: This is NOT Law No. (9) of 2026 (labour / EOSB).
/// Official Gazette Issue No. 13 of 2026.
abstract final class Law82026Tenancy {
  static const lawIdentifier = 'Law No. 8 of 2026';
  static const amends = 'Law No. 4 of 2008';

  /// Amended Article 20(2) — registration fee per lease transaction.
  static const registrationFeeQar = 250;
  static const registrationFeeArticle = 'Art. 20(2)';

  /// Late registration penalty schedule (any partial month = full month).
  static const latePenaltyMonth1 = 0.25;
  static const latePenaltyMonth2 = 0.50;
  static const latePenaltyMonth3 = 0.75;
  static const latePenaltyBeyondMonth3 = 1.00;

  /// Fine up to QR 10,000 for Art. 3 / Art. 20 bis violations.
  static const maxFineQar = 10000;

  /// Registration-violation settlement fee (Law 8/2026 — reduced from QAR 5,000).
  /// Distinct from [registrationFeeQar] (QR 250 Office fee) and appeal deadlines.
  static const registrationViolationSettlementFeeQar = 1000;
  static const priorRegistrationViolationSettlementFeeQar = 5000;

  /// Art. 20 bis — state-property sub-leases must register within 2 months (fee exempt).
  static const stateSubleaseRegisterDays = 60;
}
