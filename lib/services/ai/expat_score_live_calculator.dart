import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/models/advanced_profile.dart';
import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/intelligence/consistency_checker.dart';
import 'package:raabta/services/intelligence/risk_detector.dart';
import 'package:raabta/services/intelligence/risk_insight_adapter.dart';

/// Live Firestore/profile inputs for Expat Life Score calculation.
class ExpatScoreLiveInputs {
  const ExpatScoreLiveInputs({
    required this.profile,
    this.documents = const [],
    this.bills = const [],
    this.eosbInput,
    this.eosbBreakdown,
    this.eosbCalculationId,
    this.eosbSavedAt,
    this.overtimeCompanyName = '',
    this.overtimeBasicSalary = 0,
    this.cvDocument,
    this.scoredRisks = const [],
    this.consistencyInsights = const [],
    this.now,
  });

  final UserAIProfile profile;
  final List<DocumentVaultRecord> documents;
  final List<BillDueRecord> bills;
  final EosbEmployeeInput? eosbInput;
  final List<EntitlementBreakdownItem>? eosbBreakdown;
  final String? eosbCalculationId;
  final DateTime? eosbSavedAt;
  final String overtimeCompanyName;
  final double overtimeBasicSalary;
  final CvDocument? cvDocument;
  final List<ScoredRisk> scoredRisks;
  final List<ScoredConsistencyInsight> consistencyInsights;
  final DateTime? now;

  ExpatScoreLiveInputs copyWith({
    UserAIProfile? profile,
    List<DocumentVaultRecord>? documents,
    List<BillDueRecord>? bills,
    EosbEmployeeInput? eosbInput,
    List<EntitlementBreakdownItem>? eosbBreakdown,
    String? eosbCalculationId,
    DateTime? eosbSavedAt,
    String? overtimeCompanyName,
    double? overtimeBasicSalary,
    CvDocument? cvDocument,
    List<ScoredRisk>? scoredRisks,
    List<ScoredConsistencyInsight>? consistencyInsights,
    DateTime? now,
  }) {
    return ExpatScoreLiveInputs(
      profile: profile ?? this.profile,
      documents: documents ?? this.documents,
      bills: bills ?? this.bills,
      eosbInput: eosbInput ?? this.eosbInput,
      eosbBreakdown: eosbBreakdown ?? this.eosbBreakdown,
      eosbCalculationId: eosbCalculationId ?? this.eosbCalculationId,
      eosbSavedAt: eosbSavedAt ?? this.eosbSavedAt,
      overtimeCompanyName: overtimeCompanyName ?? this.overtimeCompanyName,
      overtimeBasicSalary: overtimeBasicSalary ?? this.overtimeBasicSalary,
      cvDocument: cvDocument ?? this.cvDocument,
      scoredRisks: scoredRisks ?? this.scoredRisks,
      consistencyInsights: consistencyInsights ?? this.consistencyInsights,
      now: now ?? this.now,
    );
  }
}

/// Per-category explainability metadata surfaced on View Details.
class ExpatScoreCategoryMeta {
  const ExpatScoreCategoryMeta({
    required this.rawPoints,
    required this.maxPoints,
    required this.confidence,
    this.insufficientData = false,
    this.changeExplanation,
    this.evidenceLines = const [],
  });

  final double rawPoints;
  final double maxPoints;
  final double confidence;
  final bool insufficientData;
  final Explanation? changeExplanation;
  final List<String> evidenceLines;

  double get percent =>
      maxPoints <= 0 ? 0 : ((rawPoints / maxPoints) * 100).clamp(0, 100);

  Map<String, dynamic> toJson() => {
        'rawPoints': rawPoints,
        'maxPoints': maxPoints,
        'confidence': confidence,
        'insufficientData': insufficientData,
        'evidenceLines': evidenceLines,
        if (changeExplanation != null)
          'changeExplanation': changeExplanation!.toJson(),
      };

