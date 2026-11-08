/// Bundled community-reported scam archetypes for Qatar expats — offline only.
abstract final class ScamCommunityPatternsConfig {
  static const version = 1;

  static const patterns = [
    ScamCommunityPatternDefinition(
      id: 'fake_moi_fine',
      labelKey: 'ss_community_pattern_moi_fine',
      terms: [
        'moi',
        'ministry',
        'fine',
        'pay',
        'arrest',
        'warrant',
        'وزارة',
        'غرامة',
        'اعتقال',
      ],
      minTermMatches: 2,
    ),
    ScamCommunityPatternDefinition(
      id: 'job_visa_fee',
      labelKey: 'ss_community_pattern_job_fee',
      terms: [
        'job offer',
        'visa fee',
        'processing fee',
        'pay fee',
        'qatar job',
        'employment',
        'رسوم',
        'visa',
        'فيزا',
        'नौकरी',
      ],
      minTermMatches: 2,
    ),
    ScamCommunityPatternDefinition(
      id: 'rental_deposit_scam',
      labelKey: 'ss_community_pattern_rental_deposit',
      terms: [
        'apartment',
        'rent',
        'deposit',
        'before viewing',
        'transfer',
        'flat',
        'إيجار',
        'عربون',
        'کرایہ',
      ],
      minTermMatches: 2,
    ),
    ScamCommunityPatternDefinition(
      id: 'nas_address_verify',
      labelKey: 'ss_community_pattern_nas_verify',
      terms: [
        'national address',
        'nas',
        'verify address',
        'update address',
        'click link',
        'العنوان الوطني',
      ],
      minTermMatches: 2,
    ),
    ScamCommunityPatternDefinition(
      id: 'telecom_sim_block',
      labelKey: 'ss_community_pattern_telecom_sim',
      terms: [
        'ooredoo',
        'vodafone',
        'sim',
        'blocked',
        'suspended',
        'call back',
        'esim',
        'اتصالات',
      ],
      minTermMatches: 2,
    ),
    ScamCommunityPatternDefinition(
      id: 'bank_kyc_phish',
      labelKey: 'ss_community_pattern_bank_kyc',
      terms: [
        'bank',
        'kyc',
        'update account',
        'verify account',
        'qnb',
        'suspended',
        'البنك',
        'تحديث',
      ],
      minTermMatches: 2,
    ),
    ScamCommunityPatternDefinition(
      id: 'delivery_customs_fee',
      labelKey: 'ss_community_pattern_delivery_customs',
      terms: [
        'delivery',
        'customs',
        'package',
        'pay fee',
        'dhl',
        'aramex',
        'tariff',
        'توصيل',
        'جمارك',
      ],
      minTermMatches: 2,
    ),
    ScamCommunityPatternDefinition(
      id: 'investment_guaranteed',
      labelKey: 'ss_community_pattern_investment',
      terms: [
        'guaranteed return',
        'investment',
        'double your money',
        'crypto',
        'usdt',
        'profit',
        'استثمار',
        'ربح مضمون',
      ],
      minTermMatches: 2,
    ),
  ];

  /// Investment/trading-scheme archetype — shared read for Community moderation pre-filter.
  static ScamCommunityPatternDefinition get investmentPattern =>
      patterns.firstWhere((p) => p.id == 'investment_guaranteed');
}

class ScamCommunityPatternDefinition {
  const ScamCommunityPatternDefinition({
    required this.id,
    required this.labelKey,
    required this.terms,
    required this.minTermMatches,
  });

  final String id;
  final String labelKey;
  final List<String> terms;
  final int minTermMatches;
}
