import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Static bundled verification channels — never AI-generated.
abstract final class ScamShieldVerificationChannels {
  static const governmentKeys = [
    'ss_verify_hukoomi',
    'ss_verify_adlsa',
    'ss_verify_moi',
  ];

  static const bankKeys = [
    'ss_verify_bank_card',
    'ss_verify_bank_app',
  ];

  static const jobKeys = [
    'ss_verify_job_mol',
    'ss_verify_job_company_site',
  ];

  static const rentalKeys = [
    'ss_verify_rental_in_person',
    'ss_verify_rental_no_deposit_before_viewing',
  ];

  static const investmentKeys = [
    'ss_verify_investment_qcb',
    'ss_verify_investment_regulator',
  ];

  static const generalKeys = [
    'ss_verify_never_use_message_contact',
    'ss_verify_independent_check',
  ];

  static List<String> keysFor({
    required ScamShieldContentType contentType,
    String? impersonationType,
  }) {
    final keys = <String>[...generalKeys];

    switch (contentType) {
      case ScamShieldContentType.paymentRequest:
        keys.insertAll(0, bankKeys);
      case ScamShieldContentType.jobOffer:
        keys.insertAll(0, jobKeys);
      case ScamShieldContentType.rentalOffer:
        keys.insertAll(0, rentalKeys);
      case ScamShieldContentType.investmentOffer:
        keys.insertAll(0, investmentKeys);
      case ScamShieldContentType.websiteUrl:
      case ScamShieldContentType.email:
      case ScamShieldContentType.whatsAppSms:
        break;
    }

    final imp = impersonationType?.toLowerCase() ?? '';
    if (imp.contains('government') ||
        imp.contains('moi') ||
        imp.contains('ministry')) {
      keys.insertAll(0, governmentKeys);
    } else if (imp.contains('bank')) {
      keys.insertAll(0, bankKeys);
    } else if (contentType == ScamShieldContentType.paymentRequest) {
      keys.insertAll(0, bankKeys);
    }

    return keys.toSet().toList();
  }
}
