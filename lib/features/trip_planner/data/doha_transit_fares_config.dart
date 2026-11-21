/// Official Doha Metro / Lusail Tram fares — bundled, deterministic, offline.
///
/// Primary source: Qatar Rail Fares Policy (English), Version 5, valid from
/// 05/08/2024:
/// https://www.qr.com.qa/media/Qatar%20Rail%20Fares%20Policy%20-%20ENG%20-%2005-08-2024.pdf
///
/// Figures below are aligned to that policy per product audit (Oct 2026). The PDF
/// was not re-opened during this bundle update.
abstract final class DohaTransitFaresConfig {
  DohaTransitFaresConfig._();

  static const currencyCode = 'QAR';

  static const faresPolicyPdfUrl =
      'https://www.qr.com.qa/media/Qatar%20Rail%20Fares%20Policy%20-%20ENG%20-%2005-08-2024.pdf';

  static const qatarRailHomeUrl = 'https://www.qr.com.qa/home';

  static const qatarRailSiteUrl = 'https://www.qr.com.qa';

  static const metrolinkInfoUrl = 'https://www.qr.com.qa/metrolink';

  /// Policy document effective date (official historical fact), not verification.
  static const sourcePolicyValidFromIso = '2024-08-05';

  /// Last in-repo engineering review of bundle alignment — not official verification.
  static const bundleInternalReviewIso = '2026-10-16';

  /// Deprecated alias — do not use as [TrustLabelType.verified] date.
  static const bundleLastReviewedIso = bundleInternalReviewIso;

  /// True only after the current Fares Policy PDF was manually inspected end-to-end.
  static const manualPolicyFetchVerified = false;

  /// ISO date when [manualPolicyFetchVerified] was last set true; null while unverified.
  static const String? officialSourceVerifiedIso = null;

  static const stalenessThresholdDays = 90;

  static const confirmedFares = <DohaTransitFareEntry>[
    DohaTransitFareEntry(
      id: 'standard_single_journey',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.singleJourney,
      amountQar: 2,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey:
          'Reusable Standard travel pass with travel credit; flat fare any distance.',
      isPerJourneyFare: true,
    ),
    DohaTransitFareEntry(
      id: 'standard_daily_cap_travel_credit',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.reusableDailyCap,
      amountQar: 6,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey:
          'Automatic daily cap on travel credit after three chargeable single fares; valid tap-in/tap-out required. Not a paper day pass.',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'standard_paper_day_pass',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.paperDayPass,
      amountQar: 6,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey:
          'Limited-use paper product; unlimited journeys until 02:59 after purchase.',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'standard_paper_weekly_pass',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.paperWeeklyPass,
      amountQar: 40,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey:
          'Limited-use paper Standard weekly pass; seven days from purchase.',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'standard_travel_card_purchase',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.cardPurchase,
      amountQar: 10,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey:
          'One-time reusable Standard/Family travel pass cost (excludes preloaded travel credit).',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'gold_single_journey',
      travelClass: DohaTransitTravelClass.goldClub,
      productKind: DohaTransitFareProductKind.singleJourney,
      amountQar: 10,
      networks: DohaTransitNetwork.metroOnly,
      conditionsKey: 'Gold Club class; not available on Lusail Tram.',
      isPerJourneyFare: true,
    ),
    DohaTransitFareEntry(
      id: 'gold_daily_cap_travel_credit',
      travelClass: DohaTransitTravelClass.goldClub,
      productKind: DohaTransitFareProductKind.reusableDailyCap,
      amountQar: 30,
      networks: DohaTransitNetwork.metroOnly,
      conditionsKey:
          'Automatic daily cap on Gold travel credit after three chargeable singles; valid tap-in/tap-out required.',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'gold_paper_day_pass',
      travelClass: DohaTransitTravelClass.goldClub,
      productKind: DohaTransitFareProductKind.paperDayPass,
      amountQar: 30,
      networks: DohaTransitNetwork.metroOnly,
      conditionsKey: 'Limited-use Gold paper day pass until 02:59 after purchase.',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'gold_travel_card_purchase',
      travelClass: DohaTransitTravelClass.goldClub,
      productKind: DohaTransitFareProductKind.cardPurchase,
      amountQar: 100,
      networks: DohaTransitNetwork.metroOnly,
      conditionsKey: 'One-time goldclub travel pass cost (non-refundable).',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'standard_minimum_travel_balance',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.policyRule,
      amountQar: 2,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey:
          'Minimum travel credit on Standard pass to tap in, even when daily cap reached.',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'travel_credit_top_up_min',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.policyRule,
      amountQar: 10,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey: 'Minimum top-up amount on reusable travel pass.',
      isPerJourneyFare: false,
    ),
    DohaTransitFareEntry(
      id: 'travel_credit_top_up_max',
      travelClass: DohaTransitTravelClass.standardFamily,
      productKind: DohaTransitFareProductKind.policyRule,
      amountQar: 500,
      networks: DohaTransitNetwork.metroAndTram,
      conditionsKey: 'Maximum travel credit stored on one reusable travel pass.',
      isPerJourneyFare: false,
    ),
  ];

