import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/domain/models/insurer_regulatory_body.dart';

enum ClaimDenialReasonCategory {
  medicalNecessity,
  policyExclusion,
  preAuthNotObtained,
  documentationIncomplete,
  coverageLapsed,
  other,
}

extension ClaimDenialReasonCategoryX on ClaimDenialReasonCategory {
  String get storageValue => name;

  static ClaimDenialReasonCategory fromStorage(String? raw) {
    return ClaimDenialReasonCategory.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => ClaimDenialReasonCategory.other,
    );
  }

  String get labelKey => 'hi_denial_reason_$name';
}

/// Persisted claim denial dispute — Firestore + local cache.
class HealthInsuranceClaimDispute {
  const HealthInsuranceClaimDispute({
    required this.disputeId,
    required this.userId,
    required this.insurerName,
    required this.regulatoryBody,
    required this.denialReason,
    required this.hasWrittenDenialLetter,
    required this.employerProvidedCoverage,
    required this.createdAt,
    required this.updatedAt,
    this.insurerMatchType,
    this.denialReasonOtherText,
    this.denialDate,
    this.claimAmount,
    this.policyNumber,
    this.completedSteps = const {},
    this.documentRefs = const {},
    this.draftLetter,
  });

  final String disputeId;
  final String userId;
  final String insurerName;
  final InsurerLookupMatchType? insurerMatchType;
  final InsurerRegulatoryBody regulatoryBody;
  final ClaimDenialReasonCategory denialReason;
  final String? denialReasonOtherText;
  final DateTime? denialDate;
  final bool hasWrittenDenialLetter;
  final bool employerProvidedCoverage;
  final String? claimAmount;
  final String? policyNumber;
  final Map<String, String> completedSteps;
  final Map<String, String> documentRefs;
  final String? draftLetter;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isStepComplete(String stepId) => completedSteps.containsKey(stepId);

  int get completedStepCount => completedSteps.length;

  HealthInsuranceClaimDispute copyWith({
    String? disputeId,
    String? userId,
    String? insurerName,
    InsurerLookupMatchType? insurerMatchType,
    InsurerRegulatoryBody? regulatoryBody,
    ClaimDenialReasonCategory? denialReason,
    String? denialReasonOtherText,
    DateTime? denialDate,
    bool? hasWrittenDenialLetter,
    bool? employerProvidedCoverage,
    String? claimAmount,
    String? policyNumber,
    Map<String, String>? completedSteps,
    Map<String, String>? documentRefs,
    String? draftLetter,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDenialDate = false,
    bool clearDraftLetter = false,
  }) {
    return HealthInsuranceClaimDispute(
      disputeId: disputeId ?? this.disputeId,
      userId: userId ?? this.userId,
      insurerName: insurerName ?? this.insurerName,
      insurerMatchType: insurerMatchType ?? this.insurerMatchType,
      regulatoryBody: regulatoryBody ?? this.regulatoryBody,
      denialReason: denialReason ?? this.denialReason,
      denialReasonOtherText: denialReasonOtherText ?? this.denialReasonOtherText,
      denialDate: clearDenialDate ? null : (denialDate ?? this.denialDate),
      hasWrittenDenialLetter:
          hasWrittenDenialLetter ?? this.hasWrittenDenialLetter,
      employerProvidedCoverage:
          employerProvidedCoverage ?? this.employerProvidedCoverage,
      claimAmount: claimAmount ?? this.claimAmount,
      policyNumber: policyNumber ?? this.policyNumber,
      completedSteps: completedSteps ?? this.completedSteps,
      documentRefs: documentRefs ?? this.documentRefs,
      draftLetter: clearDraftLetter ? null : (draftLetter ?? this.draftLetter),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'disputeId': disputeId,
        'userId': userId,
        'insurerName': insurerName,
        if (insurerMatchType != null) 'insurerMatchType': insurerMatchType!.name,
        'regulatoryBody': regulatoryBody.storageValue,
        'denialReason': denialReason.storageValue,
        if (denialReasonOtherText != null)
          'denialReasonOtherText': denialReasonOtherText,
        if (denialDate != null) 'denialDate': denialDate!.toIso8601String(),
        'hasWrittenDenialLetter': hasWrittenDenialLetter,
        'employerProvidedCoverage': employerProvidedCoverage,
        if (claimAmount != null) 'claimAmount': claimAmount,
        if (policyNumber != null) 'policyNumber': policyNumber,
        'completedSteps': completedSteps,
        'documentRefs': documentRefs,
        if (draftLetter != null) 'draftLetter': draftLetter,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory HealthInsuranceClaimDispute.fromJson(Map<String, dynamic> json) {
    final matchRaw = json['insurerMatchType'] as String?;
    InsurerLookupMatchType? matchType;
    if (matchRaw != null) {
      for (final value in InsurerLookupMatchType.values) {
        if (value.name == matchRaw) {
          matchType = value;
          break;
        }
      }
    }

    return HealthInsuranceClaimDispute(
      disputeId: json['disputeId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      insurerName: json['insurerName'] as String? ?? '',
      insurerMatchType: matchType,
      regulatoryBody: InsurerRegulatoryBodyX.fromStorage(
        json['regulatoryBody'] as String?,
      ),
      denialReason: ClaimDenialReasonCategoryX.fromStorage(
        json['denialReason'] as String?,
      ),
      denialReasonOtherText: json['denialReasonOtherText'] as String?,
      denialDate: DateTime.tryParse(json['denialDate'] as String? ?? ''),
      hasWrittenDenialLetter: json['hasWrittenDenialLetter'] == true,
      employerProvidedCoverage: json['employerProvidedCoverage'] == true,
      claimAmount: json['claimAmount'] as String?,
      policyNumber: json['policyNumber'] as String?,
      completedSteps: (json['completedSteps'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      documentRefs: (json['documentRefs'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      draftLetter: json['draftLetter'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
