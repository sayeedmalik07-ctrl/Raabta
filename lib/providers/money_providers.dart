import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/money_models.dart';
import 'package:raabta/services/exchange_api_service.dart';

final exchangeApiServiceProvider = Provider<ExchangeApiService>((ref) {
  return ExchangeApiService();
});

final sendAmountProvider = StateProvider<double>((ref) => 500);

final selectedCountryProvider =
    StateProvider<MoneyCountry>((ref) => MoneyCountry.india);

final exchangeRatesProvider =
    FutureProvider.family<ExchangeRatesResponse, String>((ref, currency) async {
  final service = ref.watch(exchangeApiServiceProvider);
  return service.fetchRates(from: 'QAR', to: currency);
});

final liveRatesProvider = Provider<List<LiveRateDisplay>>((ref) {
  return [
    const LiveRateDisplay(flag: '🇮🇳', currency: 'INR', rate: 22.80),
    const LiveRateDisplay(flag: '🇵🇰', currency: 'PKR', rate: 76.50),
    const LiveRateDisplay(flag: '🇧🇩', currency: 'BDT', rate: 29.20),
    const LiveRateDisplay(flag: '🇳🇵', currency: 'NPR', rate: 35.40),
  ];
});

final branchExchangeHousesProvider = Provider<List<BranchExchangeHouse>>((ref) {
  return const [
    BranchExchangeHouse(
      name: 'LULU Exchange Al Khor',
      bestRateLabel: '1 QR = 22.82 INR',
      distanceKm: 1.2,
      hours: 'Sat–Thu 8:00 AM – 10:00 PM',
      mapsUrl: 'https://maps.google.com/?q=Lulu+Exchange+Al+Khor+Qatar',
      phone: '+97444111222',
    ),
    BranchExchangeHouse(
      name: 'Trust Exchange Al Khor',
      bestRateLabel: '1 QR = 22.78 INR',
      distanceKm: 1.8,
      hours: 'Sat–Thu 9:00 AM – 9:00 PM',
      mapsUrl: 'https://maps.google.com/?q=Trust+Exchange+Al+Khor+Qatar',
      phone: '+97444111333',
    ),
    BranchExchangeHouse(
      name: 'Al Zaman Exchange',
      bestRateLabel: '1 QR = 22.80 INR',
      distanceKm: 2.4,
      hours: 'Daily 8:30 AM – 10:30 PM',
      mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Al+Khor',
      phone: '+97444111444',
    ),
    BranchExchangeHouse(
      name: 'Al Dar Exchange',
      bestRateLabel: '1 QR = 22.75 INR',
      distanceKm: 3.1,
      hours: 'Sat–Thu 9:00 AM – 9:30 PM',
      mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar',
      phone: '+97444111555',
    ),
    BranchExchangeHouse(
      name: 'Gulf Exchange',
      bestRateLabel: '1 QR = 22.70 INR',
      distanceKm: 4.5,
      hours: 'Sat–Thu 8:00 AM – 8:00 PM',
      mapsUrl: 'https://maps.google.com/?q=Gulf+Exchange+Qatar',
      phone: '+97444111666',
    ),
    BranchExchangeHouse(
      name: 'Habib Qatar International Exchange',
      bestRateLabel: '1 QR = 22.68 INR',
      distanceKm: 5.2,
      hours: 'Sat–Thu 9:00 AM – 7:00 PM',
      mapsUrl: 'https://maps.google.com/?q=Habib+Qatar+International+Exchange',
      phone: '+97444111777',
    ),
  ];
});

