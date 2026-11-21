import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_models.dart';
import 'package:raabta/features/scam_shield/data/scam_multilingual_dictionary_config.dart';

/// Shared phrase groups for contract/offer scans (Phase 33) — single source with Phase 12.
class ContractScamPatternGroupDef {
  const ContractScamPatternGroupDef({
    required this.id,
    required this.priority,
    required this.domain,
    required this.categoryKey,
    required this.wordingKey,
    required this.nextStep,
    this.dictionaryKeys = const [],
    this.patterns = const [],
    this.negativePatterns = const [],
    this.sourceLabelKey = 'cop_source_pattern',
  });

  final String id;
  final int priority;
  final ContractScamPatternDomain domain;
  final String categoryKey;
  final String wordingKey;
  final ContractScamPatternNextStep nextStep;
  final List<String> dictionaryKeys;
  final List<String> patterns;
  final List<String> negativePatterns;
  final String sourceLabelKey;

  List<String> resolvePositivePatterns() {
    final out = <String>[...patterns];
    for (final key in dictionaryKeys) {
      final list = ScamMultilingualDictionaryConfig.legacyFlagPatterns[key];
      if (list != null) out.addAll(list);
    }
    return out;
  }
}

abstract final class ContractScamPatternCatalog {
  static const maxFindings = 4;

  static const groups = <ContractScamPatternGroupDef>[
    ContractScamPatternGroupDef(
      id: 'worker_upfront_fee',
      priority: 10,
      domain: ContractScamPatternDomain.employment,
      categoryKey: 'cop_cat_upfront_fee',
      wordingKey: 'cop_find_upfront_fee',
      nextStep: ContractScamPatternNextStep.paymentCheck,
      dictionaryKeys: ['ss_flag_upfront_fee'],
      negativePatterns: [
        'employer shall pay',
        'employer will pay',
        'reimbursed by employer',
        'company covers',
        'no fee to the worker',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'refundable_deposit',
      priority: 20,
      domain: ContractScamPatternDomain.employment,
      categoryKey: 'cop_cat_refundable_deposit',
      wordingKey: 'cop_find_refundable_deposit',
      nextStep: ContractScamPatternNextStep.paymentCheck,
      patterns: [
        'refundable deposit',
        'security deposit from you',
        'deposit will be returned',
        'عربون مسترد',
        'refundable security',
      ],
      negativePatterns: [
        'employer deposit',
        'company security deposit',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'passport_retention',
      priority: 15,
      domain: ContractScamPatternDomain.employment,
      categoryKey: 'cop_cat_passport',
      wordingKey: 'cop_find_passport',
      nextStep: ContractScamPatternNextStep.beforeYouSign,
      patterns: [
        'keep your passport',
        'hold your passport',
        'surrender your passport',
        'passport will be kept',
        'passport retained',
        'يحتفظ بجواز',
        'جواز السفر لدينا',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'guaranteed_visa_job',
      priority: 25,
      domain: ContractScamPatternDomain.employment,
      categoryKey: 'cop_cat_guaranteed',
      wordingKey: 'cop_find_guaranteed',
      nextStep: ContractScamPatternNextStep.officialDirectory,
      patterns: [
        'guaranteed visa',
        'guaranteed job',
        '100% visa',
        'visa assured',
        'تأشيرة مضمونة',
        'وظيفة مضمونة',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'urgent_sign',
      priority: 40,
      domain: ContractScamPatternDomain.employment,
      categoryKey: 'cop_cat_urgency',
      wordingKey: 'cop_find_urgency',
      nextStep: ContractScamPatternNextStep.beforeYouSign,
      dictionaryKeys: ['ss_flag_urgency'],
      patterns: [
        'sign today or',
        'lose the offer',
        'offer expires today',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'off_platform_contact',
      priority: 35,
      domain: ContractScamPatternDomain.any,
      categoryKey: 'cop_cat_contact',
      wordingKey: 'cop_find_off_platform',
      nextStep: ContractScamPatternNextStep.inCallAssistant,
      patterns: [
        'whatsapp only',
        'telegram only',
        'contact via whatsapp',
        'personal email only',
        'gmail.com only',
        'واتساب فقط',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'personal_account_payment',
      priority: 18,
      domain: ContractScamPatternDomain.any,
      categoryKey: 'cop_cat_personal_account',
      wordingKey: 'cop_find_personal_account',
      nextStep: ContractScamPatternNextStep.paymentCheck,
      patterns: [
        'personal account',
        'personal bank account',
        'pay to my account',
        'transfer to individual account',
        'حساب شخصي',
      ],
      negativePatterns: [
        'company account',
        'corporate account',
        'official company iban',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'housing_deposit_before_viewing',
      priority: 12,
      domain: ContractScamPatternDomain.housing,
      categoryKey: 'cop_cat_housing_deposit',
      wordingKey: 'cop_find_housing_deposit',
      nextStep: ContractScamPatternNextStep.paymentCheck,
      patterns: [
        'pay before viewing',
        'deposit before viewing',
        'send deposit to reserve',
        'pay before you see the flat',
        'عربون قبل المعاينة',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'landlord_abroad_courier',
      priority: 30,
      domain: ContractScamPatternDomain.housing,
      categoryKey: 'cop_cat_landlord_abroad',
      wordingKey: 'cop_find_landlord_abroad',
      nextStep: ContractScamPatternNextStep.officialDirectory,
      patterns: [
        'landlord abroad',
        'keys by courier',
        'send keys by dhl',
        'owner overseas',
        'مفاتيح بالبريد',
      ],
    ),
    ContractScamPatternGroupDef(
      id: 'no_written_tenancy',
      priority: 45,
      domain: ContractScamPatternDomain.housing,
      categoryKey: 'cop_cat_no_written',
      wordingKey: 'cop_find_no_written',
      nextStep: ContractScamPatternNextStep.beforeYouSign,
      patterns: [
        'verbal agreement only',
        'no written contract',
        'no tenancy contract',
        'trust me no paper',
      ],
    ),
  ];
}
