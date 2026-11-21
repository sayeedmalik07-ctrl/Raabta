/// Verified reference figures for the Job Offer True-Value Calculator.
///
/// Only government/multilateral sources — no fabricated datasets.
/// Figures verified at build time (Sep 2026); reporting period always shown in UI.
abstract final class JobOfferReferenceData {
  JobOfferReferenceData._();

  // ── Law No. 17 of 2020 — minimum wage (ILO + GCO confirmed unchanged 2026) ──

  static const double minimumWageBasic = 1000;
  static const double minimumWageHousingAllowance = 500;
  static const double minimumWageFoodAllowance = 300;
  static const double minimumWageTotalIfNoInKind = 1800;

  static const String minimumWageCitation =
      'Law No. 17 of 2020 (effective March 2021)';
  static const String minimumWageVerificationNote =
      'Structure verified unchanged as of Sep 2026 (ILO migrant-worker factsheet; '
      'GCO labour reform page). Minimum Wage Committee may review periodically.';

  // ── QNPS / NPC Labour Force Sample Survey ──

  /// Average monthly wage, paid employment, age 15+, all nationalities/sectors.
  /// Latest published quarterly wave at build verification: Q4 2024, Table 7.
  static const double qnpsNationalAverageMonthlyWage = 12416;

  static const String qnpsReportingPeriod = 'Q4 2024';
  static const String qnpsCitation =
      'Qatar National Planning Council, Labour Force Sample Survey, Table 7';

  static const String qnpsDataCurrencyNote =
      'Official Qatar wage data is published periodically (quarterly/yearly), not '
      'monthly. The figure below is from the latest published survey wave — it may '
      'be several quarters old. No 2025 or 2026 QNPS wage wave was published at '
      'build verification.';
}
