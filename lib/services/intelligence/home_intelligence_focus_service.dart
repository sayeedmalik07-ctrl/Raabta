import 'package:raabta/core/intelligence/capabilities.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/intelligence/attention_scorer.dart';
import 'package:raabta/services/intelligence/consistency_checker.dart';
import 'package:raabta/services/intelligence/intelligence_capability_mapper.dart';
import 'package:raabta/services/intelligence/opportunity_detector.dart';
import 'package:raabta/services/intelligence/risk_detector.dart';

/// One critical/high insight surfaced on the Home "Today's Focus" card.
class HomeIntelligenceFocusItem {
  const HomeIntelligenceFocusItem({
    required this.id,
    required this.title,
    required this.explanation,
    required this.priority,
    required this.insightType,
    required this.evidenceReference,
    required this.compositeScore,
    this.capability,
  });

  final String id;
  final String title;
  final Explanation explanation;
  final IntelligencePriority priority;
  final String insightType;
  final String evidenceReference;
  final double compositeScore;
  final Capability? capability;
}

/// Resolves top 1–3 critical/high insights for Home — reuses Phase 3/5/16/18 stack.
class HomeIntelligenceFocusService {
  const HomeIntelligenceFocusService({this.maxItems = 3});

  final int maxItems;

  List<HomeIntelligenceFocusItem> resolveTopItems({
    required String userId,
    List<DocumentVaultRecord> documents = const [],
    List<BillDueRecord> bills = const [],
    EosbEmployeeInput? eosbInput,
    List<EntitlementBreakdownItem>? eosbBreakdown,
    String? eosbCalculationId,
    List<EvidenceDeadlineRecord> evidenceEntries = const [],
    EosbSalarySnapshot? eosbSalary,
    CvStatedSalarySnapshot? cvSalary,
    EosbTimestampSnapshot? eosbTimestamp,
    ExpatScoreTimestampSnapshot? expatScoreTimestamp,
    EosbEmployerSnapshot? eosbEmployer,
    OvertimeEmployerSnapshot? overtimeEmployer,
    List<IntelligenceInsight>? recentInsightHistory,
    DateTime? now,
  }) {
    final riskDetector = RiskDetector(now: now);
    final opportunityDetector = OpportunityDetector(now: now);
    final scorer = AttentionScorer(
      now: now,
      typeSeverity: {
        ...RiskDetector.insightTypeSeverity,
        ...OpportunityDetector.insightTypeSeverity,
        ...ConsistencyChecker.insightTypeSeverity,
      },
    );
    final consistencyChecker = ConsistencyChecker(
      now: now,
      attentionScorer: scorer,
    );

    final scoredRisks = riskDetector.detectAndScore(
      userId: userId,
      documents: documents,
      bills: bills,
      eosbInput: eosbInput,
      eosbBreakdown: eosbBreakdown,
      eosbCalculationId: eosbCalculationId,
      evidenceEntries: evidenceEntries,
      recentInsightHistory: recentInsightHistory,
    );

    final eosbRisks = scoredRisks
        .map((s) => s.risk)
        .where((r) => r.type == Risk.typeEosbViolation)
        .toList();

    final scoredOpportunities = opportunityDetector.detectAndScore(
      userId: userId,
      eosbViolationRisks: eosbRisks,
      recentInsightHistory: recentInsightHistory,
    );

    final ranked = <_RankedFocusCandidate>[];

    for (final scored in scoredRisks) {
      if (!_isHomePriority(scored.priority)) continue;
      ranked.add(
        _RankedFocusCandidate(
          id: scored.risk.id,
          title: scored.insight.summary,
          explanation: scored.explanation,
          priority: scored.priority,
          insightType: scored.risk.type,
          evidenceReference: scored.risk.evidenceReference,
          compositeScore: scorer.compositeScore(
            scored.insight,
            recentHistory: recentInsightHistory,
          ),
        ),
      );
    }

    for (final scored in scoredOpportunities) {
      if (!_isHomePriority(scored.priority)) continue;
      ranked.add(
        _RankedFocusCandidate(
          id: scored.opportunity.id,
          title: scored.insight.summary,
          explanation: scored.explanation,
          priority: scored.priority,
          insightType: scored.opportunity.type,
          evidenceReference: scored.opportunity.evidenceReference,
          compositeScore: scorer.compositeScore(
            scored.insight,
            recentHistory: recentInsightHistory,
          ),
        ),
      );
    }

    final scoredConsistency = consistencyChecker.detectAndScore(
      userId: userId,
      eosbSalary: eosbSalary,
      cvSalary: cvSalary,
      eosbTimestamp: eosbTimestamp,
      expatScoreTimestamp: expatScoreTimestamp,
      eosbEmployer: eosbEmployer,
      overtimeEmployer: overtimeEmployer,
      recentInsightHistory: recentInsightHistory,
    );

    for (final scored in scoredConsistency) {
      if (!_isHomePriority(scored.priority)) continue;
      ranked.add(
        _RankedFocusCandidate(
          id: scored.insight.id,
          title: scored.insight.summary,
          explanation: scored.explanation,
          priority: scored.priority,
          insightType: scored.insight.type,
          evidenceReference: scored.detail.checkId,
          compositeScore: scorer.compositeScore(
            scored.insight,
            recentHistory: recentInsightHistory,
          ),
        ),
      );
    }

    ranked.sort((a, b) {
      final byPriority =
          _priorityRank(a.priority).compareTo(_priorityRank(b.priority));
      if (byPriority != 0) return byPriority;
      return b.compositeScore.compareTo(a.compositeScore);
    });

    final seenEvidence = <String>{};
    final selected = <HomeIntelligenceFocusItem>[];

    for (final candidate in ranked) {
      if (seenEvidence.contains(candidate.evidenceReference)) continue;
      seenEvidence.add(candidate.evidenceReference);

      selected.add(
        HomeIntelligenceFocusItem(
          id: candidate.id,
          title: candidate.title,
          explanation: candidate.explanation,
          priority: candidate.priority,
          insightType: candidate.insightType,
          evidenceReference: candidate.evidenceReference,
          compositeScore: candidate.compositeScore,
          capability: IntelligenceCapabilityMapper.capabilityForInsightType(
            candidate.insightType,
          ),
        ),
      );

      if (selected.length >= maxItems) break;
    }

    return selected;
  }

  static bool _isHomePriority(IntelligencePriority priority) {
    return priority == IntelligencePriority.critical ||
        priority == IntelligencePriority.high;
  }

  static int _priorityRank(IntelligencePriority priority) {
    switch (priority) {
      case IntelligencePriority.critical:
        return 0;
      case IntelligencePriority.high:
        return 1;
      case IntelligencePriority.medium:
        return 2;
      case IntelligencePriority.low:
        return 3;
      case IntelligencePriority.digest:
        return 4;
    }
  }
}

class _RankedFocusCandidate {
  const _RankedFocusCandidate({
    required this.id,
    required this.title,
    required this.explanation,
    required this.priority,
    required this.insightType,
    required this.evidenceReference,
    required this.compositeScore,
  });

  final String id;
  final String title;
  final Explanation explanation;
  final IntelligencePriority priority;
  final String insightType;
  final String evidenceReference;
  final double compositeScore;
}
