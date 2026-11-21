/// Law No. 9 of 2026 — amendments to Qatar Labour Law (Law No. 14 of 2004).
///
/// **LEGAL REVIEW REQUIRED before shipping:** Exact article numbers, precise
/// statutory wording, and full scope must be verified against the official Al
/// Meezan portal (almeezan.qa) and Ministry of Labour primary guidance.
/// The constants below are structured from legal-analysis summaries (June 2026),
/// not the primary legislative text.
abstract final class LabourLaw92026 {
  static const lawIdentifier = 'Law No. 9 of 2026';
  static const amendsLaw = 'Law No. 14 of 2004';
  static const promulgatedDate = '2026-06-25';
  static final promulgationDateTime = DateTime(2026, 6, 25);

  /// Joint employer–worker committees — threshold raised from 30+ to 100+ workers.
  /// Article reference: **requires legal review**.
  static const jointCommitteeMinWorkers = 100;

  /// Reported administrative fines for non-compliance (verify on Al Meezan).
  static const jointCommitteeFineMinQar = 2000;
  static const jointCommitteeFineMaxQar = 5000;

  /// Article 23 bis — vocational training/examination certificate before starting work
  /// in designated professions (verify scope on Al Meezan).
  static const article23BisTrainingCertificateNote =
      'Law No. 9 of 2026 reportedly adds an Article 23 bis requirement for a '
      'training/examination certificate before starting work in designated '
      'vocational professions — verify designated categories on Al Meezan.';

  /// Part-time and freelance workers excluded from Labour Law coverage by default;
  /// Council of Ministers may extend by decision.
  static const partTimeFreelanceExcludedByDefault = true;

  /// Narrow summary-dismissal ground — gratuity forfeiture only when ALL conditions met.
  /// Exact article: **requires legal review** (reported as new ground in Law 9/2026).
  static const summaryDismissalStrikeIncitementGroundId =
      'unlawful_strike_incitement_disrupts_operations';

  static const summaryDismissalStrikeIncitementDescription =
      'Employer may terminate without notice and without end-of-service gratuity '
      'where the worker unlawfully incited other workers to strike in a manner '
      'that disrupted business operations (Law No. 9 of 2026 — verify exact wording '
      'on Al Meezan before relying on this in a dispute).';

  /// Noncompete durations expanded under Law 9/2026 — Contract Analyzer context only.
  static const noncompeteAmendedNote =
      'Law No. 9 of 2026 reportedly expands permissible noncompete durations — '
      'verify current limits on Al Meezan before contract review.';

  static const verificationNotice =
      'Law No. 9 of 2026 provisions referenced here require verification against '
      'primary sources (Al Meezan / mol.gov.qa) before use in live disputes.';
}
