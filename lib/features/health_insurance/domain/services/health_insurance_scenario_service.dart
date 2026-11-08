import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/data/moph_registered_insurers.dart';
import 'package:raabta/features/health_insurance/domain/calculators/insurance_compliance_checker.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_exemption.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_scenario.dart';
import 'package:raabta/features/health_insurance/domain/services/insurer_lookup_service.dart';

/// Compares Part A compliance across hypothetical inputs — deterministic only.
class HealthInsuranceScenarioService {
  const HealthInsuranceScenarioService({
    required InsuranceComplianceChecker baseChecker,
    InsurerLookupService? insurerLookup,
  })  : _baseChecker = baseChecker,
        _insurerLookup = insurerLookup;

  final InsuranceComplianceChecker _baseChecker;
  final InsurerLookupService? _insurerLookup;

  ComplianceCheckResult calculateBase(InsuranceComplianceInput base) =>
      _baseChecker.check(base);

  List<HealthInsuranceScenario> simulate(InsuranceComplianceInput base) {
    if (HealthInsuranceExemptionRules.isExempt(base.exemptionCategory)) {
      return [];
    }

    final baseResult = _baseChecker.check(base);
    final baseSeverity = _severityScore(baseResult);
    final scenarios = <HealthInsuranceScenario>[];
    final insurers = MophRegisteredInsurers.defaultInsurers;

    void add({
      required String id,
      required String titleKey,
      required String descriptionKey,
      required InsuranceComplianceInput input,
      InsuranceComplianceChecker? checker,
    }) {
      final engine = checker ?? _baseChecker;
      final result = engine.check(input);
      scenarios.add(
        HealthInsuranceScenario(
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

    final currentInsurer = base.insurerName.trim().isNotEmpty
        ? base.insurerName.trim()
        : base.insurerCardLabel.trim();
    final altInsurer = insurers.firstWhere(
      (name) => name.toLowerCase() != currentInsurer.toLowerCase(),
      orElse: () => insurers.first,
    );

    add(
      id: 'switch_insurer',
      titleKey: 'hi_scenario_switch_insurer_title',
      descriptionKey: 'hi_scenario_switch_insurer_desc',
      input: base.copyWith(
        insurerName: altInsurer,
        insurerCardLabel: altInsurer,
        insurerManualReview: false,
      ),
    );

    final now = DateTime.now();
    final priorEnd = now.subtract(const Duration(days: 10));
    final gapStart = now.subtract(const Duration(days: 2));
    add(
      id: 'insurer_switch_gap',
      titleKey: 'hi_scenario_switch_gap_title',
      descriptionKey: 'hi_scenario_switch_gap_desc',
      input: base.copyWith(
        hadInsurerSwitch: true,
        insurerName: altInsurer,
        insurerCardLabel: altInsurer,
        previousPolicyEndDate: priorEnd,
        newPolicyStartDate: gapStart,
      ),
    );

    final staleChecker = InsuranceComplianceChecker(
      mophInsurers: _baseChecker.mophInsurers,
      insurerLookup: _insurerLookup,
      mophListLastVerified: now.subtract(const Duration(days: 200)),
    );
    add(
      id: 'moph_list_stale',
      titleKey: 'hi_scenario_moph_stale_title',
      descriptionKey: 'hi_scenario_moph_stale_desc',
      input: base,
      checker: staleChecker,
    );

    return scenarios;
  }

  static int _severityScore(ComplianceCheckResult result) {
    if (result.hasUnresolvedViolation) return 4;
    if (result.items.any(
      (item) => item.status == HealthComplianceStatus.violation,
    )) {
      return 3;
    }
    if (result.items.any(
      (item) => item.status == HealthComplianceStatus.needsVerification,
    )) {
      return 2;
    }
    return 1;
  }

  static String _differenceSummaryKey(
    ComplianceCheckResult base,
    ComplianceCheckResult scenario,
  ) {
    if (base.hasUnresolvedViolation != scenario.hasUnresolvedViolation) {
      return scenario.hasUnresolvedViolation
          ? 'hi_scenario_diff_violation_added'
          : 'hi_scenario_diff_violation_removed';
    }
    final baseStale = base.items.any(
      (item) => item.explanationKey == 'hi_check_insurer_stale_list',
    );
    final scenarioStale = scenario.items.any(
      (item) => item.explanationKey == 'hi_check_insurer_stale_list',
    );
    if (!baseStale && scenarioStale) {
      return 'hi_scenario_diff_moph_stale';
    }
    final baseGap = base.items
        .where((item) => item.id == 'insurer_switch_gap')
        .map((item) => item.status)
        .firstOrNull;
    final scenarioGap = scenario.items
        .where((item) => item.id == 'insurer_switch_gap')
        .map((item) => item.status)
        .firstOrNull;
    if (baseGap != scenarioGap &&
        scenarioGap == HealthComplianceStatus.violation) {
      return 'hi_scenario_diff_coverage_gap';
    }
    return 'hi_scenario_diff_status_changed';
  }
}
