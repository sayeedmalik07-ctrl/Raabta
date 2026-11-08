import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/opportunity.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/intelligence/attention_scorer.dart';
import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/services/intelligence/intelligence_explanation_builder.dart';
import 'package:raabta/services/intelligence/opportunity_insight_adapter.dart';
import 'package:raabta/services/intelligence/risk_detector.dart';

/// Hand-written, evidence-based opportunity rules over existing Raabta data.
///
/// No Firestore persistence — in-memory only, same as Phase 5 [RiskDetector].
class OpportunityDetector {
  OpportunityDetector({
    DateTime? now,
    AttentionScorer? attentionScorer,
  })  : _now = now,
        _attentionScorer = attentionScorer ??
            AttentionScorer(
              now: now,
              typeSeverity: insightTypeSeverity,
            );

  final DateTime? _now;
  final AttentionScorer _attentionScorer;

  static const exchangeRatesCollection = 'exchange_rates';
  static const eosbCalculationsCollection = RiskDetector.eosbCalculationsCollection;

  /// Opportunity weights fed into Phase 3 [AttentionScorer].
  static const insightTypeSeverity = <String, double>{
    Opportunity.typeExchangeRate: 0.55,
    Opportunity.typeEntitlementGap: 0.80,
  };

  DateTime get _clock => _now ?? DateTime.now();

  /// Skipped: Raabta does not track per-user remittance send timing.
  ///
  /// [ExchangeRateService.fetchHistory] exposes global 7-day corridor trends
  /// (`RateHistoryPoint` via `rateHistoryProvider`), and Personal Budget stores
  /// a monthly remittance *amount* only — no send-date history to compare
  /// against the user's typical remittance window.
  List<Opportunity> checkFavorableExchangeRate({
    required String userId,
    String? preferredCurrencyCode,
    List<RateHistorySnapshot>? rateHistory,
    RemittanceTimingPattern? remittanceTiming,
  }) {
    if (remittanceTiming == null || !remittanceTiming.hasUsablePattern) {
      return const [];
    }

    // Reserved for when per-user remittance timing exists; not implemented.
    return const [];
  }

  /// Reframes Phase 5 EOSB violation [Risk]s as actionable opportunities.
  ///
  /// Pass the output of [RiskDetector.checkEOSBViolation] — this method does
  /// **not** call [ViolationDetector.detect] again.
  List<Opportunity> checkEntitlementGap({
    required String userId,
    required List<Risk> eosbViolationRisks,
  }) {
    return eosbViolationRisks
        .where((risk) => risk.type == Risk.typeEosbViolation)
        .map(
          (risk) => Opportunity(
            id: _opportunityId(Opportunity.typeEntitlementGap, risk.id),
            userId: userId,
            type: Opportunity.typeEntitlementGap,
            evidenceReference: risk.evidenceReference,
            evidenceCollection: risk.evidenceCollection,
            actionableInsight: _reframeEosbRiskAsOpportunity(risk),
            createdAt: _clock,
          ),
        )
        .toList();
  }

  /// Runs active rules and scores each [Opportunity] through [AttentionScorer].
  List<ScoredOpportunity> detectAndScore({
    required String userId,
    RemittanceTimingPattern? remittanceTiming,
    String? preferredCurrencyCode,
    List<RateHistorySnapshot>? rateHistory,
    List<Risk> eosbViolationRisks = const [],
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    final opportunities = <Opportunity>[
      ...checkFavorableExchangeRate(
        userId: userId,
        preferredCurrencyCode: preferredCurrencyCode,
        rateHistory: rateHistory,
        remittanceTiming: remittanceTiming,
      ),
      ...checkEntitlementGap(
        userId: userId,
        eosbViolationRisks: eosbViolationRisks,
      ),
    ];

    return scoreOpportunities(
      opportunities,
      recentInsightHistory: recentInsightHistory,
    );
  }

  List<ScoredOpportunity> scoreOpportunities(
    List<Opportunity> opportunities, {
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    return opportunities.map((opportunity) {
      final insight = OpportunityInsightAdapter.toInsight(opportunity);
      final priority = _attentionScorer.score(
        insight,
        recentHistory: recentInsightHistory,
      );
      return ScoredOpportunity(
        opportunity: opportunity,
        insight: insight,
        priority: priority,
        explanation: explain(opportunity),
      );
    }).toList();
  }

  /// Template-based "why am I seeing this" for an [Opportunity] — no AI call.
  static Explanation explain(Opportunity opportunity) =>
      IntelligenceExplanationBuilder.forOpportunity(opportunity);

  static String _opportunityId(String type, String sourceId) =>
      '${type}_$sourceId';

  static String _reframeEosbRiskAsOpportunity(Risk risk) {
    final action = risk.recommendedAction;
    if (action.startsWith('Review EOSB labour-law flag')) {
      return action.replaceFirst(
        'Review EOSB labour-law flag',
        'You may be entitled to more — review this EOSB labour-law flag',
      );
    }
    return 'Actionable EOSB opportunity: $action';
  }
}

/// Placeholder for future per-user remittance timing — not populated today.
class RemittanceTimingPattern {
  const RemittanceTimingPattern({
    this.typicalDayOfMonth,
    this.typicalWeekday,
    this.lastSendDates = const [],
  });

  final int? typicalDayOfMonth;
  final int? typicalWeekday;
  final List<DateTime> lastSendDates;

  bool get hasUsablePattern =>
      typicalDayOfMonth != null ||
      typicalWeekday != null ||
      lastSendDates.length >= 2;
}

/// In-memory 7-day rate snapshot (from [ExchangeRateService.fetchHistory]).
class RateHistorySnapshot {
  const RateHistorySnapshot({
    required this.currencyCode,
    required this.points,
  });

  final String currencyCode;
  final List<RateHistoryPointSnapshot> points;
}

class RateHistoryPointSnapshot {
  const RateHistoryPointSnapshot({
    required this.date,
    this.rate,
  });

  final String date;
  final double? rate;
}
