import 'package:raabta/models/intelligence/intelligence_source.dart';

/// Plain-language "why am I seeing this" for a deterministic intelligence signal.
class Explanation {
  const Explanation({
    required this.why,
    required this.source,
    required this.confidence,
    required this.lastUpdated,
  });

  /// Short plain-language explanation of the signal.
  final String why;

  final IntelligenceSource source;

  /// 0.0–1.0
  final double confidence;

  final DateTime lastUpdated;

  Map<String, dynamic> toJson() => {
        'why': why,
        'source': source.toJson(),
        'confidence': confidence,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Explanation.fromJson(Map<String, dynamic> json) {
    return Explanation(
      why: json['why'] as String? ?? '',
      source: IntelligenceSource.fromJson(
        Map<String, dynamic>.from(json['source'] as Map? ?? {}),
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Explanation &&
          runtimeType == other.runtimeType &&
          why == other.why &&
          source == other.source &&
          confidence == other.confidence &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      Object.hash(why, source, confidence, lastUpdated);
}
