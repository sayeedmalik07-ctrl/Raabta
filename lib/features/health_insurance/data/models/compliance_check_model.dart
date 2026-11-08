import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_exemption.dart';
import 'package:raabta/features/health_insurance/domain/models/premium_deduction_status.dart';

/// User answers for Part A — deterministic compliance check.
class InsuranceComplianceInput {
  const InsuranceComplianceInput({
    this.premiumDeductionStatus = PremiumDeductionStatus.unanswered,
    this.exemptionCategory = HealthInsuranceExemptionCategory.none,
    this.hasInsuranceCard,
    this.insurerName = '',
    this.insurerCardLabel = '',
    this.insurerManualReview = false,
    this.qidRenewalProofProvided,
    this.hadInsurerSwitch = false,
    this.previousPolicyEndDate,
    this.newPolicyStartDate,
    this.currentRenewalYear,
  });

  final PremiumDeductionStatus premiumDeductionStatus;
  final HealthInsuranceExemptionCategory exemptionCategory;
  final bool? hasInsuranceCard;

  /// Legacy bool — derived from [premiumDeductionStatus] for cached JSON/tests.
  bool? get employerPaysFullPremium {
    switch (premiumDeductionStatus) {
      case PremiumDeductionStatus.noDeduction:
        return true;
      case PremiumDeductionStatus.deductionReported:
        return false;
      case PremiumDeductionStatus.unanswered:
      case PremiumDeductionStatus.notSure:
        return null;
    }
  }
  /// Resolved MOPH insurer legal name used for registration check.
  final String insurerName;
  /// Name printed on the user's card (TPA / plan / shorthand).
  final String insurerCardLabel;
  final bool insurerManualReview;
  final bool? qidRenewalProofProvided;
  final bool hadInsurerSwitch;
  final DateTime? previousPolicyEndDate;
  final DateTime? newPolicyStartDate;
  final int? currentRenewalYear;

  InsuranceComplianceInput copyWith({
    PremiumDeductionStatus? premiumDeductionStatus,
    HealthInsuranceExemptionCategory? exemptionCategory,
    bool? hasInsuranceCard,
    String? insurerName,
    String? insurerCardLabel,
    bool? insurerManualReview,
    bool? qidRenewalProofProvided,
    bool? hadInsurerSwitch,
    DateTime? previousPolicyEndDate,
    DateTime? newPolicyStartDate,
    int? currentRenewalYear,
  }) {
    return InsuranceComplianceInput(
      premiumDeductionStatus:
          premiumDeductionStatus ?? this.premiumDeductionStatus,
      exemptionCategory: exemptionCategory ?? this.exemptionCategory,
      hasInsuranceCard: hasInsuranceCard ?? this.hasInsuranceCard,
      insurerName: insurerName ?? this.insurerName,
      insurerCardLabel: insurerCardLabel ?? this.insurerCardLabel,
      insurerManualReview: insurerManualReview ?? this.insurerManualReview,
      qidRenewalProofProvided:
          qidRenewalProofProvided ?? this.qidRenewalProofProvided,
      hadInsurerSwitch: hadInsurerSwitch ?? this.hadInsurerSwitch,
      previousPolicyEndDate:
          previousPolicyEndDate ?? this.previousPolicyEndDate,
      newPolicyStartDate: newPolicyStartDate ?? this.newPolicyStartDate,
      currentRenewalYear: currentRenewalYear ?? this.currentRenewalYear,
    );
  }

  Map<String, dynamic> toJson() => {
        'premiumDeductionStatus': premiumDeductionStatus.name,
        'exemptionCategory': exemptionCategory.name,
        'employerPaysFullPremium': employerPaysFullPremium,
        'hasInsuranceCard': hasInsuranceCard,
        'insurerName': insurerName,
        'insurerCardLabel': insurerCardLabel,
        'insurerManualReview': insurerManualReview,
        'qidRenewalProofProvided': qidRenewalProofProvided,
        'hadInsurerSwitch': hadInsurerSwitch,
        'previousPolicyEndDate':
            previousPolicyEndDate?.toIso8601String(),
        'newPolicyStartDate': newPolicyStartDate?.toIso8601String(),
        'currentRenewalYear': currentRenewalYear,
      };

