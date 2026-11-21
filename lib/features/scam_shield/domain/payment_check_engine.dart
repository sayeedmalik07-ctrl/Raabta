import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';
import 'package:raabta/features/scam_shield/domain/qatar_iban_validator.dart';
import 'package:raabta/features/scam_shield/domain/qatar_phone_validator.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_local_checker.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Deterministic pre-payment checks — on-device only.
abstract final class PaymentCheckEngine {
  // Risk combination (first match wins, top → bottom):
  // high     = gift cards OR crypto requested
  //         OR 2+ pressure signals selected
  //         OR invalid IBAN checksum AND urgency/threats selected
  // elevated = personal-account method AND business-like payment context
  //         OR foreign (non-QA) IBAN with valid checksum
  //         OR move chat to WhatsApp/Telegram selected
  // clear    = otherwise (may still list informational concerns)

  static PaymentCheckResult evaluate(PaymentCheckInput input) {
    final concerns = <String>[];
    final contextPrompts = <String>[];
    final reusedVerify = <String>[];

    if (input.context != null) {
      contextPrompts.addAll(_contextPrompts(input.context!));
      reusedVerify.addAll(_reusedVerifyKeys(input.context!));
    }

    var showNameCoaching = false;
    IbanValidationResult? ibanResult;
    if (input.iban.trim().isNotEmpty) {
      ibanResult = QatarIbanValidator.validate(input.iban);
      showNameCoaching = ibanResult.isQatar ||
          ibanResult.kind == IbanValidationKind.qatarUnknownBankCode;
      concerns.addAll(_ibanConcernKeys(ibanResult));
    }

    if (input.phone.trim().isNotEmpty) {
      final phone = QatarPhoneValidator.validate(input.phone);
      concerns.addAll(
        _phoneConcernKeys(
          phone,
          context: input.context,
          methods: input.requestedMethods,
        ),
      );
    }

    final urlFindings = <ScamShieldUrlFinding>[];
    if (input.link.trim().isNotEmpty) {
      final local = ScamShieldLocalChecker.check(
        text: input.link,
        contentType: ScamShieldContentType.websiteUrl,
      );
      urlFindings.addAll(local.urlFindings);
      for (final f in local.urlFindings) {
        if (f.isKnownLegitimate) {
          concerns.add('ss_pay_concern_link_directory_match');
        }
        for (final flag in f.flags) {
          concerns.add(_urlFlagToConcern(flag));
        }
      }
      if (local.redFlags.contains('ss_flag_sideload_app')) {
        concerns.add('ss_pay_concern_sideload');
      }
    }

    for (final method in input.requestedMethods) {
      concerns.addAll(_methodConcernKeys(method));
    }

    if (input.requestedMethods.contains(PaymentRequestedMethod.personalAccount) &&
        input.context?.expectsLocalFormalPayee == true) {
      concerns.add('ss_pay_concern_personal_business_fawran');
    }

    final band = _resolveBand(
      input: input,
      ibanResult: ibanResult,
    );

    final riskLevel = switch (band) {
      PaymentCheckRiskBand.high => ScamShieldRiskLevel.high,
      PaymentCheckRiskBand.elevated => ScamShieldRiskLevel.medium,
      PaymentCheckRiskBand.clear => ScamShieldRiskLevel.low,
    };

    return PaymentCheckResult(
      band: band,
      concernKeys: concerns.toSet().toList(),
      contextPromptKeys: contextPrompts,
      reusedVerifyKeys: reusedVerify,
      urlFindings: urlFindings,
      showNameCoaching: showNameCoaching,
      riskLevel: riskLevel,
      ibanValidation: ibanResult,
    );
  }

  static PaymentCheckRiskBand _resolveBand({
    required PaymentCheckInput input,
    required IbanValidationResult? ibanResult,
  }) {
    final methods = input.requestedMethods;

    if (methods.contains(PaymentRequestedMethod.giftCards) ||
        methods.contains(PaymentRequestedMethod.crypto)) {
      return PaymentCheckRiskBand.high;
    }

    final pressureCount =
        methods.where((m) => m.isPressureSignal).length;
    if (pressureCount >= 2) return PaymentCheckRiskBand.high;

    if (ibanResult?.kind == IbanValidationKind.checksumFailed &&
        methods.contains(PaymentRequestedMethod.urgencyThreats)) {
      return PaymentCheckRiskBand.high;
    }

    if (methods.contains(PaymentRequestedMethod.personalAccount) &&
        input.context?.expectsLocalFormalPayee == true) {
      return PaymentCheckRiskBand.elevated;
    }

    if (ibanResult?.kind == IbanValidationKind.foreign) {
      return PaymentCheckRiskBand.elevated;
    }

    if (methods.contains(PaymentRequestedMethod.moveToWhatsAppTelegram)) {
      return PaymentCheckRiskBand.elevated;
    }

    return PaymentCheckRiskBand.clear;
  }

