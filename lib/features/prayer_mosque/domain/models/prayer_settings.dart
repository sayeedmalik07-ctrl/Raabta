import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';

class PrayerSettings {
  const PrayerSettings({
    this.calculationMethod = PrayerCalculationMethod.qatarCalendarHouse,
    this.madhab = PrayerMadhab.shafi,
    this.timeFormat = PrayerTimeFormat.hour12,
    this.autoLocation = true,
    this.manualCity = 'Doha',
    this.manualLatitude = 25.2854,
    this.manualLongitude = 51.5310,
    this.locale = 'English',
    this.vacationMode = false,
    this.weekendOnly = false,
    this.perPrayerNotifications = const {},
    this.jumuahReminderOffset = JumuahReminderOffset.thirtyMinutes,
    this.favoriteMosqueId,
    this.cloudSyncEnabled = false,
    this.navigationApp = NavigationMapsApp.googleMaps,
  });

  final PrayerCalculationMethod calculationMethod;
  final PrayerMadhab madhab;
  final PrayerTimeFormat timeFormat;
  final bool autoLocation;
  final String manualCity;
  final double manualLatitude;
  final double manualLongitude;
  final String locale;
  final bool vacationMode;
  final bool weekendOnly;
  final Map<String, bool> perPrayerNotifications;
  final JumuahReminderOffset jumuahReminderOffset;
  final String? favoriteMosqueId;
  final bool cloudSyncEnabled;
  final NavigationMapsApp navigationApp;

  static const defaultNotifications = {
    'fajr': true,
    'sunrise': false,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
  };

  PrayerSettings copyWith({
    PrayerCalculationMethod? calculationMethod,
    PrayerMadhab? madhab,
    PrayerTimeFormat? timeFormat,
    bool? autoLocation,
    String? manualCity,
    double? manualLatitude,
    double? manualLongitude,
    String? locale,
    bool? vacationMode,
    bool? weekendOnly,
    Map<String, bool>? perPrayerNotifications,
    JumuahReminderOffset? jumuahReminderOffset,
    String? favoriteMosqueId,
    bool? cloudSyncEnabled,
    NavigationMapsApp? navigationApp,
  }) {
    return PrayerSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      timeFormat: timeFormat ?? this.timeFormat,
      autoLocation: autoLocation ?? this.autoLocation,
      manualCity: manualCity ?? this.manualCity,
      manualLatitude: manualLatitude ?? this.manualLatitude,
      manualLongitude: manualLongitude ?? this.manualLongitude,
      locale: locale ?? this.locale,
      vacationMode: vacationMode ?? this.vacationMode,
      weekendOnly: weekendOnly ?? this.weekendOnly,
      perPrayerNotifications:
          perPrayerNotifications ?? this.perPrayerNotifications,
      jumuahReminderOffset:
          jumuahReminderOffset ?? this.jumuahReminderOffset,
      favoriteMosqueId: favoriteMosqueId ?? this.favoriteMosqueId,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      navigationApp: navigationApp ?? this.navigationApp,
    );
  }

  Map<String, dynamic> toJson() => {
        'calculationMethod': calculationMethod.storageKey,
        'madhab': madhab.storageKey,
        'timeFormat': timeFormat.name,
        'autoLocation': autoLocation,
        'manualCity': manualCity,
        'manualLatitude': manualLatitude,
        'manualLongitude': manualLongitude,
        'locale': locale,
        'vacationMode': vacationMode,
        'weekendOnly': weekendOnly,
        'perPrayerNotifications': perPrayerNotifications,
        'jumuahReminderOffset': jumuahReminderOffset.name,
        'favoriteMosqueId': favoriteMosqueId,
        'cloudSyncEnabled': cloudSyncEnabled,
        'navigationApp': navigationApp.name,
      };

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    return PrayerSettings(
      calculationMethod: PrayerCalculationMethodExt.fromKey(
        json['calculationMethod'] as String?,
      ),
      madhab: PrayerMadhabExt.fromKey(json['madhab'] as String?),
      timeFormat: PrayerTimeFormat.values.firstWhere(
        (t) => t.name == json['timeFormat'],
        orElse: () => PrayerTimeFormat.hour12,
      ),
      autoLocation: json['autoLocation'] as bool? ?? true,
      manualCity: json['manualCity'] as String? ?? 'Doha',
      manualLatitude: (json['manualLatitude'] as num?)?.toDouble() ?? 25.2854,
      manualLongitude:
          (json['manualLongitude'] as num?)?.toDouble() ?? 51.5310,
      locale: json['locale'] as String? ?? 'English',
      vacationMode: json['vacationMode'] as bool? ?? false,
      weekendOnly: json['weekendOnly'] as bool? ?? false,
      perPrayerNotifications: Map<String, bool>.from(
        json['perPrayerNotifications'] as Map? ??
            PrayerSettings.defaultNotifications,
      ),
      jumuahReminderOffset: JumuahReminderOffset.values.firstWhere(
        (e) => e.name == json['jumuahReminderOffset'],
        orElse: () => JumuahReminderOffset.thirtyMinutes,
      ),
      favoriteMosqueId: json['favoriteMosqueId'] as String?,
      cloudSyncEnabled: json['cloudSyncEnabled'] as bool? ?? false,
      navigationApp: NavigationMapsApp.values.firstWhere(
        (e) => e.name == json['navigationApp'],
        orElse: () => NavigationMapsApp.googleMaps,
      ),
    );
  }
}
