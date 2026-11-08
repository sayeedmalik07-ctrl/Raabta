import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/models/intelligence/risk.dart';

/// Converts [Risk] → [IntelligenceInsight] for [AttentionScorer].
///
/// Adapter choice (Phase 5): keep scoring types separate — [Risk] holds evidence
/// and rule output; [IntelligenceInsight] is the cross-feature attention primitive.
/// Mapping lives here rather than on [Risk] so labour-law detectors stay decoupled.
abstract final class RiskInsightAdapter {
  static IntelligenceInsight toInsight(
    Risk risk, {
    DateTime? expiresAt,
    double? confidenceOverride,
  }) {
    return IntelligenceInsight(
      id: risk.id,
      userId: risk.userId,
      type: risk.type,
      summary: risk.recommendedAction,
      confidence: confidenceOverride ?? _confidenceFromSeverity(risk.severity),
      source: IntelligenceSource(
        type: _sourceTypeForCollection(risk.evidenceCollection),
        reference: '${risk.evidenceCollection}/${risk.evidenceReference}',
        verificationStatus: 'verified',
      ),
      createdAt: risk.createdAt,
      expiresAt: expiresAt,
    );
  }

  static double _confidenceFromSeverity(String severity) {
    switch (severity) {
      case Risk.severityCritical:
        return 0.95;
      case Risk.severityHigh:
        return 0.85;
      case Risk.severityMedium:
        return 0.65;
      case Risk.severityLow:
        return 0.45;
      default:
        return 0.5;
    }
  }

  static String _sourceTypeForCollection(String collection) {
    if (collection == 'scanned_documents') return 'document';
    if (collection == 'bill_tracker') return 'user';
    if (collection.startsWith('eosb')) return 'official';
    return 'user';
  }
}

/// Risk paired with its attention priority after scoring.
class ScoredRisk {
  const ScoredRisk({
    required this.risk,
    required this.insight,
    required this.priority,
    required this.explanation,
  });

  final Risk risk;
  final IntelligenceInsight insight;
  final IntelligencePriority priority;
  final Explanation explanation;
}
