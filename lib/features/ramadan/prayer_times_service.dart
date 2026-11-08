import 'package:adhan/adhan.dart';

/// Offline prayer times using Umm al-Qura (Saudi / Gulf standard).
class PrayerTimesService {
  PrayerTimesService._();

  /// Default coordinates: Doha, Qatar.
  static const defaultLatitude = 25.2854;
  static const defaultLongitude = 51.5310;

  static CalculationParameters get _params =>
      CalculationMethod.umm_al_qura.getParameters();

  static PrayerTimes forCoordinates({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) {
    final localDate = date ?? DateTime.now();
    final components = DateComponents.from(localDate);
    final coords = Coordinates(latitude, longitude);
    return PrayerTimes(coords, components, _params);
  }

  static Map<Prayer, DateTime> namedTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) {
    final times = forCoordinates(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
    return {
      Prayer.fajr: times.fajr,
      Prayer.sunrise: times.sunrise,
      Prayer.dhuhr: times.dhuhr,
      Prayer.asr: times.asr,
      Prayer.maghrib: times.maghrib,
      Prayer.isha: times.isha,
    };
  }

  static String prayerLabel(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      case Prayer.none:
        return '';
    }
  }

  static String prayerEmoji(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return '🌅';
      case Prayer.sunrise:
        return '☀️';
      case Prayer.dhuhr:
        return '🌤️';
      case Prayer.asr:
        return '🌇';
      case Prayer.maghrib:
        return '🌆';
      case Prayer.isha:
        return '🌙';
      case Prayer.none:
        return '';
    }
  }

  /// Prayers shown in the daily list (excludes sunrise).
  static const displayPrayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];
}
