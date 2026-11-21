import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/intelligence/daily_digest_builder.dart';
import 'package:raabta/services/intelligence/opportunity_detector.dart';
import 'package:raabta/services/intelligence/risk_detector.dart';
import 'package:raabta/services/notifications/notification_engine.dart';
import 'package:raabta/services/raabta_notification_service.dart';

export 'package:raabta/services/notifications/notification_engine.dart'
    show SmartSendResult;

/// Scheduled job id — wired from Node [dailyRiskOpportunityReview.js] daily cron.
abstract final class DailyRiskOpportunityReviewJob {
  static const id = 'daily_risk_opportunity_review';
  static const batchDedupReference = 'daily_risk_opportunity_review';
}

/// One user's scored intelligence review — max one notification batch per day.
class IntelligenceReviewBatch {
  const IntelligenceReviewBatch({
    required this.userId,
    required this.insights,
    required this.topPriority,
  });

  final String userId;
  final List<IntelligenceInsight> insights;
  final IntelligencePriority topPriority;

  bool get isEmpty => insights.isEmpty;

  String get title => 'Your Raabta intelligence update';

  String get body {
    if (insights.isEmpty) return '';
    if (insights.length == 1) return insights.first.summary;
    final preview = insights.take(2).map((i) => i.summary).join(' · ');
    final extra = insights.length - 2;
    if (extra > 0) {
      return '$preview · +$extra more';
    }
    return preview;
  }
}

/// Re-runs Phase 5/16 detectors, scores via Phase 3, delivers one batch/day.
class DailyRiskOpportunityReviewService {
  const DailyRiskOpportunityReviewService({
    this.digestBuilder = const DailyDigestBuilder(),
  });

  final DailyDigestBuilder digestBuilder;

  IntelligenceReviewBatch review({
    required String userId,
    List<DocumentVaultRecord> documents = const [],
    List<BillDueRecord> bills = const [],
    EosbEmployeeInput? eosbInput,
    List<EntitlementBreakdownItem>? eosbBreakdown,
    String? eosbCalculationId,
    List<EvidenceDeadlineRecord> evidenceEntries = const [],
    List<IntelligenceInsight>? recentInsightHistory,
    DateTime? now,
  }) {
    final riskDetector = RiskDetector(now: now);
    final opportunityDetector = OpportunityDetector(now: now);

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

    final allInsights = [
      ...scoredRisks.map((s) => s.insight),
      ...scoredOpportunities.map((s) => s.insight),
    ];

    if (allInsights.isEmpty) {
      return IntelligenceReviewBatch(
        userId: userId,
        insights: const [],
        topPriority: IntelligencePriority.digest,
      );
    }

    final grouped = digestBuilder.build(
      allInsights,
      recentHistory: recentInsightHistory,
      now: now,
    );

    final deliverable = <IntelligenceInsight>[
      ...grouped[IntelligencePriority.critical]!,
      ...grouped[IntelligencePriority.high]!,
      ...grouped[IntelligencePriority.medium]!,
      ...grouped[IntelligencePriority.low]!,
    ];

    if (deliverable.isEmpty) {
      return IntelligenceReviewBatch(
        userId: userId,
        insights: const [],
        topPriority: IntelligencePriority.digest,
      );
    }

    deliverable.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return IntelligenceReviewBatch(
      userId: userId,
      insights: deliverable,
      topPriority: _highestPriority(grouped),
    );
  }

  /// Delivers via [RaabtaNotificationService.sendSmartNotification] — not a parallel path.
  Future<SmartSendResult> deliverBatch(IntelligenceReviewBatch batch) async {
    if (batch.isEmpty) {
      return SmartSendResult(skipped: true, reason: 'empty_batch');
    }

    return RaabtaNotificationService.instance.sendSmartNotification(
      SmartNotificationRequest(
        type: NotificationType.intelligenceDailyReview,
        title: batch.title,
        body: batch.body,
        route: '/home',
        dedupKey: DailyRiskOpportunityReviewJob.batchDedupReference,
        data: {
          'jobId': DailyRiskOpportunityReviewJob.id,
          'insightCount': batch.insights.length,
          'topPriority': batch.topPriority.name,
        },
      ),
    );
  }

  static IntelligencePriority _highestPriority(
    Map<IntelligencePriority, List<IntelligenceInsight>> grouped,
  ) {
    for (final priority in IntelligencePriority.values) {
      if (priority == IntelligencePriority.digest) continue;
      if (grouped[priority]!.isNotEmpty) return priority;
    }
    return IntelligencePriority.digest;
  }
}
