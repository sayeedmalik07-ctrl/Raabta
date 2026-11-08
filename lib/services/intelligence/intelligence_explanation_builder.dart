import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/models/intelligence/opportunity.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/intelligence/opportunity_insight_adapter.dart';
import 'package:raabta/services/intelligence/risk_insight_adapter.dart';

/// Template-based explanations for Phase 5/16 deterministic rules — no AI calls.
abstract final class IntelligenceExplanationBuilder {
  static Explanation forRisk(Risk risk) {
    final insight = RiskInsightAdapter.toInsight(risk);

    return Explanation(
      why: _whyForRisk(risk),
      source: insight.source,
      confidence: insight.confidence,
      lastUpdated: risk.createdAt,
    );
  }

  static Explanation forOpportunity(Opportunity opportunity) {
    final insight = OpportunityInsightAdapter.toInsight(opportunity);

    return Explanation(
      why: _whyForOpportunity(opportunity),
      source: insight.source,
      confidence: insight.confidence,
      lastUpdated: opportunity.createdAt,
    );
  }

  static Explanation forInsight(IntelligenceInsight insight) {
    return Explanation(
      why: insight.summary,
      source: insight.source,
      confidence: insight.confidence,
      lastUpdated: insight.createdAt,
    );
  }

  /// Phase 27 — cross-feature mismatch; user must pick which source is current.
  static Explanation forDataMismatch({
    required String labelA,
    required String labelB,
    required String valueA,
    required String valueB,
    required IntelligenceSource source,
    required DateTime detectedAt,
    double confidence = 0.88,
  }) {
    return Explanation(
      why: '$labelA shows "$valueA" but $labelB shows "$valueB". '
          'Raabta will not change either value automatically — open the tool '
          'you trust and update the other when you are ready.',
      source: source,
      confidence: confidence,
      lastUpdated: detectedAt,
    );
  }

  static String _whyForRisk(Risk risk) {
    switch (risk.type) {
      case Risk.typeDocumentExpiry:
        return 'Raabta checked your Document Vault and found a document '
            'expiring within the renewal window (${risk.recommendedAction}). '
            'Evidence: ${risk.evidenceCollection}/${risk.evidenceReference}.';
      case Risk.typeBillDue:
        return 'Raabta checked Bill Tracker for unpaid bills due soon '
            '(${risk.recommendedAction}). '
            'Evidence: ${risk.evidenceCollection}/${risk.evidenceReference}.';
      case Risk.typeEosbViolation:
        return 'Your EOSB calculation triggered a Qatar labour-law check '
            '(${risk.recommendedAction}). '
            'Evidence: ${risk.evidenceCollection}/${risk.evidenceReference}.';
      case Risk.typeLabourComplaintDeadline:
        return 'Raabta compared your evidence trail incident date against a '
            'placeholder ADLSA filing window (${risk.recommendedAction}). '
            '// TODO-VERIFY: filing day-count against primary ADLSA sources. '
            'Evidence: ${risk.evidenceCollection}/${risk.evidenceReference}.';
      case Risk.typeVehicleExpiry:
        return 'Vehicle registration expiry is not tracked separately; '
            'driving licences in Document Vault are covered by document expiry rules.';
      default:
        return risk.recommendedAction;
    }
  }

  static String _whyForOpportunity(Opportunity opportunity) {
    switch (opportunity.type) {
      case Opportunity.typeEntitlementGap:
        return 'Your EOSB entitlement review suggests you may be able to '
            'act on a labour-law gap (${opportunity.actionableInsight}). '
            'This reframes an EOSB violation flagged in Phase 5 — same evidence, '
            'opportunity framing. '
            'Evidence: ${opportunity.evidenceCollection}/${opportunity.evidenceReference}.';
      case Opportunity.typeExchangeRate:
        return 'Raabta compared the current corridor rate to your typical '
            'remittance timing (${opportunity.actionableInsight}). '
            'Evidence: ${opportunity.evidenceCollection}/${opportunity.evidenceReference}.';
      default:
        return opportunity.actionableInsight;
    }
  }
}
