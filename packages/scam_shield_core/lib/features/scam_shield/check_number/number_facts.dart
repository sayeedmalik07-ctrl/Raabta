enum NumberFactType {
  qatarMobile,
  qatarLandline,
  qatarNationalUnverified,
  international,
  shortCode,
  invalid,
}

enum CheckNumberReachChannel {
  phoneCall,
  sms,
  whatsAppOrVoip,
  otherApp,
}

class NumberFacts {
  const NumberFacts({
    required this.type,
    required this.normalizedE164,
    required this.displayNational,
    this.internationalCountryEn,
    this.internationalCountryAr,
    this.numberingPlanVerified = false,
  });

  final NumberFactType type;
  final String? normalizedE164;
  final String displayNational;
  final String? internationalCountryEn;
  final String? internationalCountryAr;
  final bool numberingPlanVerified;

  String factLineKey(String locale) {
    return switch (type) {
      NumberFactType.qatarMobile => 'ss_cn_fact_qatar_mobile',
      NumberFactType.qatarLandline => 'ss_cn_fact_qatar_landline',
      NumberFactType.qatarNationalUnverified => 'ss_cn_fact_qatar_format',
      NumberFactType.international => 'ss_cn_fact_international',
      NumberFactType.shortCode => 'ss_cn_fact_short_code',
      NumberFactType.invalid => 'ss_cn_fact_invalid',
    };
  }
}

class NumberGuidanceCard {
  const NumberGuidanceCard({
    required this.id,
    required this.textKey,
    required this.sourceLabel,
    this.sourceUrl,
  });

  final String id;
  final String textKey;
  final String sourceLabel;
  final String? sourceUrl;
}
