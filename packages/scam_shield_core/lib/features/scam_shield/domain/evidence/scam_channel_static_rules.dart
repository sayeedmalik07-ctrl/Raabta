/// Static sender/channel rules with published source labels (no invented law).
abstract final class ScamChannelStaticRules {
  static const otpPinSourceLabel = 'Doha Bank fraud awareness campaign';
  static const otpPinSourceUrl =
      'https://www.dohabank.com.qa/fraud-awareness-campaign/';

  static const govWhatsAppRuleKey = 'ss_evidence_rule_gov_whatsapp';
  static const otpPinRuleKey = 'ss_evidence_rule_otp_pin';
  static const senderCaveatKey = 'ss_evidence_sender_caveat';
}
