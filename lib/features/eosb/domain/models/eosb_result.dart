import 'eosb_enums.dart';
import 'eosb_employee_input.dart';

/// Single line item in an EOSB entitlement breakdown.
class EntitlementBreakdownItem {
  const EntitlementBreakdownItem({
    required this.id,
    required this.titleKey,
    required this.amount,
    required this.formulaKey,
    required this.ruleKey,
    required this.exampleKey,
    this.isEstimated = true,
  });

  final String id;
  final String titleKey;
  final double amount;
  final String formulaKey;
  final String ruleKey;
  final String exampleKey;
  final bool isEstimated;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleKey': titleKey,
        'amount': amount,
        'formulaKey': formulaKey,
        'ruleKey': ruleKey,
        'exampleKey': exampleKey,
        'isEstimated': isEstimated,
      };

  factory EntitlementBreakdownItem.fromJson(Map<String, dynamic> json) {
    return EntitlementBreakdownItem(
      id: json['id'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      formulaKey: json['formulaKey'] as String? ?? '',
      ruleKey: json['ruleKey'] as String? ?? '',
      exampleKey: json['exampleKey'] as String? ?? '',
      isEstimated: json['isEstimated'] as bool? ?? true,
    );
  }
}

class WarningItem {
  const WarningItem({
    required this.severity,
    required this.titleKey,
    required this.explanationKey,
    required this.actionKey,
    this.readMoreKey,
  });

  final EosbWarningSeverity severity;
  final String titleKey;
  final String explanationKey;
  final String actionKey;
  final String? readMoreKey;

  Map<String, dynamic> toJson() => {
        'severity': severity.name,
        'titleKey': titleKey,
        'explanationKey': explanationKey,
        'actionKey': actionKey,
        'readMoreKey': readMoreKey,
      };
}

class ViolationItem {
  const ViolationItem({
    required this.titleKey,
    required this.explanationKey,
    required this.ruleKey,
    required this.riskLevelKey,
  });

  final String titleKey;
  final String explanationKey;
  final String ruleKey;
  final String riskLevelKey;
}

class DisputeItem {
  const DisputeItem({
    required this.issueKey,
    required this.explanationKey,
    required this.riskLevelKey,
    required this.ruleKey,
    required this.actionKey,
    required this.confidence,
    required this.amountGap,
  });

  final String issueKey;
  final String explanationKey;
  final String riskLevelKey;
  final String ruleKey;
  final String actionKey;
  final double confidence;
  final double amountGap;
}

class EmployerComparison {
  const EmployerComparison({
    required this.employerOffer,
    required this.legalEstimate,
    required this.difference,
    required this.isUnderpaid,
    required this.disputes,
    required this.suggestedStepsKeys,
  });

  final double employerOffer;
  final double legalEstimate;
  final double difference;
  final bool isUnderpaid;
  final List<DisputeItem> disputes;
  final List<String> suggestedStepsKeys;

  double get differencePercent =>
      legalEstimate > 0 ? (difference / legalEstimate) * 100 : 0;
}

class CalculationExplanation {
  const CalculationExplanation({
    required this.summaryKey,
    required this.confidenceScore,
    required this.stepsKeys,
  });

  final String summaryKey;
  final double confidenceScore;
  final List<String> stepsKeys;
}

class EosbResult {
  const EosbResult({
    required this.totalEntitlement,
    required this.breakdown,
    required this.warnings,
    required this.violations,
    required this.explanation,
    this.comparison,
    required this.calculatedAt,
  });

  final double totalEntitlement;
  final List<EntitlementBreakdownItem> breakdown;
  final List<WarningItem> warnings;
  final List<ViolationItem> violations;
  final CalculationExplanation explanation;
  final EmployerComparison? comparison;
  final DateTime calculatedAt;

  double amountFor(String id) {
    for (final item in breakdown) {
      if (item.id == id) return item.amount;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'totalEntitlement': totalEntitlement,
        'breakdown': breakdown.map((e) => e.toJson()).toList(),
        'warnings': warnings.map((e) => e.toJson()).toList(),
        'explanation': {
          'summaryKey': explanation.summaryKey,
          'confidenceScore': explanation.confidenceScore,
          'stepsKeys': explanation.stepsKeys,
        },
        'comparison': comparison == null
            ? null
            : {
                'employerOffer': comparison!.employerOffer,
                'legalEstimate': comparison!.legalEstimate,
                'difference': comparison!.difference,
                'isUnderpaid': comparison!.isUnderpaid,
              },
        'calculatedAt': calculatedAt.toIso8601String(),
      };

  factory EosbResult.fromJson(Map<String, dynamic> json) {
    return EosbResult(
      totalEntitlement: (json['totalEntitlement'] as num?)?.toDouble() ?? 0,
      breakdown: (json['breakdown'] as List<dynamic>? ?? [])
          .map((e) =>
              EntitlementBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      warnings: const [],
      violations: const [],
      explanation: CalculationExplanation(
        summaryKey: (json['explanation'] as Map?)?['summaryKey'] as String? ??
            'eosb_explanation_default',
        confidenceScore:
            ((json['explanation'] as Map?)?['confidenceScore'] as num?)
                    ?.toDouble() ??
                0.8,
        stepsKeys: const [],
      ),
      calculatedAt: DateTime.tryParse(json['calculatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class CalculationHistoryEntry {
  const CalculationHistoryEntry({
    required this.id,
    required this.input,
    required this.result,
    required this.savedAt,
    this.label,
  });

  final String id;
  final EosbEmployeeInput input;
  final EosbResult result;
  final DateTime savedAt;
  final String? label;
}
