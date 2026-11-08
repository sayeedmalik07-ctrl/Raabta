/// Structured output from AI contract / settlement document analysis.
class EosbContractAnalysis {
  const EosbContractAnalysis({
    this.joiningDate,
    this.basicSalary,
    this.totalSalary,
    this.housingAllowance,
    this.transportAllowance,
    this.foodAllowance,
    this.noticePeriodDays,
    this.leavePolicyDays,
    this.contractType,
    this.eosbClauseSummary,
    this.ticketPolicy,
    this.bonusPolicy,
    this.illegalClauses = const [],
    this.missingBenefits = const [],
    this.warnings = const [],
    this.confidence = 0.0,
    this.rawSummary,
  });

  final DateTime? joiningDate;
  final double? basicSalary;
  final double? totalSalary;
  final double? housingAllowance;
  final double? transportAllowance;
  final double? foodAllowance;
  final int? noticePeriodDays;
  final int? leavePolicyDays;
  final String? contractType;
  final String? eosbClauseSummary;
  final String? ticketPolicy;
  final String? bonusPolicy;
  final List<String> illegalClauses;
  final List<String> missingBenefits;
  final List<String> warnings;
  final double confidence;
  final String? rawSummary;

  factory EosbContractAnalysis.fromJson(Map<String, dynamic> json) {
    DateTime? joining;
    final jd = json['joiningDate'] as String?;
    if (jd != null && jd.isNotEmpty) {
      joining = DateTime.tryParse(jd);
    }

    return EosbContractAnalysis(
      joiningDate: joining,
      basicSalary: (json['basicSalary'] as num?)?.toDouble(),
      totalSalary: (json['totalSalary'] as num?)?.toDouble(),
      housingAllowance: (json['housingAllowance'] as num?)?.toDouble(),
      transportAllowance: (json['transportAllowance'] as num?)?.toDouble(),
      foodAllowance: (json['foodAllowance'] as num?)?.toDouble(),
      noticePeriodDays: (json['noticePeriodDays'] as num?)?.toInt(),
      leavePolicyDays: (json['leavePolicyDays'] as num?)?.toInt(),
      contractType: json['contractType'] as String?,
      eosbClauseSummary: json['eosbClauseSummary'] as String?,
      ticketPolicy: json['ticketPolicy'] as String?,
      bonusPolicy: json['bonusPolicy'] as String?,
      illegalClauses: (json['illegalClauses'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      missingBenefits: (json['missingBenefits'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      warnings: (json['warnings'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      rawSummary: json['summary'] as String?,
    );
  }
}

/// Structured AI legal review for settlement disputes.
class EosbLegalReview {
  const EosbLegalReview({
    this.missingBenefits = const [],
    this.possibleUnderpayments = const [],
    this.labourLawIssues = const [],
    this.contractRisks = const [],
    this.illegalClauses = const [],
    this.nextSteps = const [],
    this.negotiationAdvice = const [],
    this.requiredDocuments = const [],
    this.deadlines = const [],
    this.summary,
  });

  final List<String> missingBenefits;
  final List<String> possibleUnderpayments;
  final List<String> labourLawIssues;
  final List<String> contractRisks;
  final List<String> illegalClauses;
  final List<String> nextSteps;
  final List<String> negotiationAdvice;
  final List<String> requiredDocuments;
  final List<String> deadlines;
  final String? summary;

  factory EosbLegalReview.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) =>
        (json[key] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    return EosbLegalReview(
      missingBenefits: list('missingBenefits'),
      possibleUnderpayments: list('possibleUnderpayments'),
      labourLawIssues: list('labourLawIssues'),
      contractRisks: list('contractRisks'),
      illegalClauses: list('illegalClauses'),
      nextSteps: list('nextSteps'),
      negotiationAdvice: list('negotiationAdvice'),
      requiredDocuments: list('requiredDocuments'),
      deadlines: list('deadlines'),
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'missingBenefits': missingBenefits,
        'possibleUnderpayments': possibleUnderpayments,
        'labourLawIssues': labourLawIssues,
        'contractRisks': contractRisks,
        'illegalClauses': illegalClauses,
        'nextSteps': nextSteps,
        'negotiationAdvice': negotiationAdvice,
        'requiredDocuments': requiredDocuments,
        'deadlines': deadlines,
        'summary': summary,
      };
}
