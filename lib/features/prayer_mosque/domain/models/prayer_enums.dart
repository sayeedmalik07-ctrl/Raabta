/// Prayer & Mosque feature enums.
enum PrayerCalculationMethod {
  ummAlQura,
  muslimWorldLeague,
  qatarCalendarHouse,
  isna,
}

enum PrayerMadhab {
  hanafi,
  shafi,
}

enum PrayerTimeFormat {
  hour12,
  hour24,
}

enum PrayerTrackingStatus {
  prayed,
  missed,
  late,
  congregationHome,
  congregationMosque,
}

enum JumuahReminderOffset {
  oneHour,
  thirtyMinutes,
  fifteenMinutes,
  custom,
}

enum NavigationMapsApp {
  googleMaps,
  appleMaps,
  waze,
}

extension JumuahReminderOffsetExt on JumuahReminderOffset {
  int get minutesBefore {
    switch (this) {
      case JumuahReminderOffset.oneHour:
        return 60;
      case JumuahReminderOffset.thirtyMinutes:
        return 30;
      case JumuahReminderOffset.fifteenMinutes:
        return 15;
      case JumuahReminderOffset.custom:
        return 45;
    }
  }
}

extension PrayerCalculationMethodExt on PrayerCalculationMethod {
  String get storageKey => name;

  static PrayerCalculationMethod fromKey(String? key) {
    return PrayerCalculationMethod.values.firstWhere(
      (e) => e.name == key,
      orElse: () => PrayerCalculationMethod.qatarCalendarHouse,
    );
  }
}

extension PrayerMadhabExt on PrayerMadhab {
  String get storageKey => name;

  static PrayerMadhab fromKey(String? key) {
    return PrayerMadhab.values.firstWhere(
      (e) => e.name == key,
      orElse: () => PrayerMadhab.shafi,
    );
  }
}
