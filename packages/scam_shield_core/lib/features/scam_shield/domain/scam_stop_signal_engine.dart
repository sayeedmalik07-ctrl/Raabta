import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';

class ScamStopSignalResult {
  const ScamStopSignalResult({
    required this.triggered,
    required this.triggerSignals,
    this.headlineKey = 'ss_stop_headline',
    this.explanationKey,
  });

  final bool triggered;
  final List<ScamRiskSignal> triggerSignals;
  final String headlineKey;
  final String? explanationKey;
}

/// Hard-stop interrupt on high-danger signal combinations.
abstract final class ScamStopSignalEngine {
  static const _hardStopSignals = {
    ScamRiskSignal.otpRequest,
    ScamRiskSignal.pinRequest,
    ScamRiskSignal.cvvRequest,
    ScamRiskSignal.passwordRequest,
    ScamRiskSignal.remoteAccessRequest,
    ScamRiskSignal.screenShareRequest,
    ScamRiskSignal.simChange,
    ScamRiskSignal.esimChange,
    ScamRiskSignal.arrestThreat,
    ScamRiskSignal.accountLockThreat,
  };

  static ScamStopSignalResult evaluate(Set<ScamRiskSignal> signals) {
    final triggers = <ScamRiskSignal>[];

    for (final signal in _hardStopSignals) {
      if (signals.contains(signal)) triggers.add(signal);
    }

    final hasAuthority = signals.contains(ScamRiskSignal.authorityImpersonation);
    final hasFinancial = signals.contains(ScamRiskSignal.financialImpersonation);
    if (signals.contains(ScamRiskSignal.cashWithdrawalRequest) &&
        (hasAuthority || hasFinancial)) {
      triggers.add(ScamRiskSignal.cashWithdrawalRequest);
    }

    if (triggers.isEmpty) {
      return const ScamStopSignalResult(triggered: false, triggerSignals: []);
    }

    return ScamStopSignalResult(
      triggered: true,
      triggerSignals: triggers,
      explanationKey: _explanationKeyFor(triggers, hasAuthority, hasFinancial),
    );
  }

  static String _explanationKeyFor(
    List<ScamRiskSignal> triggers,
    bool hasAuthority,
    bool hasFinancial,
  ) {
    if (triggers.contains(ScamRiskSignal.otpRequest) && hasAuthority) {
      return 'ss_stop_explain_otp_authority';
    }
    if (triggers.contains(ScamRiskSignal.otpRequest)) {
      return 'ss_stop_explain_otp';
    }
    if (triggers.contains(ScamRiskSignal.cvvRequest) ||
        triggers.contains(ScamRiskSignal.pinRequest)) {
      return 'ss_stop_explain_card_credential';
    }
    if (triggers.contains(ScamRiskSignal.remoteAccessRequest) ||
        triggers.contains(ScamRiskSignal.screenShareRequest)) {
      return 'ss_stop_explain_remote_access';
    }
    if (triggers.contains(ScamRiskSignal.simChange) ||
        triggers.contains(ScamRiskSignal.esimChange)) {
      return 'ss_stop_explain_sim';
    }
    if (triggers.contains(ScamRiskSignal.cashWithdrawalRequest)) {
      return 'ss_stop_explain_cash_withdrawal';
    }
    if (triggers.contains(ScamRiskSignal.arrestThreat)) {
      return 'ss_stop_explain_arrest';
    }
    if (triggers.contains(ScamRiskSignal.accountLockThreat)) {
      return 'ss_stop_explain_account_lock';
    }
    if (triggers.contains(ScamRiskSignal.passwordRequest)) {
      return 'ss_stop_explain_password';
    }
    return 'ss_stop_explain_generic';
  }
}
