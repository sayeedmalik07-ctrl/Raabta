import 'package:raabta/features/eosb/domain/services/employer_name_normalizer.dart';
import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/services/intelligence/attention_scorer.dart';
import 'package:raabta/services/intelligence/intelligence_explanation_builder.dart';

/// Cross-feature truth consistency — deterministic, zero AI cost.
///
/// Reads live snapshots passed in by callers (EOSB history, CV, Overtime,
/// Expat Score). No Firestore persistence — same in-memory path as Phase 5
/// [RiskDetector].
class ConsistencyChecker {
  ConsistencyChecker({
    DateTime? now,
    this.salaryToleranceQar = 1,
    AttentionScorer? attentionScorer,
  })  : _now = now,
        _attentionScorer = attentionScorer ??
            AttentionScorer(
              now: now,
              typeSeverity: insightTypeSeverity,
            );

  final DateTime? _now;
  final double salaryToleranceQar;
  final AttentionScorer _attentionScorer;

  static const typeDataMismatch = 'data_mismatch';

  static const eosbCalculationsCollection = 'users/eosb_calculations';
  static const cvDocumentsCollection = 'users/cv_documents';
  static const overtimeInputCollection = 'eosb_overtime_input';
  static const expatScoreHistoryCollection = 'users/score_history';

  static const checkIdSalary = 'eosb_salary_vs_cv_salary';
  static const checkIdStaleness = 'eosb_updated_vs_expat_score';
  static const checkIdEmployer = 'eosb_employer_vs_overtime_employer';

  /// Severity weight for Phase 3 [AttentionScorer].
  static const insightTypeSeverity = <String, double>{
    typeDataMismatch: 0.72,
  };

  DateTime get _clock => _now ?? DateTime.now();

