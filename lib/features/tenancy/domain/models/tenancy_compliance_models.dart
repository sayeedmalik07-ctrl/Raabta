import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/services/late_registration_fee_calculator.dart';

/// Single compliance or informational line on the results screen.
class TenancyComplianceItem {
  const TenancyComplianceItem({
    required this.id,
    required this.titleKey,
    required this.explanationKey,
    required this.actionKey,
    required this.status,
    this.ruleKey,
    this.citationKey,
    this.sortPriority = 100,
  });

  final String id;
  final String titleKey;
  final String explanationKey;
  final String actionKey;
  final TenancyComplianceStatus status;
  final String? ruleKey;
  final String? citationKey;
  final int sortPriority;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleKey': titleKey,
        'explanationKey': explanationKey,
        'actionKey': actionKey,
        'status': status.name,
        'ruleKey': ruleKey,
        'citationKey': citationKey,
        'sortPriority': sortPriority,
      };

  factory TenancyComplianceItem.fromJson(Map<String, dynamic> json) {
    return TenancyComplianceItem(
      id: json['id'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      explanationKey: json['explanationKey'] as String? ?? '',
      actionKey: json['actionKey'] as String? ?? '',
      status: TenancyComplianceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TenancyComplianceStatus.informational,
      ),
      ruleKey: json['ruleKey'] as String?,
      citationKey: json['citationKey'] as String?,
      sortPriority: json['sortPriority'] as int? ?? 100,
    );
  }
}

class TenancyComplianceResult {
  const TenancyComplianceResult({
    required this.items,
    required this.checkedAt,
    this.lateFeeEstimate,
  });

  final List<TenancyComplianceItem> items;
  final DateTime checkedAt;
  final LateRegistrationFeeEstimate? lateFeeEstimate;

  bool get hasCriticalIssue =>
      items.any((i) => i.status == TenancyComplianceStatus.critical);

  bool get hasViolation =>
      items.any((i) => i.status == TenancyComplianceStatus.violation);

  TenancyComplianceItem? get primaryCritical => items
      .where((i) => i.status == TenancyComplianceStatus.critical)
      .fold<TenancyComplianceItem?>(null, (best, item) {
    if (best == null || item.sortPriority < best.sortPriority) return item;
    return best;
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'checkedAt': checkedAt.toIso8601String(),
        if (lateFeeEstimate != null)
          'lateFeeEstimate': {
            'baseFeeQar': lateFeeEstimate!.baseFeeQar,
            'monthsLate': lateFeeEstimate!.monthsLate,
            'penaltyRate': lateFeeEstimate!.penaltyRate,
            'totalFeeQar': lateFeeEstimate!.totalFeeQar,
          },
      };

  factory TenancyComplianceResult.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    LateRegistrationFeeEstimate? fee;
    final feeMap = json['lateFeeEstimate'] as Map<String, dynamic>?;
    if (feeMap != null) {
      fee = LateRegistrationFeeEstimate(
        baseFeeQar: (feeMap['baseFeeQar'] as num?)?.toDouble() ?? 250,
        monthsLate: feeMap['monthsLate'] as int? ?? 0,
        penaltyRate: (feeMap['penaltyRate'] as num?)?.toDouble() ?? 0,
        totalFeeQar: (feeMap['totalFeeQar'] as num?)?.toDouble() ?? 250,
      );
    }
    return TenancyComplianceResult(
      items: itemsRaw
          .map((e) => TenancyComplianceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkedAt: DateTime.tryParse(json['checkedAt'] as String? ?? '') ??
          DateTime.now(),
      lateFeeEstimate: fee,
    );
  }
}
