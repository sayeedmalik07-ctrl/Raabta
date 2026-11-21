import 'package:geolocator/geolocator.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';

/// Location normalization for post forms.
class PostLocationEngine {
  const PostLocationEngine();

  List<String> qatarAreas() => const [
        'Al Khor',
        'Doha',
        'Lusail',
        'Al Wakrah',
        'Mesaieed',
        'Al Rayyan',
        'The Pearl',
        'West Bay',
      ];

  String normalizeArea(String raw) => raw.trim();

  /// Maps GPS label (e.g. "Doha, Qatar") to a [qatarAreas] entry when possible.
  String matchAreaFromGpsLabel(String label) {
    final normalized = label.toLowerCase();
    final areas = [...qatarAreas()]..sort((a, b) => b.length.compareTo(a.length));
    for (final area in areas) {
      if (normalized.contains(area.toLowerCase())) return area;
    }
    if (normalized.contains('qatar')) return 'Doha';
    return qatarAreas().first;
  }

  /// One-tap current location via [PrayerLocationService].
  Future<String?> resolveCurrentArea() async {
    final service = PrayerLocationService();
    if (!await service.ensurePermission()) return null;
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
    final result = service.locationFromPosition(position);
    return matchAreaFromGpsLabel(result.label);
  }
}