  /// Runs all three checks and scores each mismatch through [AttentionScorer].
  List<ScoredConsistencyInsight> detectAndScore({
    required String userId,
    EosbSalarySnapshot? eosbSalary,
    CvStatedSalarySnapshot? cvSalary,
    EosbTimestampSnapshot? eosbTimestamp,
    ExpatScoreTimestampSnapshot? expatScoreTimestamp,
    EosbEmployerSnapshot? eosbEmployer,
    OvertimeEmployerSnapshot? overtimeEmployer,
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    final scored = <ScoredConsistencyInsight>[
      ...checkEosbSalaryVsCvSalary(
        userId: userId,
        eosb: eosbSalary,
        cv: cvSalary,
        recentInsightHistory: recentInsightHistory,
      ),
      ...checkEosbStalenessVsExpatScore(
        userId: userId,
        eosb: eosbTimestamp,
        expatScore: expatScoreTimestamp,
        recentInsightHistory: recentInsightHistory,
      ),
      ...checkEosbEmployerVsOvertimeEmployer(
        userId: userId,
        eosb: eosbEmployer,
        overtime: overtimeEmployer,
        recentInsightHistory: recentInsightHistory,
      ),
    ];
    return scored;
  }

  /// EOSB [EosbSalarySnapshot.basicSalary] vs CV Maker stated salary (most recent).
  List<ScoredConsistencyInsight> checkEosbSalaryVsCvSalary({
    required String userId,
    EosbSalarySnapshot? eosb,
    CvStatedSalarySnapshot? cv,
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    if (eosb == null || cv == null) return const [];
    if (eosb.basicSalary <= 0 || cv.statedSalary <= 0) return const [];

    if (_salariesAgree(eosb.basicSalary, cv.statedSalary)) {
      return const [];
    }

    return [
      _scoreMismatch(
        userId: userId,
        checkId: checkIdSalary,
        summary:
            'EOSB basic salary (QAR ${_formatAmount(eosb.basicSalary)}) differs '
            'from CV stated salary (QAR ${_formatAmount(cv.statedSalary)})',
        sourceA: const IntelligenceSource(
          type: 'official',
          reference: '$eosbCalculationsCollection/salary',
          verificationStatus: 'verified',
        ),
        sourceB: const IntelligenceSource(
          type: 'user',
          reference: '$cvDocumentsCollection/salary',
          verificationStatus: 'verified',
        ),
        labelA: 'EOSB Calculator',
        labelB: 'CV Maker',
        valueA: 'QAR ${_formatAmount(eosb.basicSalary)}',
        valueB: 'QAR ${_formatAmount(cv.statedSalary)}',
        recentInsightHistory: recentInsightHistory,
      ),
    ];
  }

  /// EOSB last-updated vs Expat Life Score last-calculated (staleness).
  List<ScoredConsistencyInsight> checkEosbStalenessVsExpatScore({
    required String userId,
    EosbTimestampSnapshot? eosb,
    ExpatScoreTimestampSnapshot? expatScore,
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    if (eosb == null || expatScore == null) return const [];
    final eosbAt = eosb.updatedAt;
    final expatAt = expatScore.lastCalculated;
    if (eosbAt == null || expatAt == null) return const [];

    // Score is stale when EOSB was updated after the score was last calculated.
    if (!eosbAt.isAfter(expatAt)) return const [];

    return [
      _scoreMismatch(
        userId: userId,
        checkId: checkIdStaleness,
        summary:
            'EOSB was updated after your Expat Life Score was last calculated — '
            'your score may not reflect your latest EOSB data',
        sourceA: const IntelligenceSource(
          type: 'official',
          reference: '$eosbCalculationsCollection/updatedAt',
          verificationStatus: 'verified',
        ),
        sourceB: const IntelligenceSource(
          type: 'user',
          reference: '$expatScoreHistoryCollection/lastCalculated',
          verificationStatus: 'verified',
        ),
        labelA: 'EOSB Calculator',
        labelB: 'Expat Life Score',
        valueA: _formatTimestamp(eosbAt),
        valueB: _formatTimestamp(expatAt),
        recentInsightHistory: recentInsightHistory,
      ),
    ];
  }

  /// EOSB [EosbEmployerSnapshot.companyName] vs Overtime employer field.
  List<ScoredConsistencyInsight> checkEosbEmployerVsOvertimeEmployer({
    required String userId,
    EosbEmployerSnapshot? eosb,
    OvertimeEmployerSnapshot? overtime,
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    if (eosb == null || overtime == null) return const [];
    final eosbName = EmployerNameNormalizer.normalize(eosb.companyName);
    final otName = EmployerNameNormalizer.normalize(overtime.companyName);
    if (eosbName.isEmpty || otName.isEmpty) return const [];
    if (eosbName == otName) return const [];

    return [
      _scoreMismatch(
        userId: userId,
        checkId: checkIdEmployer,
        summary:
            'EOSB employer ($eosbName) differs from Overtime employer ($otName)',
        sourceA: const IntelligenceSource(
          type: 'official',
          reference: '$eosbCalculationsCollection/companyName',
          verificationStatus: 'verified',
        ),
        sourceB: const IntelligenceSource(
          type: 'user',
          reference: '$overtimeInputCollection/companyName',
          verificationStatus: 'verified',
        ),
        labelA: 'EOSB Calculator',
        labelB: 'Overtime Truth',
        valueA: eosb.companyName.trim(),
        valueB: overtime.companyName.trim(),
        recentInsightHistory: recentInsightHistory,
      ),
    ];
  }

  ScoredConsistencyInsight _scoreMismatch({
    required String userId,
    required String checkId,
    required String summary,
    required IntelligenceSource sourceA,
    required IntelligenceSource sourceB,
    required String labelA,
    required String labelB,
    required String valueA,
    required String valueB,
    List<IntelligenceInsight>? recentInsightHistory,
  }) {
    final insight = IntelligenceInsight(
      id: _insightId(checkId, userId),
      userId: userId,
      type: typeDataMismatch,
      summary: summary,
      confidence: 0.88,
      source: sourceA,
      createdAt: _clock,
    );

    final priority = _attentionScorer.score(
      insight,
      recentHistory: recentInsightHistory,
    );

    final mismatch = DataMismatchDetail(
      checkId: checkId,
      labelA: labelA,
      labelB: labelB,
      valueA: valueA,
      valueB: valueB,
      sourceA: sourceA,
      sourceB: sourceB,
    );

    return ScoredConsistencyInsight(
      insight: insight,
      priority: priority,
      explanation: IntelligenceExplanationBuilder.forDataMismatch(
        labelA: labelA,
        labelB: labelB,
        valueA: valueA,
        valueB: valueB,
        source: sourceA,
        detectedAt: _clock,
      ),
      detail: mismatch,
    );
  }

  bool _salariesAgree(double a, double b) =>
      (a - b).abs() <= salaryToleranceQar;

  static String _insightId(String checkId, String userId) =>
      '${typeDataMismatch}_${checkId}_$userId';

  static String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  static String _formatTimestamp(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// EOSB basic salary — from [EosbEmployeeInput.basicSalary] / latest calc.
class EosbSalarySnapshot {
  const EosbSalarySnapshot({
    required this.basicSalary,
    this.updatedAt,
  });

  final double basicSalary;
  final DateTime? updatedAt;
}

/// CV Maker stated salary — most recent employment entry when salary is captured.
class CvStatedSalarySnapshot {
  const CvStatedSalarySnapshot({
    required this.statedSalary,
    this.updatedAt,
  });

  final double statedSalary;
  final DateTime? updatedAt;
}

/// EOSB last-updated timestamp — e.g. latest [CalculationHistoryEntry.savedAt].
class EosbTimestampSnapshot {
  const EosbTimestampSnapshot({this.updatedAt});

  final DateTime? updatedAt;
}

/// Expat Life Score last-calculated — [ExpatLifeScore.lastCalculated].
class ExpatScoreTimestampSnapshot {
  const ExpatScoreTimestampSnapshot({this.lastCalculated});

  final DateTime? lastCalculated;
}

/// EOSB employer — [EosbEmployeeInput.companyName].
class EosbEmployerSnapshot {
  const EosbEmployerSnapshot({
    required this.companyName,
    this.updatedAt,
  });

  final String companyName;
  final DateTime? updatedAt;
}

/// Overtime employer — [OvertimeTruthInput.companyName].
class OvertimeEmployerSnapshot {
  const OvertimeEmployerSnapshot({
    required this.companyName,
    this.updatedAt,
  });

  final String companyName;
  final DateTime? updatedAt;
}

/// Plain-language detail for Phase 18 explainability — no auto-resolution.
class DataMismatchDetail {
  const DataMismatchDetail({
    required this.checkId,
    required this.labelA,
    required this.labelB,
    required this.valueA,
    required this.valueB,
    required this.sourceA,
    required this.sourceB,
  });

  final String checkId;
  final String labelA;
  final String labelB;
  final String valueA;
  final String valueB;
  final IntelligenceSource sourceA;
  final IntelligenceSource sourceB;
}

/// Mismatch insight paired with attention priority and explanation.
class ScoredConsistencyInsight {
  const ScoredConsistencyInsight({
    required this.insight,
    required this.priority,
    required this.explanation,
    required this.detail,
  });

  final IntelligenceInsight insight;
  final IntelligencePriority priority;
  final Explanation explanation;
  final DataMismatchDetail detail;
}
