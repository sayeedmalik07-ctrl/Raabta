/// Incident Response Mode — shared data categories, outcomes, and results.
///
/// Separate from [ScamShieldRiskLevel] (single-scan concern bands).
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_sim_swap_self_report.dart';

enum ScamAttackStage {
  contact,
  impersonation,
  informationHarvesting,
  credentialHarvesting,
  otpHarvesting,
  simSwapRisk,
  accountTakeoverRisk,
  financialAction,
  suspectedCompromise,
  incidentResponse,
}

enum ScamImpersonationCategory {
  government,
  bank,
  telecom,
  deliveryCompany,
  employer,
  other,
}

/// Step A — data the user reports sharing (categories only, never raw values).
enum ScamSharedDataCategory {
  qid,
  passport,
  drivingLicence,
  otp,
  bankDetails,
  cardDetails,
  password,
  phoneConfirmation,
  simEsimInfo,
  other,
}

/// Step B — reported outcomes after the contact.
enum ScamIncidentOutcome {
  nothingYet,
  simPhoneStopped,
  unexpectedOtp,
  passwordChanged,
  unknownTransaction,
  moneyTransferred,
  cardCharged,
  accountLocked,
}

enum ScamCompoundRiskBand { low, medium, high, critical }

enum ScamIncidentResponseLevel {
  level1,
  level2,
  level3,
  level4,
  level5,
}

enum ScamShieldHistoryEntryKind { scan, incident, simSwap, proactiveCall }

/// Step C — how the user was contacted.
enum ScamContactChannel {
  phoneCall,
  sms,
  whatsApp,
  email,
  socialMedia,
  website,
  qrCode,
  inPerson,
  messagingApp,
  other,
}

/// Step D — when the incident occurred.
enum ScamIncidentTiming {
  justNow,
  within1Hour,
  today,
  yesterday,
  within7Days,
  moreThan7Days,
  unknown,
}

enum ScamChainConfidenceBand { low, moderate, high }

/// Response urgency — separate from [ScamAttackStage] progression.
enum ScamResponsePriority {
  observe,
  protect,
  secure,
  urgent,
  emergency,
}

/// How strongly an exposure/event is supported.
enum ScamEvidenceStatus {
  reportedByUser,
  observed,
  suspected,
  verified,
  unknown,
}

class ScamIncidentInput {
  const ScamIncidentInput({
    this.impersonationCategory = ScamImpersonationCategory.other,
    this.contactChannels = const {},
    this.timing = ScamIncidentTiming.unknown,
    this.occurredAt,
    this.sharedData = const {},
    this.outcomes = const {},
    this.freeTextNotes,
    this.evidenceStatus = ScamEvidenceStatus.reportedByUser,
    this.simSelfReportAnswers,
  });

  final ScamImpersonationCategory impersonationCategory;
  final Set<ScamContactChannel> contactChannels;
  final ScamIncidentTiming timing;
  final DateTime? occurredAt;
  final Set<ScamSharedDataCategory> sharedData;
  final Set<ScamIncidentOutcome> outcomes;
  final String? freeTextNotes;
  final ScamEvidenceStatus evidenceStatus;

  /// Optional SIM/eSIM self-report answers when collected in Incident Response.
  final SimSwapSelfReportAnswers? simSelfReportAnswers;
}

class ScamCompoundRiskResult {
  const ScamCompoundRiskResult({
    required this.band,
    required this.multiplier,
    required this.reasonKeys,
  });

  final ScamCompoundRiskBand band;
  final double multiplier;
  final List<String> reasonKeys;
}

class ScamIncidentAssessmentResult {
  const ScamIncidentAssessmentResult({
    required this.stage,
    required this.responsePriority,
    required this.responseLevel,
    required this.compoundRisk,
    required this.checklistActionKeys,
    required this.stageSummaryKeys,
    required this.chainConfidence,
    required this.confidenceBand,
    this.evidenceStatus = ScamEvidenceStatus.reportedByUser,
    this.safeVerificationKeys = const [],
    this.chainNarrative,
    this.incidentGroupId,
  });

  final ScamAttackStage stage;
  final ScamResponsePriority responsePriority;
  final ScamIncidentResponseLevel responseLevel;
  final ScamCompoundRiskResult compoundRisk;
  final List<String> checklistActionKeys;
  final List<String> stageSummaryKeys;
  final double chainConfidence;
  final ScamChainConfidenceBand confidenceBand;
  final ScamEvidenceStatus evidenceStatus;
  final List<String> safeVerificationKeys;
  final String? chainNarrative;
  final String? incidentGroupId;

  ScamShieldRiskLevel get displaySeverity => _displaySeverityForStage(stage);

  static ScamShieldRiskLevel _displaySeverityForStage(ScamAttackStage stage) {
    return switch (stage) {
      ScamAttackStage.contact || ScamAttackStage.impersonation => ScamShieldRiskLevel.low,
      ScamAttackStage.informationHarvesting => ScamShieldRiskLevel.medium,
      ScamAttackStage.credentialHarvesting ||
      ScamAttackStage.otpHarvesting =>
        ScamShieldRiskLevel.high,
      ScamAttackStage.simSwapRisk ||
      ScamAttackStage.accountTakeoverRisk ||
      ScamAttackStage.financialAction ||
      ScamAttackStage.suspectedCompromise ||
      ScamAttackStage.incidentResponse =>
        ScamShieldRiskLevel.high,
    };
  }
}


extension ScamAttackStageX on ScamAttackStage {
  int get rank => ScamAttackStage.values.indexOf(this);

  static ScamAttackStage highest(Iterable<ScamAttackStage> stages) {
    return stages.reduce(
      (a, b) => a.rank >= b.rank ? a : b,
    );
  }
}

extension ScamIncidentResponseLevelX on ScamIncidentResponseLevel {
  int get rank => ScamIncidentResponseLevel.values.indexOf(this);

  String get labelKey => switch (this) {
        ScamIncidentResponseLevel.level1 => 'ss_ir_level_1',
        ScamIncidentResponseLevel.level2 => 'ss_ir_level_2',
        ScamIncidentResponseLevel.level3 => 'ss_ir_level_3',
        ScamIncidentResponseLevel.level4 => 'ss_ir_level_4',
        ScamIncidentResponseLevel.level5 => 'ss_ir_level_5',
      };
}

extension ScamResponsePriorityX on ScamResponsePriority {
  int get rank => ScamResponsePriority.values.indexOf(this);

  String get labelKey => switch (this) {
        ScamResponsePriority.observe => 'ss_priority_observe',
        ScamResponsePriority.protect => 'ss_priority_protect',
        ScamResponsePriority.secure => 'ss_priority_secure',
        ScamResponsePriority.urgent => 'ss_priority_urgent',
        ScamResponsePriority.emergency => 'ss_priority_emergency',
      };
}

extension ScamChainConfidenceBandX on ScamChainConfidenceBand {
  String get labelKey => switch (this) {
        ScamChainConfidenceBand.low => 'ss_chain_confidence_low',
        ScamChainConfidenceBand.moderate => 'ss_chain_confidence_moderate',
        ScamChainConfidenceBand.high => 'ss_chain_confidence_high',
      };
}
