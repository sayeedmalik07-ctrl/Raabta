import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_scenario.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_compliance_checker.dart';

/// Compares tenancy compliance across hypothetical lease inputs — deterministic only.
class TenancyScenarioService {
  const TenancyScenarioService(this._checker);

  final TenancyComplianceChecker _checker;

  TenancyComplianceResult calculateBase(TenancyLeaseInput base) =>
      _checker.check(base);

  List<TenancyScenario> simulate(TenancyLeaseInput base) {
    if (base.monthlyRent <= 0 && base.registrationStatus == null) {
      return [];
    }

    final baseResult = _checker.check(base);
    final baseSeverity = _severityScore(baseResult);
    final scenarios = <TenancyScenario>[];

    void add({
      required String id,
      required String titleKey,
      required String descriptionKey,
      required TenancyLeaseInput input,
    }) {
      final result = _checker.check(input);
      scenarios.add(
        TenancyScenario(
          id: id,
          titleKey: titleKey,
          descriptionKey: descriptionKey,
          input: input,
          result: result,
          differenceFromBase: _severityScore(result) - baseSeverity,
          differenceSummaryKey: _differenceSummaryKey(baseResult, result),
        ),
      );
    }

    if (base.monthlyRent > 0 && base.isResidential) {
      add(
        id: 'deposit_over_cap',
        titleKey: 'tenancy_scenario_deposit_over_title',
        descriptionKey: 'tenancy_scenario_deposit_over_desc',
        input: base.copyWith(
          securityDeposit: base.monthlyRent * 3,
          propertyType: TenancyPropertyType.residential,
        ),
      );
    }

    final lateStart = DateTime.now().subtract(const Duration(days: 120));
    add(
      id: 'late_registration',
      titleKey: 'tenancy_scenario_late_reg_title',
      descriptionKey: 'tenancy_scenario_late_reg_desc',
      input: base.copyWith(
        registrationStatus: TenancyRegistrationStatus.no,
        leaseStartDate: lateStart,
      ),
    );

    final recentStart = DateTime.now().subtract(const Duration(days: 20));
    add(
      id: 'late_registration_recent',
      titleKey: 'tenancy_scenario_late_reg_recent_title',
      descriptionKey: 'tenancy_scenario_late_reg_recent_desc',
      input: base.copyWith(
        registrationStatus: TenancyRegistrationStatus.no,
        leaseStartDate: recentStart,
      ),
    );

    return scenarios;
  }

  static int _severityScore(TenancyComplianceResult result) {
    if (result.hasCriticalIssue) return 4;
    if (result.hasViolation) return 3;
    if (result.items.any(
      (item) => item.status == TenancyComplianceStatus.needsVerification,
    )) {
      return 2;
    }
    return 1;
  }

  static String _differenceSummaryKey(
    TenancyComplianceResult base,
    TenancyComplianceResult scenario,
  ) {
    if (base.hasCriticalIssue != scenario.hasCriticalIssue) {
      return scenario.hasCriticalIssue
          ? 'tenancy_scenario_diff_critical_added'
          : 'tenancy_scenario_diff_critical_removed';
    }
    if (base.hasViolation != scenario.hasViolation) {
      return scenario.hasViolation
          ? 'tenancy_scenario_diff_violation_added'
          : 'tenancy_scenario_diff_violation_removed';
    }
    final baseFee = base.lateFeeEstimate?.totalFeeQar ?? 0;
    final scenarioFee = scenario.lateFeeEstimate?.totalFeeQar ?? 0;
    if (baseFee != scenarioFee) {
      return 'tenancy_scenario_diff_late_fee_changed';
    }
    return 'tenancy_scenario_diff_status_changed';
  }
}
