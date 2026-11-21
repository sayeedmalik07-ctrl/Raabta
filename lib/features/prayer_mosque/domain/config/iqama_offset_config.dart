/// Estimated congregation (Iqama) offsets from Adhan — Qatar convention defaults.
///
/// These are **not** mosque-confirmed times. Display with estimate labeling only.
abstract final class IqamaOffsetConfig {
  /// Minutes after Adhan for estimated congregation start, by prayer key.
  static const offsetsMinutes = <String, int>{
    'fajr': 20,
    'dhuhr': 10,
    'asr': 10,
    'maghrib': 5,
    'isha': 10,
  };

  static Duration? offsetForPrayerKey(String key) {
    final minutes = offsetsMinutes[key];
    if (minutes == null) return null;
    return Duration(minutes: minutes);
  }
}
