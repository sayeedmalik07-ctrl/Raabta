import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/violation_detector.dart';
import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/intelligence/attention_scorer.dart';
import 'package:raabta/services/intelligence/intelligence_explanation_builder.dart';
import 'package:raabta/services/intelligence/risk_insight_adapter.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Hand-written, evidence-based risk rules over existing Raabta data sources.
///
/// No Firestore persistence in this phase — Phase 0 audit found no `risks`
/// collection; results are produced in-memory until a later phase needs read-back.
class RiskDetector {
  RiskDetector({
    DateTime? now,
    this.documentExpiryWindowDays = 7,
    this.billDueWindowDays = 3,
    AttentionScorer? attentionScorer,
  })  : _now = now,
        _attentionScorer = attentionScorer ??
            AttentionScorer(
              now: now,
              typeSeverity: insightTypeSeverity,
            );

  final DateTime? _now;
  final int documentExpiryWindowDays;
  final int billDueWindowDays;
  final AttentionScorer _attentionScorer;

  static const scannedDocumentsCollection = 'scanned_documents';
  static const billTrackerCollection = 'bill_tracker';
  static const eosbCalculationsCollection = 'users/eosb_calculations';
  static const evidenceEntriesCollection = 'users/evidence_entries';

  /// Severity weights fed into Phase 3 [AttentionScorer].
  static const insightTypeSeverity = <String, double>{
    Risk.typeDocumentExpiry: 0.95,
    Risk.typeBillDue: 0.85,
    Risk.typeEosbViolation: 0.90,
    Risk.typeLabourComplaintDeadline: 0.88,
  };

  DateTime get _clock => _now ?? DateTime.now();

  /// Flags Document Vault documents expiring within [documentExpiryWindowDays] as critical.
  List<Risk> checkDocumentExpiry({
    required String userId,
    required List<DocumentVaultRecord> documents,
  }) {
    final risks = <Risk>[];
    for (final doc in documents) {
      final expiry = doc.expiryDate;
      if (expiry == null) continue;

      final daysLeft = expiry.difference(_clock).inDays;
      if (daysLeft > documentExpiryWindowDays) continue;

      final label = doc.displayName?.trim().isNotEmpty == true
          ? doc.displayName!
          : (doc.docType ?? 'Document');

      risks.add(
        Risk(
          id: _riskId(Risk.typeDocumentExpiry, doc.id),
          userId: userId,
          type: Risk.typeDocumentExpiry,
          severity: Risk.severityCritical,
          evidenceReference: doc.id,
          evidenceCollection: scannedDocumentsCollection,
          recommendedAction: daysLeft < 0
              ? '$label expired — renew immediately'
              : '$label expires in $daysLeft day(s) — renew before ${_formatDate(expiry)}',
          createdAt: _clock,
        ),
      );
    }
    return risks;
  }

  /// Flags unpaid Bill Tracker bills due within [billDueWindowDays] as high.
  List<Risk> checkBillDue({
    required String userId,
    required List<BillDueRecord> bills,
  }) {
    final risks = <Risk>[];
    for (final bill in bills) {
      if (bill.isPaid) continue;

      final daysUntil = bill.dueDate.difference(_clock).inDays;
      if (daysUntil > billDueWindowDays) continue;

      risks.add(
        Risk(
          id: _riskId(Risk.typeBillDue, bill.id),
          userId: userId,
          type: Risk.typeBillDue,
          severity: Risk.severityHigh,
          evidenceReference: bill.id,
          evidenceCollection: billTrackerCollection,
          recommendedAction: daysUntil < 0
              ? '${bill.provider} bill is overdue — pay now'
              : '${bill.provider} bill due in $daysUntil day(s) on ${_formatDate(bill.dueDate)}',
          createdAt: _clock,
        ),
      );
    }
    return risks;
  }

  /// Art. 10 — Law No. 14 of 2004: lawsuit for entitlements lapses one year from
  /// contract expiry. Uses [LegalDeadlineService.eosbLabourClaimDeadline] from
  /// [EosbEmployeeInput.lastWorkingDate] — not evidence incident dates.
  ///
  /// Known limitation: [LegalDeadlineService] does not suspend the clock during
  /// active MoL conciliation — follow-up scope if product requires it.
  static const labourComplaintFilingWindowDays =
      LegalDeadlineService.eosbFilingLimitDays;
  static const labourComplaintDeadlineWarningDays = 30;

  /// Flags when the verified Art. 10 filing deadline is within the warning window.
  ///
  /// Returns empty when [lastWorkingDate] is null — no fabricated deadline.
  List<Risk> checkLabourComplaintDeadline({
    required String userId,
    DateTime? lastWorkingDate,
    String? eosbCalculationId,
  }) {
    final deadline = LegalDeadlineService.eosbLabourClaimDeadline(
      contractExpiryDate: lastWorkingDate,
      now: _clock,
    );
    if (deadline == null) return [];

    final daysLeft = deadline.daysRemaining;
    if (daysLeft > labourComplaintDeadlineWarningDays) return [];

    final refId = eosbCalculationId ?? 'eosb';
    final severity = daysLeft < 0 ? Risk.severityCritical : Risk.severityHigh;
    return [
      Risk(
        id: _riskId(Risk.typeLabourComplaintDeadline, refId),
        userId: userId,
        type: Risk.typeLabourComplaintDeadline,
        severity: severity,
        evidenceReference: refId,
        evidenceCollection: eosbCalculationsCollection,
        recommendedAction: daysLeft < 0
            ? '${LegalDeadlineService.eosbCitation} filing window may have passed '
                '(deadline ${_formatDate(deadline.deadlineDate)}) — verify with ADLSA 16008'
            : '${LegalDeadlineService.eosbCitation} filing deadline in $daysLeft day(s) '
                '(${_formatDate(deadline.deadlineDate)}) — see EOSB deadline card',
        createdAt: _clock,
      ),
    ];
  }

