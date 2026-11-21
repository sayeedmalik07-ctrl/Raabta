import 'dart:convert';

import 'package:raabta/features/truth_engine/l10n/truth_package_strings.dart';

/// Structured input contract for Truth Engine Claude explain/assistant calls.
///
/// Data-shape convention only — not a shared engine architecture.
class TruthPackage {
  const TruthPackage({
    required this.engineType,
    this.facts = const {},
    this.calculation = const {},
    this.assumptions = const [],
    this.unknowns = const [],
    this.sourceRefs = const [],
  });

  /// `eosb`, `healthInsurance`, `tenancy`, `sponsorshipTransfer`
  final String engineType;
  final Map<String, dynamic> facts;
  final Map<String, dynamic> calculation;
  final List<String> assumptions;
  final List<String> unknowns;
  final List<String> sourceRefs;

  Map<String, dynamic> toJson() => {
        'engineType': engineType,
        'facts': facts,
        'calculation': calculation,
        'assumptions': assumptions,
        'unknowns': unknowns,
        'sourceRefs': sourceRefs,
      };
}

/// Shared Claude instructions for all Truth Engine explain paths.
abstract final class TruthPackageInstructions {
  static const explainOnly = '''
Explain the following TruthPackage in plain language. Do not restate the calculation math. Do not speculate beyond the facts, assumptions, and unknowns provided. If asked something not covered by this package, say so rather than inventing an answer.''';
}

/// Builds a consistent user-message body from [TruthPackage].
abstract final class TruthPackagePrompt {
  static String build({
    required TruthPackage package,
    required String locale,
    String? preamble,
    String? userQuestion,
    String? trailingInstructions,
  }) {
    final buffer = StringBuffer();
    if (preamble != null && preamble.trim().isNotEmpty) {
      buffer.writeln(preamble.trim());
      buffer.writeln();
    }
    buffer.writeln(TruthPackageInstructions.explainOnly);
    buffer.writeln('Output language: $locale');
    buffer.writeln();
    buffer.writeln('TRUTH PACKAGE (JSON):');
    buffer.writeln(const JsonEncoder.withIndent('  ').convert(package.toJson()));
    if (userQuestion != null && userQuestion.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('User question: ${userQuestion.trim()}');
    }
    if (trailingInstructions != null && trailingInstructions.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln(trailingInstructions.trim());
    }
    return buffer.toString();
  }
}

/// Engine-specific assumptions, unknowns, and legal source refs for AI calls.
abstract final class TruthPackageCatalog {
  static const eosb = 'eosb';
  static const healthInsurance = 'healthInsurance';
  static const tenancy = 'tenancy';
  static const sponsorshipTransfer = 'sponsorshipTransfer';

  static List<String> eosbAssumptions() => const [
        'Document OCR text is complete and legible where fields were extracted.',
        'Extracted salary and date fields reflect the uploaded document as read.',
        'Gratuity is estimated on your final basic wage only; housing, transport, and other allowances are excluded unless separately owed.',
      ];

  static List<String> eosbUnknowns() => const [
        'Whether your employer will accept this calculation or offer is not something Raabta can predict.',
        'Whether additional contract clauses or side agreements exist beyond the uploaded document.',
        'Final entitlement may depend on MoL/LDRC findings not available to this app.',
        'Whether a court or LDRC would find a dismissal arbitrary or unlawful under Article 64 depends on evidence Raabta cannot assess — any compensation is at court discretion with no fixed formula.',
      ];

  static List<String> eosbSourceRefs() => const [
        'Law No. 14 of 2004',
        'Qatar Labour Law No. 14 of 2004, Art. 61',
        'Qatar Labour Law No. 14 of 2004, Art. 62',
        'Qatar Labour Law No. 14 of 2004, Art. 64',
        'Law No. 9 of 2026',
        'Cabinet Resolution No. 6 of 2018 (LDRC)',
        'Law No. 17 of 2018, Workers\' Support and Insurance Fund',
        'Ministry of Labour procedural guidance',
      ];

