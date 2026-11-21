import '../models/eosb_employee_input.dart';
import '../models/eosb_enums.dart';
import '../models/eosb_result.dart';
import 'contract_checker.dart';
import 'gratuity_calculator.dart';
import 'leave_calculator.dart';
import 'notice_calculator.dart';
import 'overtime_calculator.dart';
import 'pending_salary_calculator.dart';
import 'ticket_calculator.dart';
import 'violation_detector.dart';

/// Orchestrates modular EOSB calculators for Qatar Labour Law estimates.
class EosbCalculationService {
  const EosbCalculationService();

  EosbResult calculate(EosbEmployeeInput input) {
    final breakdown = <EntitlementBreakdownItem>[
      GratuityCalculator.calculate(input),
      LeaveCalculator.calculate(input),
      NoticeCalculator.calculate(input),
      ...TicketCalculator.calculate(input),
      PendingSalaryCalculator.calculate(input),
      OvertimeCalculator.calculate(input),
    ];

    if (input.otherContractualBenefits > 0) {
      breakdown.add(
        EntitlementBreakdownItem(
          id: 'other_benefits',
          titleKey: 'eosb_other_benefits',
          amount: input.otherContractualBenefits,
          formulaKey: 'eosb_other_benefits_formula',
          ruleKey: 'eosb_other_benefits_rule',
          exampleKey: 'eosb_other_benefits_example',
        ),
      );
    }

    if (input.annualBonus > 0) {
      breakdown.add(
        EntitlementBreakdownItem(
          id: 'annual_bonus',
          titleKey: 'eosb_annual_bonus',
          amount: input.annualBonus,
          formulaKey: 'eosb_annual_bonus_formula',
          ruleKey: 'eosb_annual_bonus_rule',
          exampleKey: 'eosb_annual_bonus_example',
        ),
      );
    }

    if (input.commission > 0) {
      breakdown.add(
        EntitlementBreakdownItem(
          id: 'commission',
          titleKey: 'eosb_commission',
          amount: input.commission,
          formulaKey: 'eosb_commission_formula',
          ruleKey: 'eosb_commission_rule',
          exampleKey: 'eosb_commission_example',
        ),
      );
    }

    if (input.retentionBonus > 0) {
      breakdown.add(
        EntitlementBreakdownItem(
          id: 'retention_bonus',
          titleKey: 'eosb_retention_bonus',
          amount: input.retentionBonus,
          formulaKey: 'eosb_retention_bonus_formula',
          ruleKey: 'eosb_retention_bonus_rule',
          exampleKey: 'eosb_retention_bonus_example',
        ),
      );
    }

    final total = breakdown.fold<double>(0, (sum, item) => sum + item.amount);
    final contractWarnings = ContractChecker.check(input);
    final violations = ViolationDetector.detect(input, breakdown);

    final warnings = [...contractWarnings, ..._buildResultWarnings(input, breakdown)];

    EmployerComparison? comparison;
    if (input.employerOffer != null && input.employerOffer! > 0) {
      comparison = _buildComparison(input.employerOffer!, total, breakdown);
    }

    final confidence = _confidenceScore(input, breakdown);

    return EosbResult(
      totalEntitlement: total,
      breakdown: breakdown,
      warnings: warnings,
      violations: violations,
      explanation: CalculationExplanation(
        summaryKey: 'eosb_explanation_summary',
        confidenceScore: confidence,
        stepsKeys: const [
          'eosb_step_gratuity',
          'eosb_step_leave',
          'eosb_step_notice',
          'eosb_step_ticket',
        ],
      ),
      comparison: comparison,
      calculatedAt: DateTime.now(),
    );
  }

  List<WarningItem> _buildResultWarnings(
    EosbEmployeeInput input,
    List<EntitlementBreakdownItem> breakdown,
  ) {
    final warnings = <WarningItem>[];

    if (input.unusedLeaveDays > 0) {
      final leave = breakdown.where((b) => b.id == 'leave').map((b) => b.amount).firstOrNull ?? 0;
      if (leave <= 0) {
        warnings.add(
          const WarningItem(
            severity: EosbWarningSeverity.violation,
            titleKey: 'eosb_warn_leave_encashment',
            explanationKey: 'eosb_warn_leave_encashment_exp',
            actionKey: 'eosb_warn_leave_encashment_action',
          ),
        );
      }
    }

    if (!input.noticeServed &&
        input.terminationType == EosbTerminationType.employerTermination) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.warning,
          titleKey: 'eosb_warn_notice_comp',
          explanationKey: 'eosb_warn_notice_comp_exp',
          actionKey: 'eosb_warn_notice_comp_action',
        ),
      );
    }

    if (input.pendingSalary > 0) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.info,
          titleKey: 'eosb_warn_pending_salary',
          explanationKey: 'eosb_warn_pending_salary_exp',
          actionKey: 'eosb_warn_pending_salary_action',
        ),
      );
    }

    return warnings;
  }

  EmployerComparison _buildComparison(
    double offer,
    double estimate,
    List<EntitlementBreakdownItem> breakdown,
  ) {
    final diff = estimate - offer;
    final underpaid = diff > 0;
    final disputes = <DisputeItem>[];

    if (underpaid) {
      for (final item in breakdown) {
        if (item.amount <= 0) continue;
        final share = item.amount / estimate;
        final gap = diff * share;
        if (gap > 100) {
          disputes.add(
            DisputeItem(
              issueKey: item.titleKey,
              explanationKey: item.ruleKey,
              riskLevelKey: gap > 2000 ? 'eosb_risk_high' : 'eosb_risk_medium',
              ruleKey: item.ruleKey,
              actionKey: 'eosb_dispute_action_request',
              confidence: 0.75,
              amountGap: gap,
            ),
          );
        }
      }
    }

    final steps = underpaid
        ? const [
            'eosb_step_compare_document',
            'eosb_step_compare_hr',
            'eosb_step_compare_adlsa',
          ]
        : const ['eosb_step_compare_fair'];

    return EmployerComparison(
      employerOffer: offer,
      legalEstimate: estimate,
      difference: diff.abs(),
      isUnderpaid: underpaid,
      disputes: disputes,
      suggestedStepsKeys: steps,
    );
  }

  double _confidenceScore(
    EosbEmployeeInput input,
    List<EntitlementBreakdownItem> breakdown,
  ) {
    var score = 0.5;
    if (input.basicSalary > 0) score += 0.15;
    if (input.joiningDate != null && input.lastWorkingDate != null) score += 0.15;
    if (input.totalSalary > 0) score += 0.1;
    if (breakdown.any((b) => b.amount > 0)) score += 0.1;
    return score.clamp(0.0, 0.95);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final i = iterator;
    if (i.moveNext()) return i.current;
    return null;
  }
}
