/// Provider markup data — World Bank RPW (verified) or Raabta-curated fallback.
class RemittanceProviderRate {
  const RemittanceProviderRate({
    required this.id,
    required this.providerName,
    required this.destinationCountryCode,
    required this.fxMarginPercent,
    required this.flatFeeQar,
    required this.dataSource,
    required this.dataAsOf,
    this.method,
    this.reliabilityNote,
    this.sourceUrl,
  });

  final String id;
  final String providerName;
  final String destinationCountryCode;
  final double fxMarginPercent;
  final double flatFeeQar;
  final RemittanceProviderDataSource dataSource;
  final String dataAsOf;
  final String? method;
  final String? reliabilityNote;
  final String? sourceUrl;

  factory RemittanceProviderRate.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return RemittanceProviderRate.fromCacheJson({
      'id': id,
      ...data,
    });
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'providerName': providerName,
        'destinationCountryCode': destinationCountryCode,
        'fxMarginPercent': fxMarginPercent,
        'flatFeeQar': flatFeeQar,
        'dataSource': dataSource.id,
        'dataAsOf': dataAsOf,
        if (method != null) 'method': method,
        if (reliabilityNote != null) 'reliabilityNote': reliabilityNote,
        if (sourceUrl != null) 'sourceUrl': sourceUrl,
      };

  factory RemittanceProviderRate.fromCacheJson(Map<String, dynamic> data) {
    return RemittanceProviderRate(
      id: data['id'] as String? ?? '',
      providerName: data['providerName'] as String? ?? '',
      destinationCountryCode:
          (data['destinationCountryCode'] as String? ?? '').toUpperCase(),
      fxMarginPercent: (data['fxMarginPercent'] as num?)?.toDouble() ?? 0,
      flatFeeQar: (data['flatFeeQar'] as num?)?.toDouble() ?? 0,
      dataSource: RemittanceProviderDataSource.fromId(
        data['dataSource'] as String? ?? '',
      ),
      dataAsOf: data['dataAsOf'] as String? ?? '',
      method: data['method'] as String?,
      reliabilityNote: data['reliabilityNote'] as String?,
      sourceUrl: data['sourceUrl'] as String?,
    );
  }
}

enum RemittanceProviderDataSource {
  worldBankRpw('world_bank_rpw'),
  raabtaCurated('raabta_curated'),
  unknown('unknown');

  const RemittanceProviderDataSource(this.id);
  final String id;

  static RemittanceProviderDataSource fromId(String id) {
    for (final s in RemittanceProviderDataSource.values) {
      if (s.id == id) return s;
    }
    return RemittanceProviderDataSource.unknown;
  }
}
