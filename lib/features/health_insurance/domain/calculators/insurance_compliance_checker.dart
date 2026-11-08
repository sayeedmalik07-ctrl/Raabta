import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/data/moph_registered_insurers.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_exemption.dart';
import 'package:raabta/features/health_insurance/domain/models/premium_deduction_status.dart';
import 'package:raabta/features/health_insurance/domain/services/insurer_lookup_service.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';

/// Deterministic, Dart-only compliance checks for Law No. 22 of 2021 (Part A).
class InsuranceComplianceChecker {
  InsuranceComplianceChecker({
    List<String>? mophInsurers,
    this.insurerLookup,
    this.mophListLastVerified,
    this.mophListStaleThresholdDays = 180,
  }) : mophInsurers = mophInsurers ?? MophRegisteredInsurers.defaultInsurers;

  final List<String> mophInsurers;
  final InsurerLookupService? insurerLookup;
  final DateTime? mophListLastVerified;
  final int mophListStaleThresholdDays;

  bool get isMophListStale {
    final verified = mophListLastVerified ??
        insurerLookup?.snapshot.lastVerified ??
        DateTime(2026, 6, 1);
    return DateTime.now().difference(verified).inDays > mophListStaleThresholdDays;
  }

  ComplianceCheckResult check(InsuranceComplianceInput input) {
    if (HealthInsuranceExemptionRules.isExempt(input.exemptionCategory)) {
      return _exemptResult(input.exemptionCategory);
    }

    final items = <ComplianceCheckItem>[
      _checkPremiumPayment(input),
      _checkInsuranceCard(input),
      _checkMophInsurer(input),
      _checkQidRenewalProof(input),
      _checkInsurerSwitchGap(input),
    ];

    final hasViolation = items.any(
      (i) => i.status == HealthComplianceStatus.violation,
    );

    return ComplianceCheckResult(
      items: items,
      checkedAt: DateTime.now(),
      hasUnresolvedViolation: hasViolation,
    );
  }

  /// Returns true when coverage start is more than one calendar day after prior end.
  static bool hasCoverageGap(DateTime previousEnd, DateTime newStart) {
    final end = DateTime(previousEnd.year, previousEnd.month, previousEnd.day);
    final start = DateTime(newStart.year, newStart.month, newStart.day);
    return start.isAfter(end.add(const Duration(days: 1)));
  }

  ComplianceCheckResult _exemptResult(HealthInsuranceExemptionCategory category) {
    return ComplianceCheckResult(
      items: [
        ComplianceCheckItem(
          id: 'exemption_confirmation',
          titleKey: 'hi_exemption_result_title',
          explanationKey: HealthInsuranceExemptionRules.confirmationKey(category),
          actionKey: 'hi_exemption_result_action',
          status: HealthComplianceStatus.informational,
          ruleKey: 'cabinet_decision_9_2023',
          metadata: category.name,
        ),
      ],
      checkedAt: DateTime.now(),
      hasUnresolvedViolation: false,
      isExemptSession: true,
      appliedExemption: category,
    );
  }

  ComplianceCheckItem _checkPremiumPayment(InsuranceComplianceInput input) {
    switch (input.premiumDeductionStatus) {
      case PremiumDeductionStatus.unanswered:
        return const ComplianceCheckItem(
          id: 'premium_payment',
          titleKey: 'hi_check_premium_title',
          explanationKey: 'hi_check_premium_unanswered',
          actionKey: 'hi_check_premium_action',
          status: HealthComplianceStatus.needsVerification,
          ruleKey: 'law_22_art_13',
        );
      case PremiumDeductionStatus.noDeduction:
        return const ComplianceCheckItem(
          id: 'premium_payment',
          titleKey: 'hi_check_premium_title',
          explanationKey: 'hi_check_premium_pass',
          actionKey: 'hi_check_premium_action_pass',
          status: HealthComplianceStatus.compliant,
          ruleKey: 'law_22_art_13',
        );
      case PremiumDeductionStatus.deductionReported:
        return const ComplianceCheckItem(
          id: 'premium_payment',
          titleKey: 'hi_check_premium_title',
          explanationKey: 'hi_check_premium_violation',
          actionKey: 'hi_check_premium_action_violation',
          status: HealthComplianceStatus.violation,
          ruleKey: 'law_22_art_13',
        );
      case PremiumDeductionStatus.notSure:
        return const ComplianceCheckItem(
          id: 'premium_payment',
          titleKey: 'hi_check_premium_title',
          explanationKey: 'hi_check_premium_not_sure',
          actionKey: 'hi_check_premium_action_not_sure',
          status: HealthComplianceStatus.informational,
          ruleKey: 'law_22_art_13',
        );
    }
  }

