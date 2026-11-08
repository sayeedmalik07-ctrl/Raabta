import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/domain/calculators/insurance_compliance_checker.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_exemption.dart';
import 'package:raabta/features/health_insurance/domain/models/premium_deduction_status.dart';
import 'package:raabta/features/home/domain/health_insurance_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/features/home/l10n/truth_chip_health_insurance_strings.dart';

void main() {
  final now = DateTime(2026, 6, 15);
  final checker = InsuranceComplianceChecker();

  ComplianceCheckResult savedResult({
    required InsuranceComplianceInput input,
    required DateTime checkedAt,
  }) {
    final live = checker.check(input);
    return ComplianceCheckResult(
      items: live.items,
      checkedAt: checkedAt,
      hasUnresolvedViolation: live.hasUnresolvedViolation,
      isExemptSession: live.isExemptSession,
      appliedExemption: live.appliedExemption,
    );
  }

  final sensitivePattern = RegExp(
    r'employer|AXA|Qatar Insurance',
    caseSensitive: false,
  );

  group('HealthInsuranceTruthChipMapper — invite', () {
    test('missing saved data → invite', () {
      final status = HealthInsuranceTruthChipMapper.map(
        input: null,
        result: null,
        now: now,
      );
      expect(status.state, TruthChipState.invite);
      expect(status.statusText, contains('policy'));
    });
  });

  group('HealthInsuranceTruthChipMapper — tracked', () {
    test('active policy window → covered until month', () {
      final start = now.subtract(const Duration(days: 100));
      final input = InsuranceComplianceInput(
        newPolicyStartDate: start,
        insurerName: 'Hidden Insurer Co',
      );
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.tracked);
      expect(status.statusText, contains('Covered until'));
      expect(status.statusText, isNot(contains('Hidden')));
      expect(status.progress, isNotNull);
    });

    test('exempt session → exemption recorded', () {
      final input = const InsuranceComplianceInput(
        exemptionCategory:
            HealthInsuranceExemptionCategory.diplomatSpouseOrChildUnder16,
      );
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.statusText, 'Exemption recorded');
    });
  });

  group('HealthInsuranceTruthChipMapper — gap and violations', () {
    test('saved gap violation → urgent', () {
      final input = InsuranceComplianceInput(
        hadInsurerSwitch: true,
        previousPolicyEndDate: DateTime(2026, 1, 1),
        newPolicyStartDate: DateTime(2026, 1, 10),
      );
      final live = checker.check(input);
      expect(
        live.items.any(
          (i) =>
              i.id == 'insurer_switch_gap' &&
              i.status == HealthComplianceStatus.violation,
        ),
        isTrue,
      );

      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.statusText, 'Coverage gap flagged');
    });

    test('premium violation without gap → compliance issue', () {
      const input = InsuranceComplianceInput(
        premiumDeductionStatus: PremiumDeductionStatus.deductionReported,
      );
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.statusText, 'Compliance issue flagged');
    });
  });

  group('HealthInsuranceTruthChipMapper — renewal bands', () {
    test('70 days to renewal → attention', () {
      final end = now.add(const Duration(days: 70));
      final start = end.subtract(
        const Duration(days: TruthChipHealthInsuranceStrings.annualCoverageDays),
      );
      final input = InsuranceComplianceInput(newPolicyStartDate: start);
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.attention);
      expect(status.pillText, '70d');
    });

    test('20 days to renewal → urgent', () {
      final end = now.add(const Duration(days: 20));
      final start = end.subtract(
        const Duration(days: TruthChipHealthInsuranceStrings.annualCoverageDays),
      );
      final input = InsuranceComplianceInput(newPolicyStartDate: start);
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
    });
  });

  group('HealthInsuranceTruthChipMapper — cover ended', () {
    test('coverage end in the past → urgent ended', () {
      final input = InsuranceComplianceInput(
        previousPolicyEndDate: now.subtract(const Duration(days: 10)),
      );
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.statusText, 'Cover ended');
    });
  });

  group('HealthInsuranceTruthChipMapper — stale', () {
    test('checkedAt older than 90 days → Refresh', () {
      final start = now.subtract(const Duration(days: 50));
      final input = InsuranceComplianceInput(newPolicyStartDate: start);
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(
          input: input,
          checkedAt: now.subtract(
            Duration(days: TruthChipUrgencyThresholds.staleDataAgeDays + 1),
          ),
        ),
        now: now,
      );
      expect(status.state, TruthChipState.stale);
      expect(status.pillText, 'Refresh');
    });

    test('gap urgent beats stale', () {
      final input = InsuranceComplianceInput(
        hadInsurerSwitch: true,
        previousPolicyEndDate: DateTime(2026, 1, 1),
        newPolicyStartDate: DateTime(2026, 1, 15),
      );
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(
          input: input,
          checkedAt: now.subtract(const Duration(days: 120)),
        ),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.statusText, 'Coverage gap flagged');
    });
  });

  group('HealthInsuranceTruthChipMapper — privacy', () {
    test('insurer only in revealed field', () {
      final start = now.subtract(const Duration(days: 30));
      final input = InsuranceComplianceInput(
        newPolicyStartDate: start,
        insurerName: 'Qatar Insurance Co',
      );
      final status = HealthInsuranceTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(sensitivePattern.hasMatch(status.statusText), isFalse);
      expect(status.hasRevealableDetail, isTrue);
      expect(status.revealedText, contains('Qatar Insurance'));
    });
  });
}
