/// Qatar telecom USSD reference — Ooredoo & Vodafone only (NOT Saudi STC/Mobily/Zain).
/// Verified against published operator docs / tariff FAQs (Jul 2026).
/// Codes can change — verify on ooredoo.qa or vf.qa if a code stops working.
library;

enum QatarTelecomOperator { ooredoo, vodafone }

enum UssdCategory {
  balanceCheck,
  dataBalance,
  recharge,
  packageActivation,
  customerService,
  roaming,
  selfService,
  other,
}

extension UssdCategoryX on UssdCategory {
  String get label {
    switch (this) {
      case UssdCategory.balanceCheck:
        return 'Balance Check';
      case UssdCategory.dataBalance:
        return 'Data Balance';
      case UssdCategory.recharge:
        return 'Recharge';
      case UssdCategory.packageActivation:
        return 'Package Activation';
      case UssdCategory.customerService:
        return 'Customer Service';
      case UssdCategory.roaming:
        return 'Roaming';
      case UssdCategory.selfService:
        return 'Self-Service Menu';
      case UssdCategory.other:
        return 'Other';
    }
  }
}

class UssdCodeEntry {
  const UssdCodeEntry({
    required this.operator,
    required this.category,
    required this.label,
    required this.code,
    required this.description,
    this.planNote,
  });

  final QatarTelecomOperator operator;
  final UssdCategory category;
  final String label;
  final String code;
  final String description;
  final String? planNote;
}

const qatarUssdCodes = <UssdCodeEntry>[
  // ── Ooredoo ─────────────────────────────────────────────
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.balanceCheck,
    label: 'Hala main balance',
    code: '*129#',
    description: 'Check prepaid (Hala) main credit balance and validity.',
    planNote: 'Hala prepaid only',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.balanceCheck,
    label: 'Hala bonus balance',
    code: '*129*2#',
    description: 'Check Hala bonus balance allowance.',
    planNote: 'Hala prepaid only',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.balanceCheck,
    label: 'Shahry postpaid balance',
    code: '*123#',
    description: 'View postpaid (Shahry) balance and plan allowances.',
    planNote: 'Shahry postpaid only',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.balanceCheck,
    label: 'Flexi balance & points',
    code: '*127#',
    description: 'Check Flexi plan balance and reward points.',
    planNote: 'Flexi plans',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.recharge,
    label: 'Recharge menu',
    code: '*100#',
    description: 'Open recharge and account self-service menu.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.recharge,
    label: 'Recharge with voucher',
    code: '*101*[16-digit code]#',
    description: 'Redeem a scratch-card voucher — replace with your 16-digit PIN.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.other,
    label: 'Transfer credit',
    code: '*130*[number]*[amount]#',
    description: 'Transfer Hala credit to another Ooredoo number.',
    planNote: 'Hala prepaid only',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.other,
    label: 'Call Me Back',
    code: '*103*[mobile number]#',
    description: 'Send a free Call Me Back request to another number.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.roaming,
    label: 'Roaming packages',
    code: '*124#',
    description: 'Browse and activate Ooredoo roaming packages.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.ooredoo,
    category: UssdCategory.customerService,
    label: 'Customer care (voice)',
    code: '111',
    description: 'Call Ooredoo customer care free from your Ooredoo line.',
  ),
  // ── Vodafone Qatar ──────────────────────────────────────
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.balanceCheck,
    label: 'Quick balance overview',
    code: '*129#',
    description: 'SMS summary of balance, data, minutes, and SMS allowance.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.selfService,
    label: 'Full self-service menu',
    code: '*100#',
    description: 'Account menu — balance, plans, voicemail, roaming, and settings.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.balanceCheck,
    label: 'Flex units balance',
    code: '*130#',
    description: 'Check remaining Flex units for calls, SMS, and data.',
    planNote: 'Flex plans',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.dataBalance,
    label: 'Data balance',
    code: '*132#',
    description: 'Check remaining mobile data allowance.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.recharge,
    label: 'Prepaid recharge card',
    code: '*127*[PIN]#',
    description: 'Recharge prepaid balance using scratch-card PIN.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.recharge,
    label: 'Flex recharge card',
    code: '*777*[PIN]#',
    description: 'Recharge Flex units using an eligible Flex voucher.',
    planNote: 'Flex cards',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.packageActivation,
    label: 'Offers & packages',
    code: '*111#',
    description: 'View latest Vodafone offers and add-on packages.',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.roaming,
    label: 'Roaming menu',
    code: '*100#',
    description: 'Access roaming settings via self-service (also works abroad).',
  ),
  UssdCodeEntry(
    operator: QatarTelecomOperator.vodafone,
    category: UssdCategory.customerService,
    label: 'Customer care (voice)',
    code: '111',
    description: 'Call Vodafone Qatar support free from your Vodafone line.',
  ),
];

List<UssdCodeEntry> ussdForOperator(QatarTelecomOperator op) =>
    qatarUssdCodes.where((e) => e.operator == op).toList();

List<UssdCategory> categoriesForOperator(QatarTelecomOperator op) {
  final cats = ussdForOperator(op).map((e) => e.category).toSet().toList();
  cats.sort((a, b) => a.index.compareTo(b.index));
  return cats;
}

String ussdToTelUri(String code) {
  final encoded = code.replaceAll('#', '%23').replaceAll('*', '*');
  return 'tel:$encoded';
}