  static List<String> eosbOvertimeRoundingAssumptions() => const [
        'Shift timestamps reflect what was entered or imported — not a full payroll audit.',
        'Rounding direction is inferred from paired clock-in/clock-out differences.',
      ];

  static List<String> eosbOvertimeRoundingUnknowns() => const [
        'This is a pattern summary from entered shifts — not proof of employer misconduct.',
        'Whether lost minutes qualify as payable overtime depends on contract and MoL review.',
        'Employer rounding policies not shown in the summary cannot be verified here.',
      ];

  static List<String> healthInsurancePolicyAssumptions() => const [
        'OCR text reflects the uploaded policy document as scanned.',
      ];

  static List<String> healthInsurancePolicyUnknowns() => const [
        'Whether your specific insurer or policy has additional clauses not shown in the document.',
        'Network hospital lists and live benefit limits may differ from the scanned copy.',
        'This summary is not a substitute for the insurer’s official policy wording.',
      ];

  static List<String> healthInsurancePolicySourceRefs() => const [
        'Law No. 22 of 2021',
      ];

  static List<String> healthInsuranceDisputeAssumptions() => const [
        'Step text and user-entered dispute facts are taken as provided.',
      ];

  static List<String> healthInsuranceDisputeUnknowns() => const [
        'Whether your insurer or regulator will overturn the denial cannot be predicted.',
        'Response times and outcomes from QCB or QFCRA are not confirmed here.',
        'Medical necessity or clinical details not provided are outside this review.',
      ];

  static List<String> healthInsuranceDisputeSourceRefs() => const [
        'Law No. 22 of 2021',
        'QCB Law No. 13 of 2012',
      ];

  /// Pre-emptive coverage gap guide — statutory minimums (Known).
  static List<String> healthInsuranceCoverageRealityKnown() => const [
        'Law No. 22 of 2021 minimum benefits require outpatient and inpatient care, diagnostics and radiology, essential medicines, hospital stays, mandatory surgical procedures, basic maternity care, emergency care, and coverage for children up to 18.',
      ];

  /// Common exclusion/limit patterns — informational only, not user-specific.
  static List<String> healthInsuranceCoverageRealityPossible() => const [
        'Cosmetic surgery, fertility beyond initial diagnostics, congenital conditions discovered after policy start, dental beyond emergency, optical beyond basic vision correction, alternative medicine, self-inflicted injuries, and maternity sub-limits are commonly excluded or capped in basic policies — verify the user\'s own schedule.',
      ];

  static List<String> healthInsuranceCoverageRealityActions() => const [
        'Ask HR/insurer: HMC in-network and prior approval for elective care; maternity sub-limit; co-insurance on inpatient/outpatient; pre-existing condition waiting periods; dependents (spouse, up to 3 children under 18) listed on the policy.',
        'Request the written dependent benefit schedule from HR; escalate if not provided within roughly a week; plan ahead for maternity given common waiting periods.',
      ];

  /// Dependent coverage addendum — spouse/children/parent gaps (general only).
  static List<String> healthInsuranceDependentCoverageKnown() => const [
        'Employer-paid family coverage under the implementing regulation covers the worker, spouse, and up to three children under 18. Parent coverage is not part of that employer-paid entitlement — sponsored parents require confirmation of applicable sponsor-paid mandatory coverage and any additional policy requirements.',
      ];

  static List<String> healthInsuranceDependentCoveragePossible() => const [
        'Dependent plans may offer reduced benefits compared with the employee plan; maternity waiting periods (often 12 months) are distinct from maternity sub-limits — verify the dependent schedule.',
      ];

  static List<String> healthInsuranceCoverageRealityUnknowns() => const [
        'Raabta does not know the user\'s specific policy terms unless they uploaded a document or entered details in Policy Explainer.',
        'Whether any particular insurer applies these exclusion patterns to this user\'s policy cannot be stated without their policy schedule.',
        'Network lists, live benefit limits, and sub-limit figures are not confirmed here.',
      ];

  static List<String> healthInsuranceCoverageRealitySourceRefs() => const [
        'Law No. 22 of 2021 — minimum benefits package',
      ];

