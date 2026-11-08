import 'package:scam_shield_core/features/scam_shield/data/scam_signal_weights_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';

enum ScamSocialEngineeringBand { low, moderate, high, critical }

class ScamSocialEngineeringScore {
  const ScamSocialEngineeringScore({
    required this.authority,
    required this.urgency,
    required this.fear,
    required this.secrecy,
    required this.financialPressure,
    required this.identityHarvesting,
    required this.technicalManipulation,
    required this.verificationAvoidance,
    required this.totalScore,
    required this.band,
  });

  final double authority;
  final double urgency;
  final double fear;
  final double secrecy;
  final double financialPressure;
  final double identityHarvesting;
  final double technicalManipulation;
  final double verificationAvoidance;
  final double totalScore;
  final ScamSocialEngineeringBand band;
}

abstract final class ScamSocialEngineeringScorer {
  static ScamSocialEngineeringScore score(Set<ScamRiskSignal> signals) {
    double authority = 0;
    double urgency = 0;
    double fear = 0;
    double secrecy = 0;
    double financial = 0;
    double identity = 0;
    double technical = 0;
    double verification = 0;

    for (final signal in signals) {
      final w = ScamSignalWeightsConfig.weightFor(signal);
      switch (signal) {
        case ScamRiskSignal.authorityImpersonation:
        case ScamRiskSignal.financialImpersonation:
        case ScamRiskSignal.telecomImpersonation:
          authority += w;
        case ScamRiskSignal.urgency:
          urgency += w;
        case ScamRiskSignal.threat:
        case ScamRiskSignal.arrestThreat:
        case ScamRiskSignal.accountLockThreat:
          fear += w;
        case ScamRiskSignal.secrecyRequest:
          secrecy += w;
        case ScamRiskSignal.paymentRequest:
        case ScamRiskSignal.transferRequest:
        case ScamRiskSignal.cashWithdrawalRequest:
        case ScamRiskSignal.giftCardRequest:
        case ScamRiskSignal.cryptoRequest:
          financial += w;
        case ScamRiskSignal.otpRequest:
        case ScamRiskSignal.pinRequest:
        case ScamRiskSignal.passwordRequest:
        case ScamRiskSignal.qidRequest:
        case ScamRiskSignal.passportRequest:
        case ScamRiskSignal.cardRequest:
        case ScamRiskSignal.cvvRequest:
          identity += w;
        case ScamRiskSignal.remoteAccessRequest:
        case ScamRiskSignal.screenShareRequest:
        case ScamRiskSignal.unknownAppRequest:
        case ScamRiskSignal.simChange:
        case ScamRiskSignal.esimChange:
        case ScamRiskSignal.numberPortRequest:
          technical += w;
        case ScamRiskSignal.antiVerificationInstruction:
        case ScamRiskSignal.callerIdDependency:
          verification += w;
        case ScamRiskSignal.passwordReset:
        case ScamRiskSignal.emailChange:
        case ScamRiskSignal.bankChange:
          identity += w * 0.6;
          technical += w * 0.4;
        case ScamRiskSignal.unexpectedLink:
        case ScamRiskSignal.lookalikeDomain:
          technical += w;
        case ScamRiskSignal.conversationUrgencyEscalation:
          urgency += w;
        case ScamRiskSignal.conversationRapportThenAsk:
          secrecy += w * 0.5;
          financial += w * 0.5;
        case ScamRiskSignal.conversationTopicShift:
          financial += w;
      }
    }

    final total = authority +
        urgency +
        fear +
        secrecy +
        financial +
        identity +
        technical +
        verification;

    return ScamSocialEngineeringScore(
      authority: authority,
      urgency: urgency,
      fear: fear,
      secrecy: secrecy,
      financialPressure: financial,
      identityHarvesting: identity,
      technicalManipulation: technical,
      verificationAvoidance: verification,
      totalScore: total,
      band: _bandForTotal(total, signals),
    );
  }

  static ScamSocialEngineeringBand _bandForTotal(
    double total,
    Set<ScamRiskSignal> signals,
  ) {
    if (signals.contains(ScamRiskSignal.otpRequest) ||
        signals.contains(ScamRiskSignal.cvvRequest) ||
        signals.contains(ScamRiskSignal.pinRequest)) {
      return ScamSocialEngineeringBand.critical;
    }
    if (total >= 55) return ScamSocialEngineeringBand.critical;
    if (total >= 32) return ScamSocialEngineeringBand.high;
    if (total >= 14) return ScamSocialEngineeringBand.moderate;
    return ScamSocialEngineeringBand.low;
  }
}

extension ScamSocialEngineeringBandX on ScamSocialEngineeringBand {
  String get labelKey => switch (this) {
        ScamSocialEngineeringBand.low => 'ss_se_band_low',
        ScamSocialEngineeringBand.moderate => 'ss_se_band_moderate',
        ScamSocialEngineeringBand.high => 'ss_se_band_high',
        ScamSocialEngineeringBand.critical => 'ss_se_band_critical',
      };
}
