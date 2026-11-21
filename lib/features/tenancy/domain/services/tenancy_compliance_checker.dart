import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/rules/law_4_2008_tenancy.dart';
import 'package:raabta/features/tenancy/domain/rules/law_8_2026_tenancy.dart';
import 'package:raabta/features/tenancy/domain/services/late_registration_fee_calculator.dart';

/// Deterministic tenancy compliance checks — verified legal facts only.
class TenancyComplianceChecker {
  const TenancyComplianceChecker();

  TenancyComplianceResult check(TenancyLeaseInput input) {
    final items = <TenancyComplianceItem>[
      _checkRegistration(input),
      _checkDepositCap(input),
      if (input.isUnregistered) _lateRegistrationFeeItem(input),
      ..._informationalRights(),
    ]..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));

    final feeEstimate = input.isUnregistered
        ? LateRegistrationFeeCalculator.estimate(
            leaseStartDate: input.leaseStartDate,
          )
        : null;

    return TenancyComplianceResult(
      items: items,
      checkedAt: DateTime.now(),
      lateFeeEstimate: feeEstimate,
    );
  }

  TenancyComplianceItem _checkRegistration(TenancyLeaseInput input) {
    final status = input.registrationStatus;
    if (status == TenancyRegistrationStatus.yes) {
      return const TenancyComplianceItem(
        id: 'registration',
        titleKey: 'tenancy_check_registration_title',
        explanationKey: 'tenancy_check_registration_pass',
        actionKey: 'tenancy_check_registration_action_pass',
        status: TenancyComplianceStatus.compliant,
        ruleKey: 'law_4_art_3',
        citationKey: 'tenancy_cite_law4_art3',
        sortPriority: 10,
      );
    }
    if (status == TenancyRegistrationStatus.no) {
      return const TenancyComplianceItem(
        id: 'registration',
        titleKey: 'tenancy_check_registration_title',
        explanationKey: 'tenancy_check_registration_critical_no',
        actionKey: 'tenancy_check_registration_action_no',
        status: TenancyComplianceStatus.critical,
        ruleKey: 'law_4_art_3',
        citationKey: 'tenancy_cite_law4_art3',
        sortPriority: 0,
      );
    }
    if (status == TenancyRegistrationStatus.notSure) {
      return const TenancyComplianceItem(
        id: 'registration',
        titleKey: 'tenancy_check_registration_title',
        explanationKey: 'tenancy_check_registration_critical_unsure',
        actionKey: 'tenancy_check_registration_action_unsure',
        status: TenancyComplianceStatus.critical,
        ruleKey: 'law_4_art_3',
        citationKey: 'tenancy_cite_law4_art3',
        sortPriority: 0,
      );
    }
    return const TenancyComplianceItem(
      id: 'registration',
      titleKey: 'tenancy_check_registration_title',
      explanationKey: 'tenancy_check_registration_unanswered',
      actionKey: 'tenancy_check_registration_action_unanswered',
      status: TenancyComplianceStatus.needsVerification,
      ruleKey: 'law_4_art_3',
      citationKey: 'tenancy_cite_law4_art3',
      sortPriority: 5,
    );
  }

  TenancyComplianceItem _checkDepositCap(TenancyLeaseInput input) {
    if (!input.isResidential) {
      return const TenancyComplianceItem(
        id: 'deposit_cap',
        titleKey: 'tenancy_check_deposit_title',
        explanationKey: 'tenancy_check_deposit_commercial',
        actionKey: 'tenancy_check_deposit_action_commercial',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_4_deposit',
        citationKey: 'tenancy_cite_law4_deposit',
        sortPriority: 20,
      );
    }
    if (input.monthlyRent <= 0) {
      return const TenancyComplianceItem(
        id: 'deposit_cap',
        titleKey: 'tenancy_check_deposit_title',
        explanationKey: 'tenancy_check_deposit_needs_rent',
        actionKey: 'tenancy_check_deposit_action_needs_rent',
        status: TenancyComplianceStatus.needsVerification,
        ruleKey: 'law_4_deposit',
        citationKey: 'tenancy_cite_law4_deposit',
        sortPriority: 20,
      );
    }
    if (input.isDepositOverCap) {
      return const TenancyComplianceItem(
        id: 'deposit_cap',
        titleKey: 'tenancy_check_deposit_title',
        explanationKey: 'tenancy_check_deposit_violation',
        actionKey: 'tenancy_check_deposit_action_violation',
        status: TenancyComplianceStatus.violation,
        ruleKey: 'law_4_deposit',
        citationKey: 'tenancy_cite_law4_deposit',
        sortPriority: 15,
      );
    }
    return const TenancyComplianceItem(
      id: 'deposit_cap',
      titleKey: 'tenancy_check_deposit_title',
      explanationKey: 'tenancy_check_deposit_pass',
      actionKey: 'tenancy_check_deposit_action_pass',
      status: TenancyComplianceStatus.compliant,
      ruleKey: 'law_4_deposit',
      citationKey: 'tenancy_cite_law4_deposit',
      sortPriority: 20,
    );
  }

  TenancyComplianceItem _lateRegistrationFeeItem(TenancyLeaseInput input) {
    final fee = LateRegistrationFeeCalculator.estimate(
      leaseStartDate: input.leaseStartDate,
    );
    final months = fee?.monthsLate ?? 0;
    final explanationKey = months >= 1
        ? 'tenancy_check_late_fee_with_penalty'
        : 'tenancy_check_late_fee_base';
    return TenancyComplianceItem(
      id: 'late_registration_fee',
      titleKey: 'tenancy_check_late_fee_title',
      explanationKey: explanationKey,
      actionKey: 'tenancy_check_late_fee_action',
      status: months >= 1
          ? TenancyComplianceStatus.violation
          : TenancyComplianceStatus.informational,
      ruleKey: 'law_8_art_20_2',
      citationKey: 'tenancy_cite_law8_art20',
      sortPriority: 12,
    );
  }

  List<TenancyComplianceItem> _informationalRights() {
    return const [
      TenancyComplianceItem(
        id: 'rent_payment_window',
        titleKey: 'tenancy_right_rent_payment_title',
        explanationKey: 'tenancy_right_rent_payment_exp',
        actionKey: 'tenancy_right_rent_payment_action',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_4_rent_timing',
        sortPriority: 50,
      ),
      TenancyComplianceItem(
        id: 'maintenance_lapse',
        titleKey: 'tenancy_right_maintenance_title',
        explanationKey: 'tenancy_right_maintenance_exp',
        actionKey: 'tenancy_right_maintenance_action',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_4_maintenance_30',
        sortPriority: 51,
      ),
      TenancyComplianceItem(
        id: 'landlord_refuses_rent',
        titleKey: 'tenancy_right_refused_rent_title',
        explanationKey: 'tenancy_right_refused_rent_exp',
        actionKey: 'tenancy_right_refused_rent_action',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_4_rent_deposit',
        sortPriority: 52,
      ),
      TenancyComplianceItem(
        id: 'ownership_transfer',
        titleKey: 'tenancy_right_ownership_title',
        explanationKey: 'tenancy_right_ownership_exp',
        actionKey: 'tenancy_right_ownership_action',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_4_ownership_30',
        sortPriority: 53,
      ),
      TenancyComplianceItem(
        id: 'committee_jurisdiction',
        titleKey: 'tenancy_right_committee_jurisdiction_title',
        explanationKey: 'tenancy_right_committee_jurisdiction_exp',
        actionKey: 'tenancy_right_committee_jurisdiction_action',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_8_art_22_jurisdiction',
        citationKey: 'tenancy_cite_law8_art22',
        sortPriority: 54,
      ),
      TenancyComplianceItem(
        id: 'committee_timeline',
        titleKey: 'tenancy_right_committee_title',
        explanationKey: 'tenancy_right_committee_exp',
        actionKey: 'tenancy_right_committee_action',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_4_art_22',
        citationKey: 'tenancy_cite_committee_interview',
        sortPriority: 55,
      ),
      TenancyComplianceItem(
        id: 'appeal_window',
        titleKey: 'tenancy_right_appeal_title',
        explanationKey: 'tenancy_right_appeal_exp',
        actionKey: 'tenancy_right_appeal_action',
        status: TenancyComplianceStatus.informational,
        ruleKey: 'law_4_art_24',
        sortPriority: 56,
      ),
    ];
  }
}

/// Exposed for tests and UI formatting.
String tenancyLawDisambiguationNote() =>
    'Law ${Law82026Tenancy.lawIdentifier} amends tenancy (${Law82026Tenancy.amends}). '
    'Law No. 9 of 2026 amends labour law (EOSB) — separate subject.';
