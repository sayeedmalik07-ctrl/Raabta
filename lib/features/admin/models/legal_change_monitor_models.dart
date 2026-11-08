/// Internal Legal Change Monitor review queue models (admin-only).
class LegalMonitorReviewItem {
  const LegalMonitorReviewItem({
    required this.id,
    required this.changeId,
    required this.sourceId,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.trackedFactId,
    required this.trackedFact,
    required this.engine,
    required this.triageStatus,
    required this.excerpt,
    required this.reasoning,
    required this.reviewDecision,
    this.reviewedAt,
    this.createdAt,
  });

  final String id;
  final String changeId;
  final String sourceId;
  final String sourceLabel;
  final String sourceUrl;
  final String trackedFactId;
  final String trackedFact;
  final String engine;
  final String triageStatus;
  final String excerpt;
  final String reasoning;
  final String reviewDecision;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  bool get isPending => reviewDecision == 'pending';

  factory LegalMonitorReviewItem.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return LegalMonitorReviewItem(
      id: id,
      changeId: json['changeId'] as String? ?? '',
      sourceId: json['sourceId'] as String? ?? '',
      sourceLabel: json['sourceLabel'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      trackedFactId: json['trackedFactId'] as String? ?? '',
      trackedFact: json['trackedFact'] as String? ?? '',
      engine: json['engine'] as String? ?? '',
      triageStatus: json['triageStatus'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      reasoning: json['reasoning'] as String? ?? '',
      reviewDecision: json['reviewDecision'] as String? ?? 'pending',
      reviewedAt: DateTime.tryParse(json['reviewedAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class LegalMonitorSourceStatus {
  const LegalMonitorSourceStatus({
    required this.id,
    required this.label,
    required this.url,
    this.lastCheckedAt,
    this.contentHash,
    this.lastChangeDetectedAt,
    this.lastFetchError,
  });

  final String id;
  final String label;
  final String url;
  final DateTime? lastCheckedAt;
  final String? contentHash;
  final DateTime? lastChangeDetectedAt;
  final String? lastFetchError;

  factory LegalMonitorSourceStatus.fromJson(Map<String, dynamic> json) {
    final state = json['state'] as Map<String, dynamic>?;
    return LegalMonitorSourceStatus(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      url: json['url'] as String? ?? '',
      lastCheckedAt:
          DateTime.tryParse(state?['lastCheckedAt']?.toString() ?? ''),
      contentHash: state?['contentHash'] as String?,
      lastChangeDetectedAt:
          DateTime.tryParse(state?['lastChangeDetectedAt']?.toString() ?? ''),
      lastFetchError: state?['lastFetchError'] as String?,
    );
  }
}

class LegalMonitorRunSummary {
  const LegalMonitorRunSummary({
    required this.ranAt,
    required this.sourcesChecked,
    required this.totalAiCalls,
  });

  final DateTime? ranAt;
  final int sourcesChecked;
  final int totalAiCalls;

  factory LegalMonitorRunSummary.fromJson(Map<String, dynamic> json) {
    return LegalMonitorRunSummary(
      ranAt: DateTime.tryParse(json['ranAt']?.toString() ?? ''),
      sourcesChecked: json['sourcesChecked'] as int? ?? 0,
      totalAiCalls: json['totalAiCalls'] as int? ?? 0,
    );
  }
}
