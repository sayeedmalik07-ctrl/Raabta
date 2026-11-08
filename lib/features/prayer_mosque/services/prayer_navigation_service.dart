import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:url_launcher/url_launcher.dart';

class PrayerNavigationService {
  const PrayerNavigationService._();

  static Uri directionsUri({
    required double latitude,
    required double longitude,
    required NavigationMapsApp app,
  }) {
    switch (app) {
      case NavigationMapsApp.appleMaps:
        return Uri.parse(
          'https://maps.apple.com/?daddr=$latitude,$longitude',
        );
      case NavigationMapsApp.waze:
        return Uri.parse(
          'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes',
        );
      case NavigationMapsApp.googleMaps:
        return Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
        );
    }
  }

  static Future<void> openDirections({
    required double latitude,
    required double longitude,
    NavigationMapsApp app = NavigationMapsApp.googleMaps,
  }) async {
    final uri = directionsUri(
      latitude: latitude,
      longitude: longitude,
      app: app,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