  /// Skipped: Raabta has no dedicated Istimara / vehicle-registration tracker.
  ///
  /// Driving licences live in Document Vault (`scanned_documents`, `docType`:
  /// `drivingLicense`, field `expiryDate`) and are already covered by
  /// [checkDocumentExpiry]. Returns an empty list by design.
  List<Risk> checkVehicleExpiry({
    required String userId,
    List<DocumentVaultRecord> documents = const [],
  }) {
    return const [];
  }

  /// Wraps the existing [ViolationDetector.detect] — no reimplemented rules.
  List<Risk> checkEOSBViolation({
    required String userId,
    required EosbEmployeeInput input,
    required List<EntitlementBreakdownItem> breakdown,
    required String calculationId,
  }) {
    final violations = ViolationDetector.detect(input, breakdown);
    return violations
        .map(
          (violation) => Risk(
            id: _riskId(
              Risk.typeEosbViolation,
              '$calculationId:${violation.ruleKey}',
            ),
            userId: userId,
            type: Risk.typeEosbViolation,
            severity: _severityFromRiskLevelKey(violation.riskLevelKey),
            evidenceReference: calculationId,
            evidenceCollection: eosbCalculationsCollection,
            recommendedAction:
                'Review EOSB labour-law flag (${violation.titleKey}) — see rule ${violation.ruleKey}',
            createdAt: _clock,
          ),
        )
        .toList();
  }

  /// Runs all active rules and scores each [Risk] through [AttentionScorer].
  List<ScoredRisk> detectAndScore({
    required String userId,
    List<DocumentVaultRecord> documents = const [],
    List<BillDueRecord> bills = const [],
    EosbEmployeeInput? eosbInput,
    List<EntitlementBreakdownItem>? eosbBreakdown,
    String? eosbCalculationId,
    List<EvidenceDeadlineRecord> evidenceEntries = const [],
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    final deadlines = <String, DateTime>{};

    for (final doc in documents) {
      if (doc.expiryDate != null) {
        deadlines[_riskId(Risk.typeDocumentExpiry, doc.id)] = doc.expiryDate!;
      }
    }
    for (final bill in bills) {
      deadlines[_riskId(Risk.typeBillDue, bill.id)] = bill.dueDate;
    }
    if (eosbInput?.lastWorkingDate != null) {
      final art10 = LegalDeadlineService.eosbLabourClaimDeadline(
        contractExpiryDate: eosbInput!.lastWorkingDate,
        now: _clock,
      );
      if (art10 != null && eosbCalculationId != null) {
        deadlines[_riskId(Risk.typeLabourComplaintDeadline, eosbCalculationId)] =
            art10.deadlineDate;
      }
    }

    final risks = <Risk>[
      ...checkDocumentExpiry(userId: userId, documents: documents),
      ...checkBillDue(userId: userId, bills: bills),
      ...checkVehicleExpiry(userId: userId, documents: documents),
      ...checkLabourComplaintDeadline(
        userId: userId,
        lastWorkingDate: eosbInput?.lastWorkingDate,
        eosbCalculationId: eosbCalculationId,
      ),
      if (eosbInput != null &&
          eosbBreakdown != null &&
          eosbCalculationId != null)
        ...checkEOSBViolation(
          userId: userId,
          input: eosbInput,
          breakdown: eosbBreakdown,
          calculationId: eosbCalculationId,
        ),
    ];

    return scoreRisks(
      risks,
      deadlineByRiskId: deadlines,
      recentInsightHistory: recentInsightHistory,
    );
  }

  List<ScoredRisk> scoreRisks(
    List<Risk> risks, {
    Map<String, DateTime> deadlineByRiskId = const {},
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    return risks.map((risk) {
      final insight = RiskInsightAdapter.toInsight(
        risk,
        expiresAt: deadlineByRiskId[risk.id],
      );
      final priority = _attentionScorer.score(
        insight,
        recentHistory: recentInsightHistory,
      );
      return ScoredRisk(
        risk: risk,
        insight: insight,
        priority: priority,
        explanation: explain(risk),
      );
    }).toList();
  }

  /// Template-based "why am I seeing this" for a [Risk] — no AI call.
  static Explanation explain(Risk risk) =>
      IntelligenceExplanationBuilder.forRisk(risk);

  static String _riskId(String type, String evidenceId) => '${type}_$evidenceId';

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String _severityFromRiskLevelKey(String riskLevelKey) {
    switch (riskLevelKey) {
      case 'eosb_risk_critical':
        return Risk.severityCritical;
      case 'eosb_risk_high':
        return Risk.severityHigh;
      case 'eosb_risk_medium':
        return Risk.severityMedium;
      default:
        return Risk.severityLow;
    }
  }
}