ExchangeRatesResponse fallbackExchangeRates(String currency) {
  final country = MoneyCountry.all.firstWhere(
    (c) => c.currency == currency,
    orElse: () => MoneyCountry.india,
  );

  final housesByCurrency = <String, List<ExchangeHouseRate>>{
    'INR': [
      _house('al-zaman', 'Al Zaman Exchange', '🏦', 22.80, 5, 'Instant', 4.7),
      _house('western-union', 'Western Union Qatar', '🌐', 22.65, 8, '2 hrs', 4.4),
      _house('al-dar', 'Al Dar Exchange', '🏛️', 22.70, 5, 'Instant', 4.5),
      _house('lulu', 'LULU Exchange Al Khor', '🛒', 22.82, 6, 'Instant', 4.8),
      _house('trust', 'Trust Exchange Al Khor', '🤝', 22.78, 5, '2 hrs', 4.3),
      _house('al-mirqab', 'Al Mirqab Exchange', '💰', 22.72, 7, 'Next Day', 4.1),
      _house('gulf', 'Gulf Exchange', '🌍', 22.68, 5, 'Instant', 4.2),
      _house('habib', 'Habib Qatar International Exchange', '🏢', 22.66, 6, '2 hrs', 4.0),
      _house('al-amanah', 'Al Amanah Exchange', '✅', 22.75, 5, 'Instant', 4.6),
      _house('baladna', 'Baladna Exchange', '🐪', 22.64, 4, 'Instant', 4.2),
      _house('moneygram', 'MoneyGram Qatar', '📨', 22.60, 10, 'Next Day', 3.9),
    ],
    'PKR': [
      _house('al-zaman', 'Al Zaman Exchange', '🏦', 76.50, 5, 'Instant', 4.7),
      _house('western-union', 'Western Union Qatar', '🌐', 76.20, 8, '2 hrs', 4.4),
      _house('al-dar', 'Al Dar Exchange', '🏛️', 76.35, 5, 'Instant', 4.5),
      _house('lulu', 'LULU Exchange Al Khor', '🛒', 76.55, 6, 'Instant', 4.8),
      _house('trust', 'Trust Exchange Al Khor', '🤝', 76.40, 5, '2 hrs', 4.3),
      _house('moneygram', 'MoneyGram Qatar', '📨', 76.10, 10, 'Next Day', 3.9),
    ],
    'BDT': [
      _house('al-zaman', 'Al Zaman Exchange', '🏦', 29.20, 5, 'Instant', 4.7),
      _house('western-union', 'Western Union Qatar', '🌐', 29.05, 8, '2 hrs', 4.4),
      _house('al-dar', 'Al Dar Exchange', '🏛️', 29.15, 5, 'Instant', 4.5),
      _house('lulu', 'LULU Exchange Al Khor', '🛒', 29.25, 6, 'Instant', 4.8),
      _house('trust', 'Trust Exchange Al Khor', '🤝', 29.18, 5, '2 hrs', 4.3),
      _house('moneygram', 'MoneyGram Qatar', '📨', 28.95, 10, 'Next Day', 3.9),
    ],
    'NPR': [
      _house('al-zaman', 'Al Zaman Exchange', '🏦', 35.40, 5, 'Instant', 4.7),
      _house('western-union', 'Western Union Qatar', '🌐', 35.20, 8, '2 hrs', 4.4),
      _house('al-dar', 'Al Dar Exchange', '🏛️', 35.35, 5, 'Instant', 4.5),
      _house('lulu', 'LULU Exchange Al Khor', '🛒', 35.45, 6, 'Instant', 4.8),
      _house('trust', 'Trust Exchange Al Khor', '🤝', 35.38, 5, '2 hrs', 4.3),
      _house('moneygram', 'MoneyGram Qatar', '📨', 35.10, 10, 'Next Day', 3.9),
    ],
    'PHP': [
      _house('al-zaman', 'Al Zaman Exchange', '🏦', 15.35, 5, 'Instant', 4.7),
      _house('western-union', 'Western Union Qatar', '🌐', 15.22, 8, '2 hrs', 4.4),
      _house('al-dar', 'Al Dar Exchange', '🏛️', 15.30, 5, 'Instant', 4.5),
      _house('lulu', 'LULU Exchange Al Khor', '🛒', 15.38, 6, 'Instant', 4.8),
      _house('moneygram', 'MoneyGram Qatar', '📨', 15.15, 10, 'Next Day', 3.9),
    ],
    'EGP': [
      _house('al-zaman', 'Al Zaman Exchange', '🏦', 13.45, 5, 'Instant', 4.6),
      _house('western-union', 'Western Union Qatar', '🌐', 13.35, 8, '2 hrs', 4.3),
      _house('al-dar', 'Al Dar Exchange', '🏛️', 13.40, 5, 'Instant', 4.4),
      _house('gulf', 'Gulf Exchange', '🌍', 13.38, 5, 'Instant', 4.2),
      _house('moneygram', 'MoneyGram Qatar', '📨', 13.28, 10, 'Next Day', 3.8),
    ],
    'LKR': [
      _house('al-zaman', 'Al Zaman Exchange', '🏦', 82.10, 5, 'Instant', 4.6),
      _house('western-union', 'Western Union Qatar', '🌐', 81.80, 8, '2 hrs', 4.3),
      _house('al-dar', 'Al Dar Exchange', '🏛️', 82.00, 5, 'Instant', 4.4),
      _house('habib', 'Habib Qatar International Exchange', '🏢', 81.95, 6, '2 hrs', 4.1),
      _house('moneygram', 'MoneyGram Qatar', '📨', 81.60, 10, 'Next Day', 3.8),
    ],
  };

  return ExchangeRatesResponse(
    from: 'QAR',
    to: currency,
    lastUpdated: 'Today 9:00 AM',
    indicativeRate: country.indicativeRate,
    houses: housesByCurrency[currency] ?? housesByCurrency['INR']!,
    history: _generateHistory(country.indicativeRate),
  );
}

ExchangeHouseRate _house(
  String id,
  String name,
  String emoji,
  double rate,
  int fee,
  String transferTime,
  double rating,
) {
  return ExchangeHouseRate(
    id: id,
    name: name,
    logoEmoji: emoji,
    rate: rate,
    fee: fee,
    transferTime: transferTime,
    rating: rating,
    mapsUrl: 'https://maps.google.com/?q=${Uri.encodeComponent(name)}+Qatar',
    phone: '+97444110000',
  );
}

List<RateHistoryPoint> _generateHistory(double currentRate) {
  return List.generate(7, (index) {
    final variation = (index - 3) * 0.04;
    return RateHistoryPoint(
      date: 'Day ${index + 1}',
      rate: double.parse((currentRate + variation).toStringAsFixed(2)),
    );
  });
}
