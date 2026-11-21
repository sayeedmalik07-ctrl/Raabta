import 'intelligence_source.dart';

const _unset = Object();

/// A single scored intelligence signal for a user — shared primitive for later phases.
class IntelligenceInsight {
  const IntelligenceInsight({
    required this.id,
    required this.userId,
    required this.type,
    required this.summary,
    required this.confidence,
    required this.source,
    required this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String userId;

  /// e.g. `document_expiry`, `data_mismatch`, `exchange_rate_opportunity`
  final String type;
  final String summary;

  /// 0.0–1.0
  final double confidence;
  final IntelligenceSource source;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'summary': summary,
        'confidence': confidence,
        'source': source.toJson(),
        'createdAt': createdAt.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      };

  factory IntelligenceInsight.fromJson(Map<String, dynamic> json) {
    return IntelligenceInsight(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      source: IntelligenceSource.fromJson(
        Map<String, dynamic>.from(json['source'] as Map? ?? {}),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  IntelligenceInsight copyWith({
    String? id,
    String? userId,
    String? type,
    String? summary,
    double? confidence,
    IntelligenceSource? source,
    DateTime? createdAt,
    Object? expiresAt = _unset,
  }) {
    return IntelligenceInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      summary: summary ?? this.summary,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: identical(expiresAt, _unset)
          ? this.expiresAt
          : expiresAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntelligenceInsight &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          type == other.type &&
          summary == other.summary &&
          confidence == other.confidence &&
          source == other.source &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        type,
        summary,
        confidence,
        source,
        createdAt,
        expiresAt,
      );
}
