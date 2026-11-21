import 'package:raabta/features/flight_checker/domain/corridor_flight_catalog.dart';

enum FlightSearchProvider { googleFlights, skyscanner }

/// Builds external search URLs — no in-app WebView, no pricing APIs.
abstract final class FlightDeepLinkBuilder {
  static const _origin = CorridorFlightCatalog.originIata;

  /// Google Flights travel search query (URL-based pre-fill).
  static Uri googleFlights({
    required String destinationIata,
  }) {
    final dest = destinationIata.toUpperCase();
    final query = Uri.encodeComponent('Flights from $_origin to $dest');
    return Uri.parse('https://www.google.com/travel/flights?q=$query');
  }

  /// Skyscanner route URL — lowercase IATA codes in path.
  static Uri skyscanner({
    required String destinationIata,
  }) {
    final origin = _origin.toLowerCase();
    final dest = destinationIata.toLowerCase();
    return Uri.parse(
      'https://www.skyscanner.net/transport/flights/$origin/$dest/',
    );
  }

  static Uri forProvider({
    required FlightSearchProvider provider,
    required String destinationIata,
  }) {
    return switch (provider) {
      FlightSearchProvider.googleFlights =>
        googleFlights(destinationIata: destinationIata),
      FlightSearchProvider.skyscanner =>
        skyscanner(destinationIata: destinationIata),
    };
  }
}
