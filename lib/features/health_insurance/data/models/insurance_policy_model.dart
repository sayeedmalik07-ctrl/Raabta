/// Reference to a user-uploaded health insurance policy in Document Vault.
class InsurancePolicyDocument {
  const InsurancePolicyDocument({
    required this.documentId,
    required this.displayName,
    required this.ocrText,
    this.aiSummary = '',
    this.uploadedAt,
  });

  final String documentId;
  final String displayName;
  final String ocrText;
  final String aiSummary;
  final DateTime? uploadedAt;

  bool get hasExtractableText => ocrText.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'displayName': displayName,
        'ocrText': ocrText,
        'aiSummary': aiSummary,
        'uploadedAt': uploadedAt?.toIso8601String(),
      };

  factory InsurancePolicyDocument.fromJson(Map<String, dynamic> json) {
    return InsurancePolicyDocument(
      documentId: json['documentId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      ocrText: json['ocrText'] as String? ?? '',
      aiSummary: json['aiSummary'] as String? ?? '',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'] as String)
          : null,
    );
  }
}

/// Plain-language policy summary — extracted content only, never invented limits.
class PolicyExplainerResult {
  const PolicyExplainerResult({
    required this.summary,
    required this.coverageCategories,
    required this.exclusions,
    required this.networkNotes,
    required this.ambiguityNotes,
    required this.disclaimerKey,
    this.sourceDocumentId = '',
  });

  final String summary;
  final List<String> coverageCategories;
  final List<String> exclusions;
  final List<String> networkNotes;
  final List<String> ambiguityNotes;
  final String disclaimerKey;
  final String sourceDocumentId;

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'coverageCategories': coverageCategories,
        'exclusions': exclusions,
        'networkNotes': networkNotes,
        'ambiguityNotes': ambiguityNotes,
        'disclaimerKey': disclaimerKey,
        'sourceDocumentId': sourceDocumentId,
      };

  factory PolicyExplainerResult.fromJson(Map<String, dynamic> json) {
    List<String> listField(String key) =>
        (json[key] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    return PolicyExplainerResult(
      summary: json['summary'] as String? ?? '',
      coverageCategories: listField('coverageCategories'),
      exclusions: listField('exclusions'),
      networkNotes: listField('networkNotes'),
      ambiguityNotes: listField('ambiguityNotes'),
      disclaimerKey:
          json['disclaimerKey'] as String? ?? 'hi_policy_explainer_disclaimer',
      sourceDocumentId: json['sourceDocumentId'] as String? ?? '',
    );
  }
}
