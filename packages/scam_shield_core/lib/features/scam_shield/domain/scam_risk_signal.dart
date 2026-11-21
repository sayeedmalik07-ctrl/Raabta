/// Granular deterministic risk signals for ScamShield Phase 2.
enum ScamRiskSignal {
  authorityImpersonation,
  financialImpersonation,
  telecomImpersonation,
  urgency,
  threat,
  arrestThreat,
  accountLockThreat,
  otpRequest,
  pinRequest,
  passwordRequest,
  qidRequest,
  passportRequest,
  cardRequest,
  cvvRequest,
  remoteAccessRequest,
  screenShareRequest,
  unknownAppRequest,
  paymentRequest,
  transferRequest,
  cashWithdrawalRequest,
  giftCardRequest,
  cryptoRequest,
  simChange,
  esimChange,
  numberPortRequest,
  passwordReset,
  emailChange,
  bankChange,
  unexpectedLink,
  lookalikeDomain,
  callerIdDependency,
  secrecyRequest,
  antiVerificationInstruction,
  conversationUrgencyEscalation,
  conversationRapportThenAsk,
  conversationTopicShift,
}

extension ScamRiskSignalX on ScamRiskSignal {
  String get labelKey => 'ss_signal_${name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      ).replaceFirst('_', '')}';

  /// Maps legacy local-checker flag keys to Phase 2 signals.
  static List<ScamRiskSignal> fromLegacyFlag(String flagKey) {
    return switch (flagKey) {
      'ss_flag_otp' => [
          ScamRiskSignal.otpRequest,
          ScamRiskSignal.pinRequest,
          ScamRiskSignal.passwordRequest,
          ScamRiskSignal.cvvRequest,
        ],
      'ss_flag_urgency' => [ScamRiskSignal.urgency, ScamRiskSignal.accountLockThreat],
      'ss_flag_unusual_payment' => [
          ScamRiskSignal.giftCardRequest,
          ScamRiskSignal.cryptoRequest,
          ScamRiskSignal.paymentRequest,
        ],
      'ss_flag_upfront_fee' => [ScamRiskSignal.paymentRequest, ScamRiskSignal.transferRequest],
      'ss_flag_impersonation' => [
          ScamRiskSignal.authorityImpersonation,
          ScamRiskSignal.financialImpersonation,
        ],
      'ss_flag_lookalike_domain' => [ScamRiskSignal.lookalikeDomain],
      'ss_flag_url_shortener' => [ScamRiskSignal.unexpectedLink],
      'ss_flag_ip_url' => [ScamRiskSignal.unexpectedLink],
      'ss_flag_suspicious_subdomain' => [ScamRiskSignal.lookalikeDomain],
      'ss_flag_nonstandard_gov_tld' => [ScamRiskSignal.lookalikeDomain],
      'ss_flag_sideload_app' => [ScamRiskSignal.unexpectedLink],
      'ss_flag_escalation_urgency' => [ScamRiskSignal.conversationUrgencyEscalation],
      'ss_flag_escalation_rapport_ask' => [ScamRiskSignal.conversationRapportThenAsk],
      'ss_flag_escalation_topic_shift' => [ScamRiskSignal.conversationTopicShift],
      'ss_flag_money_mule' => [
          ScamRiskSignal.transferRequest,
          ScamRiskSignal.paymentRequest,
        ],
      'ss_flag_sender_channel_mismatch' => [
          ScamRiskSignal.antiVerificationInstruction,
        ],
      'ss_flag_platform_hop' => [
          ScamRiskSignal.secrecyRequest,
          ScamRiskSignal.antiVerificationInstruction,
        ],
      _ => const [],
    };
  }
}
