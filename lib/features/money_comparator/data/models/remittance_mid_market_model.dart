/// Mid-market baseline stored by backend relay (Frankfurter + open.er-api.com).
class RemittanceMidMarketSnapshot {
  const RemittanceMidMarketSnapshot({
    required this.qarUsdPeg,
    required this.corridors,
    required this.refreshedAt,
    this.frankfurterDate,
    this.erApiUpdated,
  });

  final double qarUsdPeg;
  final Map<String, RemittanceCorridorRate> corridors;
  final DateTime refreshedAt;
  final String? frankfurterDate;
  final String? erApiUpdated;

  RemittanceCorridorRate? rateFor(String countryCode) =>
      corridors[countryCode.toUpperCase()];

  factory RemittanceMidMarketSnapshot.fromFirestore(Map<String, dynamic> data) {
    return RemittanceMidMarketSnapshot.fromCacheJson(data);
  }

  Map<String, dynamic> toCacheJson() => {
        'qarUsdPeg': qarUsdPeg,
        'corridors': corridors.map(
          (code, rate) => MapEntry(code, rate.toCacheJson()),
        ),
        'refreshedAt': refreshedAt.toIso8601String(),
        if (frankfurterDate != null) 'frankfurterDate': frankfurterDate,
        if (erApiUpdated != null) 'erApiUpdated': erApiUpdated,
      };

  factory RemittanceMidMarketSnapshot.fromCacheJson(Map<String, dynamic> data) {
    final corridorsRaw = data['corridors'] as Map<String, dynamic>? ?? {};
    final corridors = <String, RemittanceCorridorRate>{};
    corridorsRaw.forEach((code, value) {
      if (value is Map) {
        corridors[code.toUpperCase()] = RemittanceCorridorRate.fromMap(
          Map<String, dynamic>.from(value),
        );
      }
    });

    return RemittanceMidMarketSnapshot(
      qarUsdPeg: (data['qarUsdPeg'] as num?)?.toDouble() ?? 3.64,
      corridors: corridors,
      refreshedAt: DateTime.tryParse(data['refreshedAt'] as String? ?? '') ??
          DateTime.now(),
      frankfurterDate: data['frankfurterDate'] as String?,
      erApiUpdated: data['erApiUpdated'] as String?,
    );
  }
}

class RemittanceCorridorRate {
  const RemittanceCorridorRate({
    required this.rate,
    required this.source,
    this.sourceDate,
    this.usdCrossRate,
  });

  /// Foreign currency units received per 1 QAR at mid-market.
  final double rate;
  final RemittanceRateSource source;
  final String? sourceDate;
  final double? usdCrossRate;

  factory RemittanceCorridorRate.fromMap(Map<String, dynamic> data) {
    final sourceRaw = data['source'] as String? ?? 'unknown';
    return RemittanceCorridorRate(
      rate: (data['rate'] as num?)?.toDouble() ?? 0,
      source: RemittanceRateSource.fromId(sourceRaw),
      sourceDate: data['sourceDate'] as String?,
      usdCrossRate: (data['usdCrossRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'rate': rate,
        'source': source.id,
        if (sourceDate != null) 'sourceDate': sourceDate,
        if (usdCrossRate != null) 'usdCrossRate': usdCrossRate,
      };
}

enum RemittanceRateSource {
  frankfurterEcb('frankfurter_ecb'),
  openErApi('open_er_api'),
  unknown('unknown');

  const RemittanceRateSource(this.id);
  final String id;

  static RemittanceRateSource fromId(String id) {
    for (final s in RemittanceRateSource.values) {
      if (s.id == id) return s;
    }
    return RemittanceRateSource.unknown;
  }
}