  ComplianceCheckItem _checkInsuranceCard(InsuranceComplianceInput input) {
    final hasCard = input.hasInsuranceCard;
    if (hasCard == null) {
      return const ComplianceCheckItem(
        id: 'insurance_card',
        titleKey: 'hi_check_card_title',
        explanationKey: 'hi_check_card_unanswered',
        actionKey: 'hi_check_card_action',
        status: HealthComplianceStatus.needsVerification,
        ruleKey: 'law_22_art_13',
      );
    }
    if (hasCard) {
      return const ComplianceCheckItem(
        id: 'insurance_card',
        titleKey: 'hi_check_card_title',
        explanationKey: 'hi_check_card_pass',
        actionKey: 'hi_check_card_action_pass',
        status: HealthComplianceStatus.compliant,
        ruleKey: 'law_22_art_13',
      );
    }
    return const ComplianceCheckItem(
      id: 'insurance_card',
      titleKey: 'hi_check_card_title',
      explanationKey: 'hi_check_card_violation',
      actionKey: 'hi_check_card_action_violation',
      status: HealthComplianceStatus.violation,
      ruleKey: 'law_22_art_13',
    );
  }

  ComplianceCheckItem _checkMophInsurer(InsuranceComplianceInput input) {
    final cardLabel = input.insurerCardLabel.trim().isNotEmpty
        ? input.insurerCardLabel.trim()
        : input.insurerName.trim();
    final name = input.insurerName.trim();

    if (cardLabel.isEmpty && name.isEmpty) {
      return const ComplianceCheckItem(
        id: 'moph_insurer',
        titleKey: 'hi_check_insurer_title',
        explanationKey: 'hi_check_insurer_unanswered',
        actionKey: 'hi_check_insurer_action',
        status: HealthComplianceStatus.needsVerification,
        ruleKey: 'law_22_art_11',
      );
    }

    if (isMophListStale) {
      return const ComplianceCheckItem(
        id: 'moph_insurer',
        titleKey: 'hi_check_insurer_title',
        explanationKey: 'hi_check_insurer_stale_list',
        actionKey: 'hi_check_insurer_action_stale',
        status: HealthComplianceStatus.needsVerification,
        ruleKey: 'law_22_art_11',
      );
    }

    if (input.insurerManualReview) {
      return const ComplianceCheckItem(
        id: 'moph_insurer',
        titleKey: 'hi_check_insurer_title',
        explanationKey: 'hi_check_insurer_manual_review',
        actionKey: 'hi_check_insurer_action_manual',
        status: HealthComplianceStatus.needsVerification,
        ruleKey: 'law_22_art_11',
      );
    }

    final lookup = insurerLookup?.resolve(cardLabel.isNotEmpty ? cardLabel : name);
    if (lookup != null &&
        lookup.matchType == InsurerLookupMatchType.tpaAmbiguous) {
      return const ComplianceCheckItem(
        id: 'moph_insurer',
        titleKey: 'hi_check_insurer_title',
        explanationKey: 'hi_check_insurer_tpa_ambiguous',
        actionKey: 'hi_check_insurer_action_tpa',
        status: HealthComplianceStatus.needsVerification,
        ruleKey: 'law_22_art_11',
      );
    }

    final checkName = lookup?.resolvedInsurerName ?? name;
    if (checkName.isEmpty) {
      return const ComplianceCheckItem(
        id: 'moph_insurer',
        titleKey: 'hi_check_insurer_title',
        explanationKey: 'hi_check_insurer_not_found',
        actionKey: 'hi_check_insurer_action_not_found',
        status: HealthComplianceStatus.needsVerification,
        ruleKey: 'law_22_art_11',
      );
    }

    final registered = insurerLookup?.isRegisteredInsurer(checkName) ??
        mophInsurers.any(
          (i) =>
              i.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ==
              checkName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '),
        );

    if (registered) {
      final explanationKey = lookup != null &&
              (lookup.matchType == InsurerLookupMatchType.brandedPlan ||
                  lookup.matchType == InsurerLookupMatchType.aliasMatch ||
                  lookup.matchType == InsurerLookupMatchType.tpaMapped)
          ? 'hi_check_insurer_mapped_pass'
          : 'hi_check_insurer_pass';
      return ComplianceCheckItem(
        id: 'moph_insurer',
        titleKey: 'hi_check_insurer_title',
        explanationKey: explanationKey,
        actionKey: 'hi_check_insurer_action_pass',
        status: HealthComplianceStatus.compliant,
        ruleKey: 'law_22_art_11',
        metadata: lookup?.userMessage,
      );
    }

    return const ComplianceCheckItem(
      id: 'moph_insurer',
      titleKey: 'hi_check_insurer_title',
      explanationKey: 'hi_check_insurer_not_found',
      actionKey: 'hi_check_insurer_action_not_found',
      status: HealthComplianceStatus.needsVerification,
      ruleKey: 'law_22_art_11',
    );
  }

