import 'package:scam_shield_core/features/scam_shield/domain/qatar_iban_validator.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';

/// In-memory only — never persisted (Phase 12 route prefill).
class PaymentCheckPrefill {
  const PaymentCheckPrefill({
    this.context,
    this.ibanCandidates = const [],
    this.phoneCandidates = const [],
    this.linkCandidates = const [],
    this.requestedMethods = const [],
    /// User-declared only — not detected from call state (Phase 24).
    this.onCall = false,
  });

  final PaymentCheckContext? context;
  final List<String> ibanCandidates;
  final List<String> phoneCandidates;
  final List<String> linkCandidates;
  final List<PaymentRequestedMethod> requestedMethods;
  final bool onCall;
}

enum PaymentCheckContext {
  rentDeposit,
  jobVisaFee,
  buyingFromListing,
  investment,
  governmentFee,
  prizeRefund,
  friendFamilyEmergency,
  other,
}

enum PaymentRequestedMethod {
  giftCards,
  crypto,
  personalAccount,
  refundableDepositBeforeViewing,
  urgencyThreats,
  keepSecret,
  moveToWhatsAppTelegram,
}

enum PaymentCheckRiskBand { clear, elevated, high }

class PaymentCheckInput {
  const PaymentCheckInput({
    this.context,
    this.iban = '',
    this.phone = '',
    this.link = '',
    this.requestedMethods = const {},
  });

  final PaymentCheckContext? context;
  final String iban;
  final String phone;
  final String link;
  final Set<PaymentRequestedMethod> requestedMethods;
}

class PaymentCheckResult {
  const PaymentCheckResult({
    required this.band,
    required this.concernKeys,
    required this.contextPromptKeys,
    required this.reusedVerifyKeys,
    required this.urlFindings,
    required this.showNameCoaching,
    required this.riskLevel,
    this.ibanValidation,
  });

  final PaymentCheckRiskBand band;
  final List<String> concernKeys;
  final List<String> contextPromptKeys;
  final List<String> reusedVerifyKeys;
  final List<ScamShieldUrlFinding> urlFindings;
  final bool showNameCoaching;
  final ScamShieldRiskLevel riskLevel;
  final IbanValidationResult? ibanValidation;
}

extension PaymentCheckContextX on PaymentCheckContext {
  String get labelKey => switch (this) {
        PaymentCheckContext.rentDeposit => 'ss_pay_ctx_rent',
        PaymentCheckContext.jobVisaFee => 'ss_pay_ctx_job',
        PaymentCheckContext.buyingFromListing => 'ss_pay_ctx_listing',
        PaymentCheckContext.investment => 'ss_pay_ctx_investment',
        PaymentCheckContext.governmentFee => 'ss_pay_ctx_gov',
        PaymentCheckContext.prizeRefund => 'ss_pay_ctx_prize',
        PaymentCheckContext.friendFamilyEmergency => 'ss_pay_ctx_friend',
        PaymentCheckContext.other => 'ss_pay_ctx_other',
      };

  bool get expectsLocalFormalPayee => switch (this) {
        PaymentCheckContext.rentDeposit ||
        PaymentCheckContext.jobVisaFee ||
        PaymentCheckContext.buyingFromListing ||
        PaymentCheckContext.investment ||
        PaymentCheckContext.governmentFee =>
          true,
        _ => false,
      };
}

extension PaymentRequestedMethodX on PaymentRequestedMethod {
  String get labelKey => switch (this) {
        PaymentRequestedMethod.giftCards => 'ss_pay_method_gift_cards',
        PaymentRequestedMethod.crypto => 'ss_pay_method_crypto',
        PaymentRequestedMethod.personalAccount => 'ss_pay_method_personal',
        PaymentRequestedMethod.refundableDepositBeforeViewing =>
          'ss_pay_method_deposit_before_viewing',
        PaymentRequestedMethod.urgencyThreats => 'ss_pay_method_urgency',
        PaymentRequestedMethod.keepSecret => 'ss_pay_method_secret',
        PaymentRequestedMethod.moveToWhatsAppTelegram => 'ss_pay_method_platform_hop',
      };

  bool get isPressureSignal => switch (this) {
        PaymentRequestedMethod.giftCards ||
        PaymentRequestedMethod.crypto ||
        PaymentRequestedMethod.refundableDepositBeforeViewing ||
        PaymentRequestedMethod.urgencyThreats ||
        PaymentRequestedMethod.keepSecret ||
        PaymentRequestedMethod.moveToWhatsAppTelegram =>
          true,
        PaymentRequestedMethod.personalAccount => false,
      };
}
