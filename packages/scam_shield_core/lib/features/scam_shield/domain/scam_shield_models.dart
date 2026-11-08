import 'package:scam_shield_core/features/scam_shield/domain/scam_conversation_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_input_channel_parser.dart';
import 'package:scam_shield_core/features/scam_shield/scam_shield_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_scan_risk_engine.dart';

/// User-selected content category for the pasted message.
enum ScamShieldContentType {
  whatsAppSms,
  email,
  websiteUrl,
  paymentRequest,
  jobOffer,
  rentalOffer,
  investmentOffer,
}

enum ScamShieldRiskLevel { low, medium, high }

enum ScamShieldLocalSignal { low, medium, high }

class ScamShieldUrlFinding {
  const ScamShieldUrlFinding({
    required this.url,
    required this.domain,
    required this.isKnownLegitimate,
    required this.flags,
    this.webRiskChecked = false,
    this.webRiskFlagged = false,
    this.webRiskThreatTypes = const [],
    this.webRiskUnavailable = false,
  });

  final String url;
  final String domain;

  /// Exact allowlist match only — not proof of legitimacy.
  final bool isKnownLegitimate;
  final List<String> flags;
  final bool webRiskChecked;
  final bool webRiskFlagged;
  final List<String> webRiskThreatTypes;
  final bool webRiskUnavailable;

  ScamShieldUrlFinding copyWith({
    List<String>? flags,
    bool? webRiskChecked,
    bool? webRiskFlagged,
    List<String>? webRiskThreatTypes,
    bool? webRiskUnavailable,
  }) {
    return ScamShieldUrlFinding(
      url: url,
      domain: domain,
      isKnownLegitimate: isKnownLegitimate,
      flags: flags ?? this.flags,
      webRiskChecked: webRiskChecked ?? this.webRiskChecked,
      webRiskFlagged: webRiskFlagged ?? this.webRiskFlagged,
      webRiskThreatTypes: webRiskThreatTypes ?? this.webRiskThreatTypes,
      webRiskUnavailable: webRiskUnavailable ?? this.webRiskUnavailable,
    );
  }
}

class ScamShieldLocalCheckResult {
  const ScamShieldLocalCheckResult({
    required this.signal,
    required this.redFlags,
    required this.urlFindings,
    required this.flagCount,
  });

  final ScamShieldLocalSignal signal;
  final List<String> redFlags;
  final List<ScamShieldUrlFinding> urlFindings;
  final int flagCount;
}

class ScamShieldAiAssessment {
  const ScamShieldAiAssessment({
    required this.riskLevel,
    required this.redFlags,
    required this.requestedInfo,
    required this.impersonationType,
  });

  final ScamShieldRiskLevel riskLevel;
  final List<String> redFlags;
  final List<String> requestedInfo;
  final String? impersonationType;
}

/// Supplementary AI read — never changes deterministic [overallRisk].
class ScamShieldAiSupplementary {
  const ScamShieldAiSupplementary({
    required this.assessment,
    required this.differsFromDeterministic,
  });

  final ScamShieldAiAssessment assessment;
  final bool differsFromDeterministic;
}

class ScamShieldAssessmentResult {
  const ScamShieldAssessmentResult({
    required this.contentType,
    required this.overallRisk,
    required this.localCheck,
    required this.redFlags,
    required this.requestedInfo,
    required this.urlFindings,
    required this.usedAi,
    required this.verificationChannelKeys,
    required this.scanAnalysis,
    this.inputChannel,
    this.impersonationType,
    this.aiCapReached = false,
    this.aiSupplementary,
    this.conversationContext,
  });

  final ScamShieldContentType contentType;
  final ScamShieldRiskLevel overallRisk;
  final ScamShieldLocalCheckResult localCheck;
  final List<String> redFlags;
  final List<String> requestedInfo;
  final List<ScamShieldUrlFinding> urlFindings;
  final bool usedAi;
  final List<String> verificationChannelKeys;
  final ScamScanRiskAnalysis scanAnalysis;
  final ScamShieldInputChannel? inputChannel;
  final String? impersonationType;
  final bool aiCapReached;
  final ScamShieldAiSupplementary? aiSupplementary;
  final ScamConversationContext? conversationContext;
}

extension ScamShieldContentTypeX on ScamShieldContentType {
  bool get requiresAiReview =>
      ScamShieldConfig.aiRequiredContentTypes.contains(this);

  String get labelKey => switch (this) {
        ScamShieldContentType.whatsAppSms => 'ss_type_whatsapp',
        ScamShieldContentType.email => 'ss_type_email',
        ScamShieldContentType.websiteUrl => 'ss_type_website',
        ScamShieldContentType.paymentRequest => 'ss_type_payment',
        ScamShieldContentType.jobOffer => 'ss_type_job',
        ScamShieldContentType.rentalOffer => 'ss_type_rental',
        ScamShieldContentType.investmentOffer => 'ss_type_investment',
      };
}

extension ScamShieldRiskLevelX on ScamShieldRiskLevel {
  int get severityRank => switch (this) {
        ScamShieldRiskLevel.low => 0,
        ScamShieldRiskLevel.medium => 1,
        ScamShieldRiskLevel.high => 2,
      };

  static ScamShieldRiskLevel max(
    ScamShieldRiskLevel a,
    ScamShieldRiskLevel b,
  ) {
    return a.severityRank >= b.severityRank ? a : b;
  }

  static ScamShieldRiskLevel fromLocalSignal(ScamShieldLocalSignal signal) {
    return switch (signal) {
      ScamShieldLocalSignal.low => ScamShieldRiskLevel.low,
      ScamShieldLocalSignal.medium => ScamShieldRiskLevel.medium,
      ScamShieldLocalSignal.high => ScamShieldRiskLevel.high,
    };
  }
}

extension ScamShieldLocalSignalX on ScamShieldLocalSignal {
  static ScamShieldLocalSignal fromFlagCount(int count) {
    if (count <= 0) return ScamShieldLocalSignal.low;
    if (count <= 2) return ScamShieldLocalSignal.medium;
    return ScamShieldLocalSignal.high;
  }
}