  factory ExpatScoreCategoryMeta.fromJson(Map<String, dynamic> json) {
    return ExpatScoreCategoryMeta(
      rawPoints: (json['rawPoints'] as num?)?.toDouble() ?? 0,
      maxPoints: (json['maxPoints'] as num?)?.toDouble() ?? 1,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1,
      insufficientData: json['insufficientData'] as bool? ?? false,
      evidenceLines: (json['evidenceLines'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      changeExplanation: json['changeExplanation'] != null
          ? Explanation.fromJson(
              Map<String, dynamic>.from(json['changeExplanation'] as Map),
            )
          : null,
    );
  }
}

/// Deterministic category scoring from live repositories — zero AI cost.
class ExpatScoreLiveCalculator {
  const ExpatScoreLiveCalculator();

  static const maxCareer = 25.0;
  static const maxHousing = 20.0;
  static const maxFinancial = 20.0;
  static const maxCommunity = 15.0;
  static const maxDocumentation = 10.0;
  static const maxHealth = 10.0;

  ExpatScoreLiveResult compute(ExpatScoreLiveInputs inputs) {
    final interests =
        inputs.profile.interests.map((e) => e.toLowerCase()).toSet();
    bool flag(String key) =>
        interests.contains(key) || interests.any((i) => i.startsWith('$key:'));

    final financialRisks = inputs.scoredRisks
        .where(
          (r) =>
              r.risk.type == Risk.typeBillDue ||
              r.risk.type == Risk.typeEosbViolation,
        )
        .toList();
    final docRisks = inputs.scoredRisks
        .where((r) => r.risk.type == Risk.typeDocumentExpiry)
        .toList();

    final financial = _scoreFinancial(inputs, financialRisks, flag);
    final documentation = _scoreDocumentation(inputs, docRisks, flag);
    final career = _scoreCareer(inputs, flag);
    final housing = _scoreHousing(inputs.profile, flag);
    final community = _scoreCommunity(inputs.profile, flag);
    final health = _scoreHealth(flag);

    return ExpatScoreLiveResult(
      breakdown: {
        'career': career.rawPoints,
        'housing': housing.rawPoints,
        'financial': financial.rawPoints,
        'community': community.rawPoints,
        'health': health.rawPoints,
        'documentation': documentation.rawPoints,
      },
      categoryMeta: {
        'career': career,
        'housing': housing,
        'financial': _applyConsistencyConfidence(
          financial,
          inputs.consistencyInsights,
        ),
        'community': community,
        'documentation': documentation,
        'health': health,
      },
    );
  }

  ExpatScoreCategoryMeta _scoreFinancial(
    ExpatScoreLiveInputs inputs,
    List<ScoredRisk> financialRisks,
    bool Function(String) flag,
  ) {
    var points = 0.0;
    final evidence = <String>[];

    if (inputs.eosbInput != null && inputs.eosbCalculationId != null) {
      points += 6;
      evidence.add('EOSB calculation on file');
    } else if (flag('profile:eosb_calculation')) {
      points += 4;
      evidence.add('EOSB calculation completed');
    }

    if (inputs.overtimeBasicSalary > 0 || flag('profile:overtime_calculation')) {
      points += 4;
      evidence.add('Overtime Truth profile present');
    }

    final billCount = inputs.bills.where((b) => !b.isPaid).length;
    if (billCount >= 3 || flag('profile:bill_tracker')) {
      points += 4;
      evidence.add('Bill Tracker active ($billCount unpaid bills tracked)');
    }

    if (flag('profile:money_transfer')) {
      points += 2;
      evidence.add('Money transfer preference set');
    }
    if (flag('profile:exchange_alerts')) {
      points += 2;
      evidence.add('Exchange rate alerts enabled');
    }
    final budgetMin = inputs.profile.budgetRange['min'] ?? 0;
    if (budgetMin > 0) {
      points += 2;
      evidence.add('Monthly budget range configured');
    }

    for (final scored in financialRisks) {
      points -= scored.risk.type == Risk.typeEosbViolation ? 5 : 4;
      evidence.add('Risk: ${scored.insight.summary}');
    }

    points = points.clamp(0, maxFinancial);

    return ExpatScoreCategoryMeta(
      rawPoints: points,
      maxPoints: maxFinancial,
      confidence: _confidenceFromRisks(financialRisks.length),
      changeExplanation: _primaryExplanation(financialRisks),
      evidenceLines: evidence,
    );
  }

  ExpatScoreCategoryMeta _scoreDocumentation(
    ExpatScoreLiveInputs inputs,
    List<ScoredRisk> docRisks,
    bool Function(String) flag,
  ) {
    var points = 0.0;
    final evidence = <String>[];

    final vaultTypes = inputs.documents
        .map((d) => (d.docType ?? '').toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    if (vaultTypes.any((t) => t.contains('qid')) || flag('profile:vault_qid')) {
      points += 2;
      evidence.add('QID tracked in Document Vault');
    }
    if (vaultTypes.any((t) => t.contains('passport')) ||
        flag('profile:vault_passport')) {
      points += 2;
      evidence.add('Passport tracked in Document Vault');
    }
    if (vaultTypes.any((t) => t.contains('visa')) ||
        flag('profile:vault_visa')) {
      points += 2;
      evidence.add('Visa / Iqama tracked in Document Vault');
    }
    if (vaultTypes.any((t) => t.contains('driving') || t.contains('license')) ||
        flag('profile:vault_driving')) {
      points += 2;
      evidence.add('Driving licence tracked');
    }
    if (inputs.documents.isNotEmpty) {
      evidence.add('${inputs.documents.length} document(s) in vault');
    }

    for (final scored in docRisks) {
      points -= 3;
      evidence.add('Risk: ${scored.insight.summary}');
    }

    points = points.clamp(0, maxDocumentation);

    return ExpatScoreCategoryMeta(
      rawPoints: points,
      maxPoints: maxDocumentation,
      confidence: _confidenceFromRisks(docRisks.length),
      changeExplanation: _primaryExplanation(docRisks),
      evidenceLines: evidence,
    );
  }

  ExpatScoreCategoryMeta _scoreCareer(
    ExpatScoreLiveInputs inputs,
    bool Function(String) flag,
  ) {
    var points = 0.0;
    final evidence = <String>[];
    final profile = inputs.profile;
    final cv = inputs.cvDocument;

    if (profile.profession.trim().isNotEmpty) {
      points += 5;
      evidence.add('Profession: ${profile.profession.trim()}');
    }
    if (profile.skills.length >= 3) {
      points += 5;
      evidence.add('${profile.skills.length} skills listed');
    }
    if (profile.certifications.isNotEmpty) {
      points += 3;
      evidence.add('Certifications added');
    }
    if (cv != null && _cvIsComplete(cv)) {
      points += 8;
      evidence.add('CV Maker profile complete');
    } else if (cv != null || flag('profile:cv_started')) {
      points += 3;
      evidence.add('CV Maker started — finish for more points');
    }
    if (profile.savedJobIds.isNotEmpty) {
      points += 4;
      evidence.add('${profile.savedJobIds.length} saved jobs');
    } else if (profile.viewedJobIds.length >= 5) {
      points += 3;
      evidence.add('Explored ${profile.viewedJobIds.length} job listings');
    }
    if (profile.advancedProfileConsentGiven &&
        (profile.advancedProfile?.hasAnyField ?? false)) {
      points += 2;
      evidence.add('Optional advanced profile shared for personalization');
    }

    points = points.clamp(0, maxCareer);

    return ExpatScoreCategoryMeta(
      rawPoints: points,
      maxPoints: maxCareer,
      confidence: 1.0,
      evidenceLines: evidence,
      changeExplanation: evidence.isEmpty
          ? null
          : Explanation(
              why: evidence.join(' · '),
              source: const IntelligenceSource(
                type: 'user',
                reference: 'users/cv_documents',
                verificationStatus: 'verified',
              ),
              confidence: 0.75,
              lastUpdated: DateTime.now(),
            ),
    );
  }

  ExpatScoreCategoryMeta _scoreHousing(
    UserAIProfile profile,
    bool Function(String) flag,
  ) {
    final hasArea = profile.preferredArea.trim().isNotEmpty &&
        profile.preferredArea.toLowerCase() != 'unknown';
    final hasListingEngagement = profile.savedHousingIds.isNotEmpty ||
        profile.viewedHousingIds.isNotEmpty ||
        flag('profile:housing_confirmed');

    if (!hasArea && !hasListingEngagement) {
      return const ExpatScoreCategoryMeta(
        rawPoints: 0,
        maxPoints: maxHousing,
        confidence: 1.0,
        insufficientData: true,
        evidenceLines: [
          'Not enough housing data yet — browse listings or set your preferred area',
        ],
      );
    }

    var points = 0.0;
    final evidence = <String>[];
    if (hasArea) {
      points += 5;
      evidence.add('Preferred area: ${profile.preferredArea.trim()}');
    }
    if (profile.savedHousingIds.isNotEmpty || flag('profile:housing_confirmed')) {
      points += 8;
      evidence.add('Housing search confirmed');
    }
    if (profile.viewedHousingIds.length >= 3) {
      points += 4;
      evidence.add('Viewed ${profile.viewedHousingIds.length} listings');
    } else if (profile.viewedHousingIds.isNotEmpty) {
      points += 2;
      evidence.add('Viewed ${profile.viewedHousingIds.length} listing(s)');
    }
    if (flag('profile:housing_review')) {
      points += 3;
      evidence.add('Housing review written');
    }

    points = points.clamp(0, maxHousing);

    return ExpatScoreCategoryMeta(
      rawPoints: points,
      maxPoints: maxHousing,
      confidence: 1.0,
      evidenceLines: evidence,
    );
  }

  ExpatScoreCategoryMeta _scoreCommunity(
    UserAIProfile profile,
    bool Function(String) flag,
  ) {
    final hasGroups = profile.communityGroups.isNotEmpty;
    final hasPosts = flag('profile:community_posts');
    final hasAnswers = flag('profile:questions_answered');
    final hasEvents = flag('profile:events_attended');

    if (!hasGroups && !hasPosts && !hasAnswers && !hasEvents) {
      return const ExpatScoreCategoryMeta(
        rawPoints: 0,
        maxPoints: maxCommunity,
        confidence: 1.0,
        insufficientData: true,
        evidenceLines: [
          'Not enough community activity yet — join a group or post in Community',
        ],
      );
    }

    var points = 0.0;
    final evidence = <String>[];
    if (hasGroups) {
      points += 5;
      evidence.add('Joined ${profile.communityGroups.length} group(s)');
    }
    if (hasPosts) {
      points += 3;
      evidence.add('Community posts published');
    }
    if (hasAnswers) {
      points += 4;
      evidence.add('Answered Ask Qatar questions');
    }
    if (hasEvents) {
      points += 3;
      evidence.add('Attended community events');
    }

    points = points.clamp(0, maxCommunity);

    return ExpatScoreCategoryMeta(
      rawPoints: points,
      maxPoints: maxCommunity,
      confidence: 1.0,
      evidenceLines: evidence,
    );
  }

  ExpatScoreCategoryMeta _scoreHealth(bool Function(String) flag) {
    var points = 0.0;
    final evidence = <String>[];
    if (flag('profile:doctor_preference')) {
      points += 5;
      evidence.add('Doctor language preference set');
    }
    if (flag('profile:medical_insurance')) {
      points += 3;
      evidence.add('Medical insurance confirmed');
    }
    if (flag('profile:emergency_contacts')) {
      points += 2;
      evidence.add('Emergency contacts saved');
    }
    points = points.clamp(0, maxHealth);
    return ExpatScoreCategoryMeta(
      rawPoints: points,
      maxPoints: maxHealth,
      confidence: 1.0,
      evidenceLines: evidence,
    );
  }

  ExpatScoreCategoryMeta _applyConsistencyConfidence(
    ExpatScoreCategoryMeta financial,
    List<ScoredConsistencyInsight> insights,
  ) {
    if (insights.isEmpty) return financial;

    var confidence = financial.confidence;
    Explanation? mismatchExplanation;
    final lines = [...financial.evidenceLines];

    for (final insight in insights) {
      confidence = (confidence - 0.2).clamp(0.35, 1.0);
      lines.add('Data mismatch: ${insight.insight.summary}');
      mismatchExplanation ??= insight.explanation;
    }

    return ExpatScoreCategoryMeta(
      rawPoints: financial.rawPoints,
      maxPoints: financial.maxPoints,
      confidence: confidence,
      changeExplanation: mismatchExplanation ?? financial.changeExplanation,
      evidenceLines: lines,
    );
  }

  Explanation? _primaryExplanation(List<ScoredRisk> risks) {
    if (risks.isEmpty) return null;
    return risks.first.explanation;
  }

  double _confidenceFromRisks(int riskCount) {
    if (riskCount == 0) return 1.0;
    if (riskCount == 1) return 0.85;
    return 0.7;
  }

  bool _cvIsComplete(CvDocument cv) {
    final hasExperience = cv.experience.any(
      (e) => e.jobTitle.trim().isNotEmpty,
    );
    final hasSkills = cv.skills.hardSkills.isNotEmpty ||
        cv.skills.softSkills.isNotEmpty ||
        cv.skills.toolsSoftware.isNotEmpty;
    return cv.fullName.trim().isNotEmpty &&
        cv.professionalSummary.trim().isNotEmpty &&
        hasExperience &&
        hasSkills;
  }
}

class ExpatScoreLiveResult {
  const ExpatScoreLiveResult({
    required this.breakdown,
    required this.categoryMeta,
  });

  final Map<String, double> breakdown;
  final Map<String, ExpatScoreCategoryMeta> categoryMeta;
}

List<ScoredRisk> scoreRisksForExpatInputs(ExpatScoreLiveInputs inputs) {
  return RiskDetector(now: inputs.now).detectAndScore(
    userId: inputs.profile.uid,
    documents: inputs.documents,
    bills: inputs.bills,
    eosbInput: inputs.eosbInput,
    eosbBreakdown: inputs.eosbBreakdown,
    eosbCalculationId: inputs.eosbCalculationId,
  );
}

List<ScoredConsistencyInsight> scoreConsistencyForExpatInputs(
  ExpatScoreLiveInputs inputs,
) {
  return ConsistencyChecker(now: inputs.now).detectAndScore(
    userId: inputs.profile.uid,
    eosbSalary: inputs.eosbInput != null
        ? EosbSalarySnapshot(
            basicSalary: inputs.eosbInput!.basicSalary,
            updatedAt: inputs.eosbSavedAt,
          )
        : null,
    eosbTimestamp: EosbTimestampSnapshot(updatedAt: inputs.eosbSavedAt),
    expatScoreTimestamp: ExpatScoreTimestampSnapshot(
      lastCalculated: inputs.profile.score.lastCalculated,
    ),
    eosbEmployer: inputs.eosbInput != null
        ? EosbEmployerSnapshot(companyName: inputs.eosbInput!.companyName)
        : null,
    overtimeEmployer: inputs.overtimeCompanyName.trim().isNotEmpty
        ? OvertimeEmployerSnapshot(companyName: inputs.overtimeCompanyName)
        : null,
  );
}
