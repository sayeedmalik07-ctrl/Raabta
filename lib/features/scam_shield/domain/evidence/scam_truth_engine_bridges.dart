import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_bridge_topic.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';

/// Typed launch hints — never message text or PII.
enum ScamTruthEngineBridgeHint {
  none,
  jobOfferChecklist,
  jobOfferNumbers,
  employerLookupAfterTap,
  tenancyDeposit,
  sponsorshipTransfer,
  visaDocuments,
  eosbEntitlement,
  overtimeCheck,
  healthPolicy,
  familyVerification,
  remittanceCompare,
  officialDirectoryBrowse,
  officialDirectoryClaimedEntity,
  incidentAfterScam,
  authorityReportDirectory,
}

enum ScamTruthEngineBridgeTarget {
  beforeYouSign,
  jobOfferCalculator,
  employerTrackRecord,
  tenancyTruthEngine,
  sponsorshipTransfer,
  visaDocuments,
  eosbTruthEngine,
  eosbOvertime,
  healthInsurance,
  familyVerificationKit,
  remittanceCorridor,
  officialDirectory,
  incidentResponse,
  authorityDirectory,
  investmentCheck,
  reportReadyPack,
}

class ScamTruthEngineBridgeAction {
  const ScamTruthEngineBridgeAction({
    required this.target,
    required this.routePath,
    required this.labelKey,
    required this.reasonKey,
    this.hint = ScamTruthEngineBridgeHint.none,
    this.paymentContext,
  });

  final ScamTruthEngineBridgeTarget target;
  final String routePath;
  final String labelKey;
  final String reasonKey;
  final ScamTruthEngineBridgeHint hint;
  final PaymentCheckContext? paymentContext;
}

class ScamTruthEngineBridgeTargetMeta {
  const ScamTruthEngineBridgeTargetMeta({
    required this.target,
    required this.routePath,
    required this.labelKey,
    required this.reasonKey,
    required this.isBuilt,
    this.complianceFlagKey,
    this.defaultHint = ScamTruthEngineBridgeHint.none,
    this.paymentContext,
  });

  final ScamTruthEngineBridgeTarget target;
  final String routePath;
  final String labelKey;
  final String reasonKey;
  final bool isBuilt;
  final String? complianceFlagKey;
  final ScamTruthEngineBridgeHint defaultHint;
  final PaymentCheckContext? paymentContext;
}

/// Single typed table: topic → ordered targets (first two available are shown).
abstract final class ScamTruthEngineBridgeTable {
  static const maxVisible = 2;