  factory InsuranceComplianceInput.fromJson(Map<String, dynamic> json) {
    return InsuranceComplianceInput(
      premiumDeductionStatus: PremiumDeductionStatusJson.fromJson(
        json['premiumDeductionStatus'],
        legacyEmployerPaysFull: json['employerPaysFullPremium'] as bool?,
      ),
      exemptionCategory: HealthInsuranceExemptionCategory.values.firstWhere(
        (e) => e.name == json['exemptionCategory'],
        orElse: () => HealthInsuranceExemptionCategory.none,
      ),
      hasInsuranceCard: json['hasInsuranceCard'] as bool?,
      insurerName: json['insurerName'] as String? ?? '',
      insurerCardLabel: json['insurerCardLabel'] as String? ?? '',
      insurerManualReview: json['insurerManualReview'] as bool? ?? false,
      qidRenewalProofProvided: json['qidRenewalProofProvided'] as bool?,
      hadInsurerSwitch: json['hadInsurerSwitch'] as bool? ?? false,
      previousPolicyEndDate: _parseDate(json['previousPolicyEndDate']),
      newPolicyStartDate: _parseDate(json['newPolicyStartDate']),
      currentRenewalYear: json['currentRenewalYear'] as int?,
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

/// Single line item in a compliance results breakdown.
class ComplianceCheckItem {
  const ComplianceCheckItem({
    required this.id,
    required this.titleKey,
    required this.explanationKey,
    required this.actionKey,
    required this.status,
    this.ruleKey,
    this.metadata,
  });

  final String id;
  final String titleKey;
  final String explanationKey;
  final String actionKey;
  final HealthComplianceStatus status;
  final String? ruleKey;
  /// Optional lookup note (e.g. TPA → insurer mapping message).
  final String? metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleKey': titleKey,
        'explanationKey': explanationKey,
        'actionKey': actionKey,
        'status': status.name,
        'ruleKey': ruleKey,
        if (metadata != null) 'metadata': metadata,
      };

  factory ComplianceCheckItem.fromJson(Map<String, dynamic> json) {
    return ComplianceCheckItem(
      id: json['id'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      explanationKey: json['explanationKey'] as String? ?? '',
      actionKey: json['actionKey'] as String? ?? '',
      status: HealthComplianceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HealthComplianceStatus.informational,
      ),
      ruleKey: json['ruleKey'] as String?,
      metadata: json['metadata'] as String?,
    );
  }
}

class ComplianceCheckResult {
  const ComplianceCheckResult({
    required this.items,
    required this.checkedAt,
    this.hasUnresolvedViolation = false,
    this.isExemptSession = false,
    this.appliedExemption = HealthInsuranceExemptionCategory.none,
  });

  final List<ComplianceCheckItem> items;
  final DateTime checkedAt;
  final bool hasUnresolvedViolation;
  final bool isExemptSession;
  final HealthInsuranceExemptionCategory appliedExemption;

  bool get allCompliant => items.every(
        (i) =>
            i.status == HealthComplianceStatus.compliant ||
            i.status == HealthComplianceStatus.informational ||
            i.status == HealthComplianceStatus.notApplicable,
      );

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'checkedAt': checkedAt.toIso8601String(),
        'hasUnresolvedViolation': hasUnresolvedViolation,
        'isExemptSession': isExemptSession,
        'appliedExemption': appliedExemption.name,
      };

  factory ComplianceCheckResult.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return ComplianceCheckResult(
      items: raw
          .map((e) => ComplianceCheckItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkedAt: DateTime.tryParse(json['checkedAt'] as String? ?? '') ??
          DateTime.now(),
      hasUnresolvedViolation:
          json['hasUnresolvedViolation'] as bool? ?? false,
      isExemptSession: json['isExemptSession'] as bool? ?? false,
      appliedExemption: HealthInsuranceExemptionCategory.values.firstWhere(
        (e) => e.name == json['appliedExemption'],
        orElse: () => HealthInsuranceExemptionCategory.none,
      ),
    );
  }
}

/// Local Hive history for insurer-switch tracking across renewal years.
class InsurerSwitchRecord {
  const InsurerSwitchRecord({
    required this.renewalYear,
    required this.insurerName,
    required this.coverageStart,
    required this.coverageEnd,
  });

  final int renewalYear;
  final String insurerName;
  final DateTime coverageStart;
  final DateTime coverageEnd;

  Map<String, dynamic> toJson() => {
        'renewalYear': renewalYear,
        'insurerName': insurerName,
        'coverageStart': coverageStart.toIso8601String(),
        'coverageEnd': coverageEnd.toIso8601String(),
      };

  factory InsurerSwitchRecord.fromJson(Map<String, dynamic> json) {
    return InsurerSwitchRecord(
      renewalYear: json['renewalYear'] as int? ?? DateTime.now().year,
      insurerName: json['insurerName'] as String? ?? '',
      coverageStart: DateTime.parse(json['coverageStart'] as String),
      coverageEnd: DateTime.parse(json['coverageEnd'] as String),
    );
  }
}
