import 'package:scam_shield_core/features/scam_shield/domain/scam_incident_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_sim_swap_self_report.dart';

/// Qatar mobile operators — deep-link guidance only (no live API in Phase 3).
enum ScamQatarTelecomProvider {
  ooredoo,
  vodafone,
  unknown,
}

/// Structured SIM/eSIM swap indicators reported by the user.
enum SimSwapSymptom {
  noSignal,
  unexpectedOtp,
  simChangeDiscussed,
  esimChangeDiscussed,
  numberPortDiscussed,
  cannotReceiveSms,
  telecomImpersonationCall,
  accountLoginIssues,
  financialActivityAfterSignalLoss,
}

enum SimSwapRiskBand {
  low,
  moderate,
  high,
  critical,
}

extension SimSwapRiskBandX on SimSwapRiskBand {
  String get labelKey => switch (this) {
        SimSwapRiskBand.low => 'ss_sim_band_low',
        SimSwapRiskBand.moderate => 'ss_sim_band_moderate',
        SimSwapRiskBand.high => 'ss_sim_band_high',
        SimSwapRiskBand.critical => 'ss_sim_band_critical',
      };

  ScamShieldRiskLevel get displaySeverity => switch (this) {
        SimSwapRiskBand.low => ScamShieldRiskLevel.low,
        SimSwapRiskBand.moderate => ScamShieldRiskLevel.medium,
        SimSwapRiskBand.high || SimSwapRiskBand.critical =>
          ScamShieldRiskLevel.high,
      };
}

extension SimSwapSymptomX on SimSwapSymptom {
  String get labelKey => 'ss_sim_symptom_${name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      )}';
}

extension ScamQatarTelecomProviderX on ScamQatarTelecomProvider {
  String get labelKey => switch (this) {
        ScamQatarTelecomProvider.ooredoo => 'ss_sim_provider_ooredoo',
        ScamQatarTelecomProvider.vodafone => 'ss_sim_provider_vodafone',
        ScamQatarTelecomProvider.unknown => 'ss_sim_provider_unknown',
      };
}

class SimSwapAnalyzerInput {
  const SimSwapAnalyzerInput({
    this.provider = ScamQatarTelecomProvider.unknown,
    this.symptoms = const {},
    this.notes,
    this.yesAnswerCount = 0,
    this.selfReportAnswers,
  });

  final ScamQatarTelecomProvider provider;
  final Set<SimSwapSymptom> symptoms;
  final String? notes;
  final int yesAnswerCount;
  final SimSwapSelfReportAnswers? selfReportAnswers;
}

class ScamTelecomChannel {
  const ScamTelecomChannel({
    required this.labelKey,
    this.url,
    this.phoneNumber,
    this.detailKey,
  }) : assert(
          url != null || phoneNumber != null,
          'Channel needs a url and/or phoneNumber',
        );

  final String labelKey;
  final String? url;
  final String? phoneNumber;
  final String? detailKey;
}

class SimSwapAnalyzerResult {
  const SimSwapAnalyzerResult({
    required this.band,
    required this.attackStage,
    required this.responseLevel,
    required this.matchedSymptoms,
    required this.actionKeys,
    required this.telecomChannels,
    required this.textSignals,
    required this.suggestIncidentMode,
    required this.selfReportUrgency,
    this.selfReportAnswers,
    this.yesAnswerCount = 0,
  });

  final SimSwapRiskBand band;
  final ScamAttackStage attackStage;
  final ScamIncidentResponseLevel responseLevel;
  final Set<SimSwapSymptom> matchedSymptoms;
  final List<String> actionKeys;
  final List<ScamTelecomChannel> telecomChannels;
  final Set<ScamRiskSignal> textSignals;
  final bool suggestIncidentMode;
  final SimSwapSelfReportUrgency selfReportUrgency;
  final SimSwapSelfReportAnswers? selfReportAnswers;
  final int yesAnswerCount;
}