  /// Canonical target metadata — one row per destination route.
  static const targets = <ScamTruthEngineBridgeTargetMeta>[
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.beforeYouSign,
      routePath: '/prospective/checklist',
      labelKey: 'ss_bridge_before_you_sign_label',
      reasonKey: 'ss_bridge_before_you_sign_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.jobOfferChecklist,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.jobOfferCalculator,
      routePath: '/jobs/offer-calculator',
      labelKey: 'ss_bridge_job_calculator_label',
      reasonKey: 'ss_bridge_job_calculator_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.jobOfferNumbers,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.employerTrackRecord,
      routePath: '/employer-track-record/check',
      labelKey: 'ss_bridge_employer_lookup_label',
      reasonKey: 'ss_bridge_employer_lookup_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.employerLookupAfterTap,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.tenancyTruthEngine,
      routePath: '/tenancy',
      labelKey: 'ss_bridge_tenancy_label',
      reasonKey: 'ss_bridge_tenancy_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.tenancyDeposit,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.sponsorshipTransfer,
      routePath: '/sponsorship-transfer',
      labelKey: 'ss_bridge_sponsorship_label',
      reasonKey: 'ss_bridge_sponsorship_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.sponsorshipTransfer,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.visaDocuments,
      routePath: '/visa',
      labelKey: 'ss_bridge_visa_label',
      reasonKey: 'ss_bridge_visa_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.visaDocuments,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.eosbTruthEngine,
      routePath: '/eosb',
      labelKey: 'ss_bridge_eosb_label',
      reasonKey: 'ss_bridge_eosb_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.eosbEntitlement,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.eosbOvertime,
      routePath: '/eosb/overtime',
      labelKey: 'ss_bridge_overtime_label',
      reasonKey: 'ss_bridge_overtime_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.overtimeCheck,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.healthInsurance,
      routePath: '/health-insurance',
      labelKey: 'ss_bridge_health_insurance_label',
      reasonKey: 'ss_bridge_health_insurance_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.healthPolicy,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.familyVerificationKit,
      routePath: '/scam-shield/family-verification',
      labelKey: 'ss_bridge_family_kit_label',
      reasonKey: 'ss_bridge_family_kit_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.familyVerification,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.remittanceCorridor,
      routePath: '/money-services/corridor-comparator',
      labelKey: 'ss_bridge_remittance_label',
      reasonKey: 'ss_bridge_remittance_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.remittanceCompare,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.officialDirectory,
      routePath: '/scam-shield/official-directory',
      labelKey: 'ss_bridge_official_dir_label',
      reasonKey: 'ss_bridge_official_dir_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.officialDirectoryBrowse,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.incidentResponse,
      routePath: '/scam-shield/incident',
      labelKey: 'ss_bridge_incident_label',
      reasonKey: 'ss_bridge_incident_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.incidentAfterScam,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.authorityDirectory,
      routePath: '/scam-shield/directory',
      labelKey: 'ss_bridge_report_dir_label',
      reasonKey: 'ss_bridge_report_dir_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.authorityReportDirectory,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.investmentCheck,
      routePath: '/scam-shield/investment-check',
      labelKey: 'ss_bridge_investment_check_label',
      reasonKey: 'ss_bridge_investment_check_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.none,
    ),
    ScamTruthEngineBridgeTargetMeta(
      target: ScamTruthEngineBridgeTarget.reportReadyPack,
      routePath: '/scam-shield/report-ready',
      labelKey: 'ss_bridge_report_pack_label',
      reasonKey: 'ss_bridge_report_pack_reason',
      isBuilt: true,
      defaultHint: ScamTruthEngineBridgeHint.authorityReportDirectory,
    ),
  ];

  /// Topic → priority-ordered targets. Comments document product intent per row.
  static const topicRows = <ScamBridgeTopic, List<ScamTruthEngineBridgeTarget>>{
    // Pre-offer job scams: checklist first, then numeric true-value (employer lookup is manual on its screen).
    ScamBridgeTopic.jobOffer: [
      ScamTruthEngineBridgeTarget.beforeYouSign,
      ScamTruthEngineBridgeTarget.jobOfferCalculator,
      ScamTruthEngineBridgeTarget.employerTrackRecord,
    ],
    // Up-front recruitment / visa fees: same tools; fee context is in scan, not passed as text.
    ScamBridgeTopic.recruitmentFee: [
      ScamTruthEngineBridgeTarget.beforeYouSign,
      ScamTruthEngineBridgeTarget.jobOfferCalculator,
    ],
    // Deposit-before-viewing and rental fraud → tenancy hub.
    ScamBridgeTopic.housingDeposit: [
      ScamTruthEngineBridgeTarget.tenancyTruthEngine,
    ],
    // Agent-led visa / sponsorship claims → transfer engine + visa hub.
    ScamBridgeTopic.visaOrSponsorshipAgent: [
      ScamTruthEngineBridgeTarget.sponsorshipTransfer,
      ScamTruthEngineBridgeTarget.visaDocuments,
    ],
    // EOSB / unpaid wages → entitlement calculator and overtime engine.
    ScamBridgeTopic.finalSettlementOrSalary: [
      ScamTruthEngineBridgeTarget.eosbTruthEngine,
      ScamTruthEngineBridgeTarget.eosbOvertime,
    ],
    // Cold-call “insurance” patterns → health insurance truth engine.
    ScamBridgeTopic.insuranceCall: [
      ScamTruthEngineBridgeTarget.healthInsurance,
    ],
    // Family emergency money requests → verification kit + corridor compare.
    ScamBridgeTopic.remittanceEmergency: [
      ScamTruthEngineBridgeTarget.familyVerificationKit,
      ScamTruthEngineBridgeTarget.remittanceCorridor,
    ],
    // MOI/customs fine impersonation → browse official channels (no auto entity jump).
    ScamBridgeTopic.governmentFineOrFee: [
      ScamTruthEngineBridgeTarget.officialDirectory,
    ],
    ScamBridgeTopic.investment: [
      ScamTruthEngineBridgeTarget.investmentCheck,
    ],
    // Post-loss “recovery” follow-ups → incident playbook + authority reporting (report pack TBD).
    ScamBridgeTopic.recoveryOffer: [
      ScamTruthEngineBridgeTarget.incidentResponse,
      ScamTruthEngineBridgeTarget.authorityDirectory,
      ScamTruthEngineBridgeTarget.reportReadyPack,
    ],
    ScamBridgeTopic.eventTickets: [
      ScamTruthEngineBridgeTarget.officialDirectory,
    ],
  };

  static ScamTruthEngineBridgeTargetMeta? metaFor(
    ScamTruthEngineBridgeTarget target,
  ) {
    for (final m in targets) {
      if (m.target == target) return m;
    }
    return null;
  }

  static bool isFlagEnabled(ComplianceFlags flags, String? key) {
    if (key == null) return true;
    return switch (key) {
      ComplianceFlagKeys.offersEnabled => flags.offersEnabled,
      ComplianceFlagKeys.viewingsEnabled => flags.viewingsEnabled,
      ComplianceFlagKeys.quotesEnabled => flags.quotesEnabled,
      _ => true,
    };
  }
}