  static List<String> tenancyAssumptions({
    bool registrationUnknown = false,
  }) =>
      [
        'Lease figures and registration status reflect what you entered in the checker.',
        if (registrationUnknown)
          'Lease registration status was not confirmed — checks assume highest uncertainty.',
      ];

  static List<String> tenancyUnknowns() => const [
        'Which Council of Ministers rent-increase decision applies to a specific premises type is not something Raabta can confirm without your case details — confirm with the Committee.',
        'Specific notice day-counts for eviction are not verified as flat facts — confirm with the Committee.',
        'Whether your landlord will agree to registration or deposit terms cannot be predicted.',
        'Committee or court outcomes are not something Raabta can confirm in advance.',
      ];

  static List<String> tenancySourceRefs() => const [
        'Law No. 4 of 2008',
        'Law No. 4 of 2008, Art. 10',
        'Law No. 8 of 2026',
      ];

  static List<String> sponsorshipAssumptions({
    bool noticeUnknown = false,
  }) =>
      [
        'Readiness dates and notice status reflect what you entered in the checker.',
        if (noticeUnknown)
          'Formal notice status was not confirmed — permit window checks use entered dates only.',
      ];

  static List<String> sponsorshipUnknowns() => const [
        'Whether MOI will approve a transfer or how long processing takes cannot be predicted.',
        'Employer cooperation, NOC issuance, and internal HR policies are not visible to Raabta.',
        'Domestic worker transfers (Law 15/2017) are outside this assistant’s scope.',
      ];

  static List<String> sponsorshipSourceRefs() => const [
        'Law No. 19 of 2020',
        'Law No. 18 of 2020',
        'Minister of Interior Decree No. (51) of 2020',
      ];

  // ---------------------------------------------------------------------------
  // Localized display text for UI banners (English lists above stay for AI JSON).
  // ---------------------------------------------------------------------------

  static String eosbAssumptionDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_eosb_assumption_$index', locale);

  static String eosbUnknownDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_eosb_unknown_$index', locale);

  static String eosbOvertimeAssumptionDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_eosb_ot_assumption_$index', locale);

  static String eosbOvertimeUnknownDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_eosb_ot_unknown_$index', locale);

  static String healthInsurancePolicyAssumptionDisplay(
    int index,
    String locale,
  ) =>
      TruthPackageStrings.t('tp_hi_policy_assumption_$index', locale);

  static String healthInsurancePolicyUnknownDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_hi_policy_unknown_$index', locale);

  static String healthInsuranceDisputeAssumptionDisplay(
    int index,
    String locale,
  ) =>
      TruthPackageStrings.t('tp_hi_dispute_assumption_$index', locale);

  static String healthInsuranceDisputeUnknownDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_hi_dispute_unknown_$index', locale);

  static String healthInsuranceCoverageRealityUnknownDisplay(
    int index,
    String locale,
  ) =>
      TruthPackageStrings.t('tp_hi_crc_unknown_$index', locale);

  static String tenancyAssumptionDisplay(
    int index,
    String locale, {
    bool registrationUnknown = false,
  }) {
    if (registrationUnknown && index == 1) {
      return TruthPackageStrings.t(
        'tp_tenancy_assumption_registration_unknown',
        locale,
      );
    }
    return TruthPackageStrings.t('tp_tenancy_assumption_$index', locale);
  }

  static String tenancyUnknownDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_tenancy_unknown_$index', locale);

  static String sponsorshipAssumptionDisplay(
    int index,
    String locale, {
    bool noticeUnknown = false,
  }) {
    if (noticeUnknown && index == 1) {
      return TruthPackageStrings.t(
        'tp_sponsorship_assumption_notice_unknown',
        locale,
      );
    }
    return TruthPackageStrings.t('tp_sponsorship_assumption_$index', locale);
  }

  static String sponsorshipUnknownDisplay(int index, String locale) =>
      TruthPackageStrings.t('tp_sponsorship_unknown_$index', locale);
}
