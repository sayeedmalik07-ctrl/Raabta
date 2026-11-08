import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/models/intelligence/opportunity.dart';

/// Converts [Opportunity] → [IntelligenceInsight] for [AttentionScorer].
abstract final class OpportunityInsightAdapter {
  static IntelligenceInsight toInsight(
    Opportunity opportunity, {
    DateTime? expiresAt,
    double confidence = 0.75,
  }) {
    return IntelligenceInsight(
      id: opportunity.id,
      userId: opportunity.userId,
      type: opportunity.type,
      summary: opportunity.actionableInsight,
      confidence: confidence,
      source: IntelligenceSource(
        type: _sourceTypeForCollection(opportunity.evidenceCollection),
        reference:
            '${opportunity.evidenceCollection}/${opportunity.evidenceReference}',
        verificationStatus: 'verified',
      ),
      createdAt: opportunity.createdAt,
      expiresAt: expiresAt,
    );
  }

  static String _sourceTypeForCollection(String collection) {
    if (collection.startsWith('users/eosb')) return 'official';
    if (collection == 'exchange_rates') return 'official';
    return 'user';
  }
}

/// Opportunity paired with its attention priority after scoring.
class ScoredOpportunity {
  const ScoredOpportunity({
    required this.opportunity,
    required this.insight,
    required this.priority,
    required this.explanation,
  });

  final Opportunity opportunity;
  final IntelligenceInsight insight;
  final IntelligencePriority priority;
  final Explanation explanation;
}
