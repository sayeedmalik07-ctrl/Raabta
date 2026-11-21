class DocumentIntelligenceResult {
  const DocumentIntelligenceResult({
    required this.documentType,
    required this.summary,
    this.names = const [],
    this.dates = const [],
    this.amounts = const [],
    this.expiryDate,
    this.actionItems = const [],
    this.importantClauses = const [],
    this.confidence = 0,
  });

  final String documentType;
  final String summary;
  final List<String> names;
  final List<String> dates;
  final List<String> amounts;
  final String? expiryDate;
  final List<String> actionItems;
  final List<String> importantClauses;
  final double confidence;

  factory DocumentIntelligenceResult.fromJson(Map<String, dynamic> json) {
    List<String> list(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];

    return DocumentIntelligenceResult(
      documentType: json['documentType'] as String? ?? 'unknown',
      summary: json['summary'] as String? ?? '',
      names: list(json['names']),
      dates: list(json['dates']),
      amounts: list(json['amounts']),
      expiryDate: json['expiryDate'] as String?,
      actionItems: list(json['actionItems']),
      importantClauses: list(json['importantClauses']),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'summary': summary,
        'names': names,
        'dates': dates,
        'amounts': amounts,
        'expiryDate': expiryDate,
        'actionItems': actionItems,
        'importantClauses': importantClauses,
        'confidence': confidence,
      };
}
