/// Corridor flight destinations — DOH to the five Raabta remittance corridors.
///
/// Flags and country names align with [raabtaCurrencies] (INR, PKR, BDT, NPR, PHP).
/// TODO(Sayeed): confirm default gateway airports per country if we simplify emergency to one city.
abstract final class CorridorFlightCatalog {
  static const originIata = 'DOH';

  static const countries = <CorridorFlightCountry>[
    CorridorFlightCountry(
      id: 'india',
      currencyCode: 'INR',
      flag: '🇮🇳',
      nameKey: 'fc_country_india',
      nationalityAliases: [
        'india',
        'indian',
        'in',
        'ind',
        'bharat',
        'hindustan',
        'भारत',
      ],
      destinations: [
        CorridorFlightDestination(
          airportIata: 'DEL',
          cityNameKey: 'fc_city_delhi',
        ),
        CorridorFlightDestination(
          airportIata: 'BOM',
          cityNameKey: 'fc_city_mumbai',
        ),
        CorridorFlightDestination(
          airportIata: 'BLR',
          cityNameKey: 'fc_city_bengaluru',
        ),
        CorridorFlightDestination(
          airportIata: 'MAA',
          cityNameKey: 'fc_city_chennai',
        ),
      ],
    ),
    CorridorFlightCountry(
      id: 'pakistan',
      currencyCode: 'PKR',
      flag: '🇵🇰',
      nameKey: 'fc_country_pakistan',
      nationalityAliases: [
        'pakistan',
        'pakistani',
        'pk',
        'pak',
      ],
      destinations: [
        CorridorFlightDestination(
          airportIata: 'KHI',
          cityNameKey: 'fc_city_karachi',
        ),
        CorridorFlightDestination(
          airportIata: 'LHE',
          cityNameKey: 'fc_city_lahore',
        ),
        CorridorFlightDestination(
          airportIata: 'ISB',
          cityNameKey: 'fc_city_islamabad',
        ),
      ],
    ),
    CorridorFlightCountry(
      id: 'bangladesh',
      currencyCode: 'BDT',
      flag: '🇧🇩',
      nameKey: 'fc_country_bangladesh',
      nationalityAliases: [
        'bangladesh',
        'bangladeshi',
        'bd',
        'bdt',
      ],
      destinations: [
        CorridorFlightDestination(
          airportIata: 'DAC',
          cityNameKey: 'fc_city_dhaka',
        ),
        CorridorFlightDestination(
          airportIata: 'CGP',
          cityNameKey: 'fc_city_chittagong',
        ),
      ],
    ),
    CorridorFlightCountry(
      id: 'nepal',
      currencyCode: 'NPR',
      flag: '🇳🇵',
      nameKey: 'fc_country_nepal',
      nationalityAliases: [
        'nepal',
        'nepali',
        'nepalese',
        'np',
        'नेपाल',
      ],
      destinations: [
        CorridorFlightDestination(
          airportIata: 'KTM',
          cityNameKey: 'fc_city_kathmandu',
        ),
      ],
    ),
    CorridorFlightCountry(
      id: 'philippines',
      currencyCode: 'PHP',
      flag: '🇵🇭',
      nameKey: 'fc_country_philippines',
      nationalityAliases: [
        'philippines',
        'filipino',
        'filipina',
        'philippine',
        'ph',
        'pilipinas',
        'ofw',
      ],
      destinations: [
        CorridorFlightDestination(
          airportIata: 'MNL',
          cityNameKey: 'fc_city_manila',
        ),
        CorridorFlightDestination(
          airportIata: 'CEB',
          cityNameKey: 'fc_city_cebu',
        ),
      ],
    ),
  ];

  /// Static booking guidance — general, defensible, no prices or airline names.
  static const bookingTipKeys = [
    'fc_tip_booking_window',
    'fc_tip_midweek',
    'fc_tip_direct_layover',
    'fc_tip_compare_providers',
    'fc_tip_visa_passport',
  ];

  static CorridorFlightCountry? countryById(String id) {
    for (final country in countries) {
      if (country.id == id) return country;
    }
    return null;
  }

  /// Maps onboarding / profile nationality text to a corridor country id.
  static String? resolveCountryId(String nationality) {
    final normalized = _normalize(nationality);
    if (normalized.isEmpty) return null;
    for (final country in countries) {
      for (final alias in country.nationalityAliases) {
        if (_normalize(alias) == normalized) return country.id;
      }
    }
    for (final country in countries) {
      for (final alias in country.nationalityAliases) {
        final a = _normalize(alias);
        if (normalized.contains(a) || a.contains(normalized)) {
          return country.id;
        }
      }
    }
    return null;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class CorridorFlightCountry {
  const CorridorFlightCountry({
    required this.id,
    required this.currencyCode,
    required this.flag,
    required this.nameKey,
    required this.nationalityAliases,
    required this.destinations,
  });

  final String id;
  final String currencyCode;
  final String flag;
  final String nameKey;
  final List<String> nationalityAliases;
  final List<CorridorFlightDestination> destinations;

  CorridorFlightDestination get primaryDestination => destinations.first;
}

class CorridorFlightDestination {
  const CorridorFlightDestination({
    required this.airportIata,
    required this.cityNameKey,
  });

  final String airportIata;
  final String cityNameKey;
}