  /// Described in policy but price not confirmed in this bundle — not for calculators.
  static const unverifiedProducts = <DohaTransitUnverifiedProduct>[
    DohaTransitUnverifiedProduct(
      id: 'standard_monthly_pass',
      description:
          'Monthly / 30-day pass (30 consecutive days from activation); official price not bundled.',
    ),
    DohaTransitUnverifiedProduct(
      id: 'annual_pass',
      description: '365-day pass — not listed as confirmed in Fares Policy v5 excerpt.',
    ),
    DohaTransitUnverifiedProduct(
      id: 'gold_weekly_monthly_pass',
      description: 'Gold weekly/monthly unlimited products — not confirmed for bundling.',
    ),
    DohaTransitUnverifiedProduct(
      id: 'concession_fares',
      description:
          'Concession/discount fares — see Conditions of Carriage; amounts not bundled.',
    ),
  ];

  static const metrolinkNote =
      'Metrolink feeder buses are free with eligible Qatar Rail / Karwa tap-in credentials (informational only).';

  static DohaTransitFareEntry? entryById(String id) {
    for (final entry in confirmedFares) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static DohaTransitFareEntry get standardSingleJourney =>
      entryById('standard_single_journey')!;

  static double get standardSingleJourneyQar => standardSingleJourney.amountQar;

  static double get standardDailyCapQar =>
      entryById('standard_daily_cap_travel_credit')!.amountQar;

  static double get standardTravelCardQar =>
      entryById('standard_travel_card_purchase')!.amountQar;

  static Iterable<DohaTransitFareEntry> get calculatorEligibleFares =>
      confirmedFares.where(
        (e) =>
            e.productKind != DohaTransitFareProductKind.cardPurchase &&
            e.productKind != DohaTransitFareProductKind.policyRule,
      );

  static DohaTransitSourceFreshness sourceFreshness({DateTime? asOf}) =>
      evaluateSourceFreshness(
        manualPolicyFetchVerified: manualPolicyFetchVerified,
        officialSourceVerifiedIso: officialSourceVerifiedIso,
        asOf: asOf,
        stalenessThresholdDays: stalenessThresholdDays,
      );

  static bool get isOfficialSourceVerified =>
      manualPolicyFetchVerified &&
      officialSourceVerifiedIso != null &&
      officialSourceVerifiedIso!.trim().isNotEmpty;

  static bool isVerifiedAndCurrent({DateTime? asOf}) =>
      sourceFreshness(asOf: asOf) ==
      DohaTransitSourceFreshness.verifiedAndCurrent;

  /// Stale only when manually verified but verification date is older than threshold.
  static bool isVerificationStale({DateTime? asOf}) =>
      sourceFreshness(asOf: asOf) ==
      DohaTransitSourceFreshness.verificationStale;

  /// Prefer [sourceFreshness] / [isVerificationStale]. Never true while unverified.
  static bool isBundleStale({DateTime? asOf}) => isVerificationStale(asOf: asOf);

  static bool canPresentAsVerifiedAndCurrent({DateTime? asOf}) =>
      isVerifiedAndCurrent(asOf: asOf);

  /// Params for localized metro copy ({single}, {dailyCap}, {cardCost}).
  static Map<String, String> standardMetroCopyParams() {
    String fmt(double v) => v.toStringAsFixed(0);
    return {
      'single': fmt(standardSingleJourneyQar),
      'dailyCap': fmt(standardDailyCapQar),
      'cardCost': fmt(standardTravelCardQar),
    };
  }

  static String get officialSourceAttribution =>
      'Qatar Rail Fares Policy v5 ($sourcePolicyValidFromIso)';
}

enum DohaTransitSourceFreshness {
  /// No manual end-to-end check of the current Fares Policy PDF.
  sourceNotVerified,

  /// Manually verified and within [stalenessThresholdDays].
  verifiedAndCurrent,

  /// Manually verified but verification date exceeds [stalenessThresholdDays].
  verificationStale,
}

DohaTransitSourceFreshness evaluateSourceFreshness({
  required bool manualPolicyFetchVerified,
  required String? officialSourceVerifiedIso,
  DateTime? asOf,
  int stalenessThresholdDays = DohaTransitFaresConfig.stalenessThresholdDays,
}) {
  if (!manualPolicyFetchVerified ||
      officialSourceVerifiedIso == null ||
      officialSourceVerifiedIso.trim().isEmpty) {
    return DohaTransitSourceFreshness.sourceNotVerified;
  }
  final verified = DateTime.parse(officialSourceVerifiedIso);
  final now = asOf ?? DateTime.now();
  if (now.difference(verified).inDays > stalenessThresholdDays) {
    return DohaTransitSourceFreshness.verificationStale;
  }
  return DohaTransitSourceFreshness.verifiedAndCurrent;
}

enum DohaTransitTravelClass { standardFamily, goldClub }

enum DohaTransitNetwork { metroAndTram, metroOnly }

enum DohaTransitFareProductKind {
  singleJourney,
  reusableDailyCap,
  paperDayPass,
  paperWeeklyPass,
  cardPurchase,
  policyRule,
}

class DohaTransitFareEntry {
  const DohaTransitFareEntry({
    required this.id,
    required this.travelClass,
    required this.productKind,
    required this.amountQar,
    required this.networks,
    required this.conditionsKey,
    required this.isPerJourneyFare,
  });

  final String id;
  final DohaTransitTravelClass travelClass;
  final DohaTransitFareProductKind productKind;
  final double amountQar;
  final DohaTransitNetwork networks;
  final String conditionsKey;
  final bool isPerJourneyFare;

  String get sourceUrl => DohaTransitFaresConfig.faresPolicyPdfUrl;

  String get sourceAttribution => DohaTransitFaresConfig.officialSourceAttribution;
}

class DohaTransitUnverifiedProduct {
  const DohaTransitUnverifiedProduct({
    required this.id,
    required this.description,
  });

  final String id;
  final String description;
}