  ComplianceCheckItem _checkQidRenewalProof(InsuranceComplianceInput input) {
    final proof = input.qidRenewalProofProvided;
    if (proof == null) {
      return const ComplianceCheckItem(
        id: 'qid_renewal_proof',
        titleKey: 'hi_check_qid_title',
        explanationKey: 'hi_check_qid_unanswered',
        actionKey: 'hi_check_qid_action',
        status: HealthComplianceStatus.informational,
        ruleKey: 'law_22_art_10',
      );
    }
    if (proof) {
      return const ComplianceCheckItem(
        id: 'qid_renewal_proof',
        titleKey: 'hi_check_qid_title',
        explanationKey: 'hi_check_qid_pass',
        actionKey: 'hi_check_qid_action_pass',
        status: HealthComplianceStatus.informational,
        ruleKey: 'law_22_art_10',
      );
    }
    return const ComplianceCheckItem(
      id: 'qid_renewal_proof',
      titleKey: 'hi_check_qid_title',
      explanationKey: 'hi_check_qid_flag',
      actionKey: 'hi_check_qid_action_flag',
      status: HealthComplianceStatus.needsVerification,
      ruleKey: 'law_22_art_10',
    );
  }

  ComplianceCheckItem _checkInsurerSwitchGap(InsuranceComplianceInput input) {
    if (!input.hadInsurerSwitch) {
      return const ComplianceCheckItem(
        id: 'insurer_switch_gap',
        titleKey: 'hi_check_gap_title',
        explanationKey: 'hi_check_gap_not_applicable',
        actionKey: 'hi_check_gap_action_na',
        status: HealthComplianceStatus.notApplicable,
        ruleKey: 'law_22_art_10',
      );
    }

    final oldEnd = input.previousPolicyEndDate;
    final newStart = input.newPolicyStartDate;
    if (oldEnd == null || newStart == null) {
      return const ComplianceCheckItem(
        id: 'insurer_switch_gap',
        titleKey: 'hi_check_gap_title',
        explanationKey: 'hi_check_gap_dates_missing',
        actionKey: 'hi_check_gap_action_missing',
        status: HealthComplianceStatus.needsVerification,
        ruleKey: 'law_22_art_10',
      );
    }

    if (hasCoverageGap(oldEnd, newStart)) {
      return const ComplianceCheckItem(
        id: 'insurer_switch_gap',
        titleKey: 'hi_check_gap_title',
        explanationKey: 'hi_check_gap_violation',
        actionKey: 'hi_check_gap_action_violation',
        status: HealthComplianceStatus.violation,
        ruleKey: 'law_22_art_10',
      );
    }

    return const ComplianceCheckItem(
      id: 'insurer_switch_gap',
      titleKey: 'hi_check_gap_title',
      explanationKey: 'hi_check_gap_pass',
      actionKey: 'hi_check_gap_action_pass',
      status: HealthComplianceStatus.compliant,
      ruleKey: 'law_22_art_10',
    );
  }
}
