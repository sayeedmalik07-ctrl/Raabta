import 'package:scam_shield_core/features/scam_shield/domain/scam_authority_matcher.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_incident_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_social_engineering_scorer.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_stop_signal_engine.dart';

/// Trust-but-verify labels — [verified] only via Phase 4 authority directory.
enum ScamTrustLabel {
  verified,
  likelySafe,
  needsVerification,
  highRisk,
  critical,
}

extension ScamTrustLabelX on ScamTrustLabel {
  String get labelKey => switch (this) {
        ScamTrustLabel.verified => 'ss_trust_verified',
        ScamTrustLabel.likelySafe => 'ss_trust_likely_safe',
        ScamTrustLabel.needsVerification => 'ss_trust_needs_verification',
        ScamTrustLabel.highRisk => 'ss_trust_high_risk',
        ScamTrustLabel.critical => 'ss_trust_critical',
      };

  ScamShieldRiskLevel get displayRisk => switch (this) {
        ScamTrustLabel.verified || ScamTrustLabel.likelySafe =>
          ScamShieldRiskLevel.low,
        ScamTrustLabel.needsVerification => ScamShieldRiskLevel.medium,
        ScamTrustLabel.highRisk => ScamShieldRiskLevel.high,
        ScamTrustLabel.critical => ScamShieldRiskLevel.high,
      };

  String get confidenceBandKey => switch (this) {
        ScamTrustLabel.verified => 'ss_confidence_verified_channel',
        ScamTrustLabel.likelySafe => 'ss_confidence_low',
        ScamTrustLabel.needsVerification => 'ss_confidence_moderate',
        ScamTrustLabel.highRisk => 'ss_confidence_high',
        ScamTrustLabel.critical => 'ss_confidence_high',
      };
}

abstract final class ScamTrustLabelResolver {
  static ScamTrustLabel resolve({
    required ScamStopSignalResult stop,
    required ScamSocialEngineeringScore social,
    required Set<ScamRiskSignal> signals,
    required ScamAuthorityMatchResult authority,
  }) {
    if (stop.triggered) return ScamTrustLabel.critical;

    if (authority.kind == ScamAuthorityMatchKind.domainMismatch ||
        authority.kind == ScamAuthorityMatchKind.lookalikeDomain) {
      return ScamTrustLabel.highRisk;
    }

    if (authority.verifiedChannel) {
      return ScamTrustLabel.verified;
    }

    return switch (social.band) {
      ScamSocialEngineeringBand.critical => ScamTrustLabel.critical,
      ScamSocialEngineeringBand.high => ScamTrustLabel.highRisk,
      ScamSocialEngineeringBand.moderate => ScamTrustLabel.needsVerification,
      ScamSocialEngineeringBand.low =>
        signals.isEmpty ? ScamTrustLabel.likelySafe : ScamTrustLabel.needsVerification,
    };
  }
}

/// Aligns live-scan signals with Phase 1 attack-stage tracking.
abstract final class ScamSignalStageMapper {
  static ScamAttackStage stageFromSignals(Set<ScamRiskSignal> signals) {
    final stages = <ScamAttackStage>[];

    if (signals.any((s) => _impersonationSignals.contains(s))) {
      stages.add(ScamAttackStage.impersonation);
    }
    if (signals.any((s) => _identitySignals.contains(s))) {
      stages.add(ScamAttackStage.informationHarvesting);
    }
    if (signals.any((s) => _credentialSignals.contains(s))) {
      stages.add(ScamAttackStage.credentialHarvesting);
    }
    if (signals.contains(ScamRiskSignal.otpRequest) ||
        signals.contains(ScamRiskSignal.pinRequest)) {
      stages.add(ScamAttackStage.otpHarvesting);
    }
    if (signals.contains(ScamRiskSignal.simChange) ||
        signals.contains(ScamRiskSignal.esimChange) ||
        signals.contains(ScamRiskSignal.numberPortRequest)) {
      stages.add(ScamAttackStage.simSwapRisk);
    }
    if (signals.contains(ScamRiskSignal.passwordReset) ||
        signals.contains(ScamRiskSignal.passwordRequest)) {
      stages.add(ScamAttackStage.accountTakeoverRisk);
    }
    if (signals.any((s) => _financialSignals.contains(s))) {
      stages.add(ScamAttackStage.financialAction);
    }

    if (stages.isEmpty) return ScamAttackStage.contact;
    return ScamAttackStageX.highest(stages);
  }

  static const _impersonationSignals = {
    ScamRiskSignal.authorityImpersonation,
    ScamRiskSignal.financialImpersonation,
    ScamRiskSignal.telecomImpersonation,
  };

  static const _identitySignals = {
    ScamRiskSignal.qidRequest,
    ScamRiskSignal.passportRequest,
  };

  static const _credentialSignals = {
    ScamRiskSignal.passwordRequest,
    ScamRiskSignal.cardRequest,
    ScamRiskSignal.cvvRequest,
    ScamRiskSignal.bankChange,
  };

  static const _financialSignals = {
    ScamRiskSignal.paymentRequest,
    ScamRiskSignal.transferRequest,
    ScamRiskSignal.cashWithdrawalRequest,
    ScamRiskSignal.giftCardRequest,
    ScamRiskSignal.cryptoRequest,
  };
}
