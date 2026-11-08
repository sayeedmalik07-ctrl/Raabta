/// Earned Wage Access (EWA) — static informational copy for Money Hub (Part B).
///
/// Manually updated when provider terms change. No live fetch, no AI, no backend.
/// Qatar-specific fee/eligibility figures are intentionally omitted where unconfirmed.
abstract final class EwaAwarenessConstants {
  static const title = 'Earned Wage Access';

  static const subtitle = 'Get paid early';

  /// Plain-language category description — no provider-specific Qatar fees.
  static const explanation =
      'Earned Wage Access lets employees access a portion of wages they have '
      'already earned before payday. It is not a loan or credit line — when '
      'offered through an employer programme, amounts are typically repaid '
      'automatically from your next paycheck. EWA products generally do not '
      'report to credit bureaus.';

  /// Must stay prominent — employer-gated access (Liabify FAQ + category norm).
  static const employerGateTitle = 'Employer partnership required';

  static const employerGateBody =
      'You cannot sign up for earned wage access on your own. Your specific '
      'employer must already have partnered with and integrated a provider into '
      'payroll. Raabta cannot check whether your employer offers this and cannot '
      'guarantee availability to you.';

  static const providersIntro =
      'Qatar-relevant examples in this space (informational only — not ranked, '
      'not endorsed by Raabta):';

  static const disclaimer =
      'This is informational only. Raabta does not offer, process, or '
      'guarantee earned wage access — this is a third-party financial service. '
      'Availability depends entirely on your employer\'s own partnerships. '
      'Review the provider\'s own terms before using any linked service.';

  static const learnMoreLabel = 'Learn more';

  static const referEmployerLabel = 'Refer your employer';

  static const providers = <EwaProviderReference>[
    EwaProviderReference(
      name: 'Liabify',
      summary:
          'Qatar-founded payroll fintech (QSTP, Doha). Live employer partnerships '
          'are rolling out in Qatar — e.g. Almana Group — while Liabify pursues '
          'QCB licensing. Employees can only use it after their employer integrates payroll.',
      learnMoreUrl: 'https://www.liabify.com/',
      referEmployerUrl: 'https://www.liabify.com/',
      referEmployerLabel: 'Refer your employer (Liabify)',
    ),
    EwaProviderReference(
      name: 'RatbiPlus',
      summary:
          'Doha-based platform offering Sharia-compliant earned-wage access through '
          'employer enrollment. Company signup and payroll integration required — '
          'not individual self-serve.',
      learnMoreUrl: 'https://ratbiplus.com/',
      referEmployerUrl: 'https://form.typeform.com/to/h1I71R0K',
      referEmployerLabel: 'Contact RatbiPlus for employers',
    ),
  ];
}

/// Neutral third-party pointer — no ranking, no affiliate params.
class EwaProviderReference {
  const EwaProviderReference({
    required this.name,
    required this.summary,
    required this.learnMoreUrl,
    required this.referEmployerUrl,
    required this.referEmployerLabel,
  });

  final String name;
  final String summary;
  final String learnMoreUrl;
  final String referEmployerUrl;
  final String referEmployerLabel;
}