  static List<String> _contextPrompts(PaymentCheckContext ctx) {
    return switch (ctx) {
      PaymentCheckContext.rentDeposit => [
          'ss_pay_prompt_rent_1',
          'ss_pay_prompt_rent_2',
          'ss_pay_prompt_rent_3',
        ],
      PaymentCheckContext.jobVisaFee => [
          'ss_pay_prompt_job_1',
          'ss_pay_prompt_job_2',
          'ss_pay_prompt_job_3',
        ],
      PaymentCheckContext.buyingFromListing => [
          'ss_pay_prompt_listing_1',
          'ss_pay_prompt_listing_2',
          'ss_pay_prompt_listing_3',
        ],
      PaymentCheckContext.investment => [
          'ss_pay_prompt_invest_1',
          'ss_pay_prompt_invest_2',
          'ss_pay_prompt_invest_3',
        ],
      PaymentCheckContext.governmentFee => [
          'ss_pay_prompt_gov_1',
          'ss_pay_prompt_gov_2',
          'ss_pay_prompt_gov_3',
        ],
      PaymentCheckContext.prizeRefund => [
          'ss_pay_prompt_prize_1',
          'ss_pay_prompt_prize_2',
          'ss_pay_prompt_prize_3',
        ],
      PaymentCheckContext.friendFamilyEmergency => [
          'ss_pay_prompt_friend_1',
          'ss_pay_prompt_friend_2',
          'ss_pay_prompt_friend_3',
        ],
      PaymentCheckContext.other => [
          'ss_pay_prompt_other_1',
          'ss_pay_prompt_other_2',
          'ss_pay_prompt_other_3',
        ],
    };
  }

  static List<String> _reusedVerifyKeys(PaymentCheckContext ctx) {
    return switch (ctx) {
      PaymentCheckContext.jobVisaFee => [
          'ss_verify_job_mol',
          'ss_verify_job_company_site',
          'ss_verify_never_use_message_contact',
        ],
      PaymentCheckContext.governmentFee => [
          'ss_verify_moi',
          'ss_verify_hukoomi',
          'ss_verify_independent_check',
        ],
      PaymentCheckContext.rentDeposit => [
          'ss_verify_rental_in_person',
          'ss_verify_rental_no_deposit_before_viewing',
        ],
      PaymentCheckContext.investment => [
          'ss_verify_investment_qcb',
          'ss_verify_investment_regulator',
        ],
      PaymentCheckContext.buyingFromListing => [
          'ss_verify_never_use_message_contact',
          'ss_verify_independent_check',
        ],
      _ => ['ss_verify_independent_check'],
    };
  }

  static List<String> _ibanConcernKeys(IbanValidationResult r) {
    return switch (r.kind) {
      IbanValidationKind.checksumFailed => ['ss_pay_concern_iban_invalid'],
      IbanValidationKind.invalidFormat ||
      IbanValidationKind.invalidQatarLength =>
        ['ss_pay_concern_iban_format'],
      IbanValidationKind.qatarKnownBank => [
          'ss_pay_concern_iban_bank_named',
        ],
      IbanValidationKind.qatarUnknownBankCode => [
          'ss_pay_concern_iban_unknown_bank',
        ],
      IbanValidationKind.foreign => ['ss_pay_concern_iban_foreign'],
      IbanValidationKind.empty => [],
    };
  }

  static List<String> _phoneConcernKeys(
    QatarPhoneValidationResult phone, {
    required PaymentCheckContext? context,
    required Set<PaymentRequestedMethod> methods,
  }) {
    final keys = <String>[];
    switch (phone.kind) {
      case QatarPhoneValidationKind.foreign:
        if (context?.expectsLocalFormalPayee == true) {
          keys.add('ss_pay_concern_phone_foreign');
        }
      case QatarPhoneValidationKind.invalidLength:
      case QatarPhoneValidationKind.unknown:
        keys.add('ss_pay_concern_phone_format');
      case QatarPhoneValidationKind.qatarMobile:
        if (methods.contains(PaymentRequestedMethod.moveToWhatsAppTelegram) &&
            context?.expectsLocalFormalPayee == true) {
          keys.add('ss_pay_concern_whatsapp_only');
        }
      case QatarPhoneValidationKind.empty:
      case QatarPhoneValidationKind.qatarLandline:
        break;
    }
    return keys;
  }

  static List<String> _methodConcernKeys(PaymentRequestedMethod method) {
    return switch (method) {
      PaymentRequestedMethod.giftCards => ['ss_pay_concern_method_gift_cards'],
      PaymentRequestedMethod.crypto => ['ss_pay_concern_method_crypto'],
      PaymentRequestedMethod.personalAccount => [
          'ss_pay_concern_method_personal_account',
        ],
      PaymentRequestedMethod.refundableDepositBeforeViewing => [
          'ss_pay_concern_method_deposit_before_viewing',
        ],
      PaymentRequestedMethod.urgencyThreats => ['ss_pay_concern_method_urgency'],
      PaymentRequestedMethod.keepSecret => ['ss_pay_concern_method_secret'],
      PaymentRequestedMethod.moveToWhatsAppTelegram => [
          'ss_pay_concern_method_platform_hop',
        ],
    };
  }

  static String _urlFlagToConcern(String flag) {
    return switch (flag) {
      'ss_flag_lookalike_domain' => 'ss_pay_concern_link_lookalike',
      'ss_flag_url_shortener' => 'ss_pay_concern_link_shortener',
      'ss_flag_ip_url' => 'ss_pay_concern_link_ip',
      'ss_flag_nonstandard_gov_tld' => 'ss_pay_concern_link_gov_tld',
      'ss_flag_suspicious_subdomain' => 'ss_pay_concern_link_suspicious',
      _ => 'ss_pay_concern_link_other',
    };
  }
}
