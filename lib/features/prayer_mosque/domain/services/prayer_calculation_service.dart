import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/ramadan/prayer_times_service.dart';

/// Configurable prayer times using [adhan] with GCC-friendly defaults.
class PrayerCalculationService {
  const PrayerCalculationService();

  static const displayKeys = [
    'fajr',
    'sunrise',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  static const obligatoryKeys = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  CalculationParameters paramsFor(
    PrayerCalculationMethod method,
    PrayerMadhab madhab,
  ) {
    final CalculationParameters base;
    switch (method) {
      case PrayerCalculationMethod.ummAlQura:
        base = CalculationMethod.umm_al_qura.getParameters();
      case PrayerCalculationMethod.muslimWorldLeague:
        base = CalculationMethod.muslim_world_league.getParameters();
      case PrayerCalculationMethod.isna:
        base = CalculationMethod.north_america.getParameters();
      case PrayerCalculationMethod.qatarCalendarHouse:
        base = CalculationMethod.umm_al_qura.getParameters();
        base.fajrAngle = 18;
        base.ishaAngle = 17;
    }
    base.madhab =
        madhab == PrayerMadhab.hanafi ? Madhab.hanafi : Madhab.shafi;
    return base;
  }

  PrayerScheduleDay scheduleFor({
    required double latitude,
    required double longitude,
    required String locationLabel,
    PrayerCalculationMethod method = PrayerCalculationMethod.qatarCalendarHouse,
    PrayerMadhab madhab = PrayerMadhab.shafi,
    DateTime? date,
  }) {
    final localDate = date ?? DateTime.now();
    final components = DateComponents.from(localDate);
    final coords = Coordinates(latitude, longitude);
    final params = paramsFor(method, madhab);
    final times = PrayerTimes(coords, components, params);

    final entries = <PrayerScheduleEntry>[
      _entry('fajr', Prayer.fajr, times.fajr),
      _entry('sunrise', Prayer.sunrise, times.sunrise, isSunrise: true),
      _entry('dhuhr', Prayer.dhuhr, times.dhuhr),
      _entry('asr', Prayer.asr, times.asr),
      _entry('maghrib', Prayer.maghrib, times.maghrib),
      _entry('isha', Prayer.isha, times.isha),
    ];

    return PrayerScheduleDay(
      date: DateTime(localDate.year, localDate.month, localDate.day),
      entries: entries,
      locationLabel: locationLabel,
      latitude: latitude,
      longitude: longitude,
    );
  }

  PrayerScheduleEntry _entry(
    String key,
    Prayer prayer,
    DateTime time, {
    bool isSunrise = false,
  }) {
    return PrayerScheduleEntry(
      key: key,
      labelKey: 'prayer_$key',
      emoji: PrayerTimesService.prayerEmoji(prayer),
      time: time,
      prayer: prayer,
      isSunrise: isSunrise,
    );
  }

  double qiblaBearing(double latitude, double longitude) {
    return Qibla(Coordinates(latitude, longitude)).direction;
  }

  double distanceToKaabaKm(double latitude, double longitude) {
    return Geolocator.distanceBetween(
          latitude,
          longitude,
          21.4225,
          39.8262,
        ) /
        1000;
  }
}
