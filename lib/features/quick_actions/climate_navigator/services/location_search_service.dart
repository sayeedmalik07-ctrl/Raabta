import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/core/l10n/app_locale.dart';

// ─── Place suggestion model ───────────────────────────────

class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  const PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });
}

// ─── Service ─────────────────────────────────────────────

class LocationSearchService {
  LocationSearchService._();

  static const _apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  static Future<List<PlaceSuggestion>> autocomplete(
    String input, {
    String locale = 'English',
  }) async {
    if (input.trim().length < 2) return [];

    if (_apiKey.isEmpty || _apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
      return _fallbackSearch(input);
    }

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place'
        '/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&components=country:qa'
        '&language=${AppLocale.toLanguageCode(locale)}'
        '&key=$_apiKey',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return _fallbackSearch(input);

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (data['status'] == 'REQUEST_DENIED' ||
          data['status'] == 'INVALID_REQUEST') {
        return _fallbackSearch(input);
      }

      final predictions = data['predictions'] as List<dynamic>? ?? [];

      return predictions.map((p) {
        final main = p['structured_formatting']?['main_text'] as String? ??
            p['description'] as String? ??
            '';
        final secondary =
            p['structured_formatting']?['secondary_text'] as String? ??
                'Qatar';

        return PlaceSuggestion(
          placeId: p['place_id'] as String? ?? '',
          mainText: main,
          secondaryText: secondary,
          fullText: '$main, $secondary',
        );
      }).toList();
    } catch (_) {
      return _fallbackSearch(input);
    }
  }

  static List<PlaceSuggestion> _fallbackSearch(String input) {
    final q = input.toLowerCase();
    return _qatarLocations
        .where(
          (l) =>
              l.mainText.toLowerCase().contains(q) ||
              l.secondaryText.toLowerCase().contains(q),
        )
        .take(6)
        .toList();
  }

  static const _qatarLocations = <PlaceSuggestion>[
    PlaceSuggestion(
      placeId: 'doha',
      mainText: 'Doha',
      secondaryText: 'Qatar',
      fullText: 'Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'lusail',
      mainText: 'Lusail',
      secondaryText: 'Qatar',
      fullText: 'Lusail, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'alkhor',
      mainText: 'Al Khor',
      secondaryText: 'Qatar',
      fullText: 'Al Khor, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'west_bay',
      mainText: 'West Bay',
      secondaryText: 'Doha, Qatar',
      fullText: 'West Bay, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'the_pearl',
      mainText: 'The Pearl',
      secondaryText: 'Doha, Qatar',
      fullText: 'The Pearl, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'al_sadd',
      mainText: 'Al Sadd',
      secondaryText: 'Doha, Qatar',
      fullText: 'Al Sadd, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'katara',
      mainText: 'Katara Cultural Village',
      secondaryText: 'Doha, Qatar',
      fullText: 'Katara Cultural Village, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'education_city',
      mainText: 'Education City',
      secondaryText: 'Al Rayyan, Qatar',
      fullText: 'Education City, Al Rayyan, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'hamad_airport',
      mainText: 'Hamad International Airport',
      secondaryText: 'Doha, Qatar',
      fullText: 'Hamad International Airport, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'souq_waqif',
      mainText: 'Souq Waqif',
      secondaryText: 'Doha, Qatar',
      fullText: 'Souq Waqif, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'city_center',
      mainText: 'City Center Doha',
      secondaryText: 'Al Dafna, Doha, Qatar',
      fullText: 'City Center Doha, Al Dafna, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'mall_of_qatar',
      mainText: 'Mall of Qatar',
      secondaryText: 'Al Rayyan, Qatar',
      fullText: 'Mall of Qatar, Al Rayyan, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'villagio',
      mainText: 'Villagio Mall',
      secondaryText: 'Al Waab, Doha, Qatar',
      fullText: 'Villagio Mall, Al Waab, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'aspire_zone',
      mainText: 'Aspire Zone',
      secondaryText: 'Doha, Qatar',
      fullText: 'Aspire Zone, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'industrial_area',
      mainText: 'Industrial Area',
      secondaryText: 'Doha, Qatar',
      fullText: 'Industrial Area, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'qatarenergyHQ',
      mainText: 'QatarEnergy HQ',
      secondaryText: 'West Bay, Doha, Qatar',
      fullText: 'QatarEnergy HQ, West Bay, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'hmc',
      mainText: 'Hamad Medical City',
      secondaryText: 'Al Rayyan, Qatar',
      fullText: 'Hamad Medical City, Al Rayyan, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'wakra',
      mainText: 'Al Wakra',
      secondaryText: 'Qatar',
      fullText: 'Al Wakra, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'rayyan',
      mainText: 'Al Rayyan',
      secondaryText: 'Qatar',
      fullText: 'Al Rayyan, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'place_vendome',
      mainText: 'Place Vendôme Mall',
      secondaryText: 'Lusail, Qatar',
      fullText: 'Place Vendôme Mall, Lusail, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'doha_festival_city',
      mainText: 'Doha Festival City',
      secondaryText: 'Al Rayyan, Qatar',
      fullText: 'Doha Festival City, Al Rayyan, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'metro_doha',
      mainText: 'Doha Metro — Gold Line',
      secondaryText: 'Doha, Qatar',
      fullText: 'Doha Metro Gold Line, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'madinat_khalifa',
      mainText: 'Madinat Khalifa',
      secondaryText: 'Doha, Qatar',
      fullText: 'Madinat Khalifa, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'al_messila',
      mainText: 'Al Messila',
      secondaryText: 'Doha, Qatar',
      fullText: 'Al Messila, Doha, Qatar',
    ),
    PlaceSuggestion(
      placeId: 'corniche',
      mainText: 'Corniche',
      secondaryText: 'Doha, Qatar',
      fullText: 'Corniche, Doha, Qatar',
    ),
  ];
}