abstract final class ScamTruthEngineBridgeResolver {
  static List<ScamTruthEngineBridgeAction> resolve({
    required ScamBridgeTopic topic,
    required ComplianceFlags complianceFlags,
    ScamTruthEngineBridgeHint entityHint =
        ScamTruthEngineBridgeHint.none,
  }) {
    if (!topic.isExplicit) return const [];

    final ordered =
        ScamTruthEngineBridgeTable.topicRows[topic] ?? const [];
    final actions = <ScamTruthEngineBridgeAction>[];

    for (final target in ordered) {
      if (actions.length >= ScamTruthEngineBridgeTable.maxVisible) break;
      final meta = ScamTruthEngineBridgeTable.metaFor(target);
      if (meta == null || !meta.isBuilt) continue;
      if (!ScamTruthEngineBridgeTable.isFlagEnabled(
        complianceFlags,
        meta.complianceFlagKey,
      )) {
        continue;
      }

      var hint = meta.defaultHint;
      if (target == ScamTruthEngineBridgeTarget.officialDirectory &&
          entityHint == ScamTruthEngineBridgeHint.officialDirectoryClaimedEntity) {
        hint = ScamTruthEngineBridgeHint.officialDirectoryClaimedEntity;
      }

      actions.add(
        ScamTruthEngineBridgeAction(
          target: target,
          routePath: meta.routePath,
          labelKey: meta.labelKey,
          reasonKey: meta.reasonKey,
          hint: hint,
          paymentContext: meta.paymentContext,
        ),
      );
    }

    return actions;
  }

  /// Validates table integrity for tests.
  static void assertTableIntegrity() {
    final seenTopics = <ScamBridgeTopic>{};
    for (final entry in ScamTruthEngineBridgeTable.topicRows.entries) {
      assert(entry.key != ScamBridgeTopic.none);
      assert(seenTopics.add(entry.key));
    }
    final routesByTarget = <ScamTruthEngineBridgeTarget, String>{};
    for (final meta in ScamTruthEngineBridgeTable.targets) {
      assert(
        routesByTarget.putIfAbsent(meta.target, () => meta.routePath) ==
            meta.routePath,
      );
      assert(meta.routePath.startsWith('/'));
      assert(meta.labelKey.startsWith('ss_bridge_'));
    }
  }
}
