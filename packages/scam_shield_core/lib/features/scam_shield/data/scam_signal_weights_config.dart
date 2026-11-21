import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';

/// Versioned signal weights — tune without rebuilding business logic.
abstract final class ScamSignalWeightsConfig {
  static const version = 1;

  static const weights = <ScamRiskSignal, double>{
    ScamRiskSignal.authorityImpersonation: 18,
    ScamRiskSignal.financialImpersonation: 18,
    ScamRiskSignal.telecomImpersonation: 16,
    ScamRiskSignal.urgency: 10,
    ScamRiskSignal.threat: 14,
    ScamRiskSignal.arrestThreat: 22,
    ScamRiskSignal.accountLockThreat: 16,
    ScamRiskSignal.otpRequest: 28,
    ScamRiskSignal.pinRequest: 28,
    ScamRiskSignal.passwordRequest: 26,
    ScamRiskSignal.qidRequest: 14,
    ScamRiskSignal.passportRequest: 14,
    ScamRiskSignal.cardRequest: 20,
    ScamRiskSignal.cvvRequest: 28,
    ScamRiskSignal.remoteAccessRequest: 26,
    ScamRiskSignal.screenShareRequest: 24,
    ScamRiskSignal.unknownAppRequest: 18,
    ScamRiskSignal.paymentRequest: 12,
    ScamRiskSignal.transferRequest: 14,
    ScamRiskSignal.cashWithdrawalRequest: 20,
    ScamRiskSignal.giftCardRequest: 16,
    ScamRiskSignal.cryptoRequest: 16,
    ScamRiskSignal.simChange: 24,
    ScamRiskSignal.esimChange: 24,
    ScamRiskSignal.numberPortRequest: 22,
    ScamRiskSignal.passwordReset: 14,
    ScamRiskSignal.emailChange: 12,
    ScamRiskSignal.bankChange: 14,
    ScamRiskSignal.unexpectedLink: 10,
    ScamRiskSignal.lookalikeDomain: 14,
    ScamRiskSignal.callerIdDependency: 8,
    ScamRiskSignal.secrecyRequest: 12,
    ScamRiskSignal.antiVerificationInstruction: 16,
    ScamRiskSignal.conversationUrgencyEscalation: 12,
    ScamRiskSignal.conversationRapportThenAsk: 14,
    ScamRiskSignal.conversationTopicShift: 10,
  };

  static double weightFor(ScamRiskSignal signal) =>
      weights[signal] ?? 0;
}
