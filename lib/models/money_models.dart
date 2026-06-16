class MoneyCountry {
  const MoneyCountry({
    required this.flag,
    required this.name,
    required this.currency,
    required this.indicativeRate,
  });

  final String flag;
  final String name;
  final String currency;
  final double indicativeRate;

  static const india = MoneyCountry(
    flag: '🇮🇳',
    name: 'India',
    currency: 'INR',
    indicativeRate: 22.80,
  );

  static const pakistan = MoneyCountry(
    flag: '🇵🇰',
    name: 'Pakistan',
    currency: 'PKR',
    indicativeRate: 76.50,
  );

  static const bangladesh = MoneyCountry(
    flag: '🇧🇩',
    name: 'Bangladesh',
    currency: 'BDT',
    indicativeRate: 29.20,
  );

  static const nepal = MoneyCountry(
    flag: '🇳🇵',
    name: 'Nepal',
    currency: 'NPR',
    indicativeRate: 35.40,
  );

  static const philippines = MoneyCountry(
    flag: '🇵🇭',
    name: 'Philippines',
    currency: 'PHP',
    indicativeRate: 15.35,
  );

  static const egypt = MoneyCountry(
    flag: '🇪🇬',
    name: 'Egypt',
    currency: 'EGP',
    indicativeRate: 13.45,
  );

  static const sriLanka = MoneyCountry(
    flag: '🇱🇰',
    name: 'Sri Lanka',
    currency: 'LKR',
    indicativeRate: 82.10,
  );

  static const all = [
    india,
    pakistan,
    bangladesh,
    nepal,
    philippines,
    egypt,
    sriLanka,
  ];
}

class ExchangeHouseRate {
  const ExchangeHouseRate({
    required this.id,
    required this.name,
    required this.logoEmoji,
    required this.rate,
    required this.fee,
    required this.transferTime,
    required this.rating,
    required this.mapsUrl,
    required this.phone,
  });

  final String id;
  final String name;
  final String logoEmoji;
  final double rate;
  final int fee;
  final String transferTime;
  final double rating;
  final String mapsUrl;
  final String phone;

  factory ExchangeHouseRate.fromJson(Map<String, dynamic> json) {
    return ExchangeHouseRate(
      id: json['id'] as String,
      name: json['name'] as String,
      logoEmoji: json['logoEmoji'] as String? ?? '💱',
      rate: (json['rate'] as num).toDouble(),
      fee: json['fee'] as int,
      transferTime: json['transferTime'] as String,
      rating: (json['rating'] as num).toDouble(),
      mapsUrl: json['mapsUrl'] as String,
      phone: json['phone'] as String,
    );
  }
}

class RateHistoryPoint {
  const RateHistoryPoint({
    required this.date,
    required this.rate,
  });

  final String date;
  final double rate;

  factory RateHistoryPoint.fromJson(Map<String, dynamic> json) {
    return RateHistoryPoint(
      date: json['date'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }
}

class ExchangeRatesResponse {
  const ExchangeRatesResponse({
    required this.from,
    required this.to,
    required this.lastUpdated,
    required this.indicativeRate,
    required this.houses,
    required this.history,
  });

  final String from;
  final String to;
  final String lastUpdated;
  final double indicativeRate;
  final List<ExchangeHouseRate> houses;
  final List<RateHistoryPoint> history;

  factory ExchangeRatesResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRatesResponse(
      from: json['from'] as String,
      to: json['to'] as String,
      lastUpdated: json['lastUpdated'] as String,
      indicativeRate: (json['indicativeRate'] as num).toDouble(),
      houses: (json['houses'] as List<dynamic>)
          .map((e) => ExchangeHouseRate.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>)
          .map((e) => RateHistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BranchExchangeHouse {
  const BranchExchangeHouse({
    required this.name,
    required this.bestRateLabel,
    required this.distanceKm,
    required this.hours,
    required this.mapsUrl,
    required this.phone,
  });

  final String name;
  final String bestRateLabel;
  final double distanceKm;
  final String hours;
  final String mapsUrl;
  final String phone;
}

class LiveRateDisplay {
  const LiveRateDisplay({
    required this.flag,
    required this.currency,
    required this.rate,
  });

  final String flag;
  final String currency;
  final double rate;
}
