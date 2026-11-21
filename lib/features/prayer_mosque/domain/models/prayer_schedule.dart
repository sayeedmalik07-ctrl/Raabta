import 'package:adhan/adhan.dart';

class PrayerScheduleEntry {
  const PrayerScheduleEntry({
    required this.key,
    required this.labelKey,
    required this.emoji,
    required this.time,
    required this.prayer,
    this.isSunrise = false,
  });

  final String key;
  final String labelKey;
  final String emoji;
  final DateTime time;
  final Prayer prayer;
  final bool isSunrise;

  bool get isObligatory => !isSunrise && prayer != Prayer.sunrise;
}

class PrayerScheduleDay {
  const PrayerScheduleDay({
    required this.date,
    required this.entries,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
  });

  final DateTime date;
  final List<PrayerScheduleEntry> entries;
  final String locationLabel;
  final double latitude;
  final double longitude;

  PrayerScheduleEntry? get currentPrayer => currentPrayerAt(DateTime.now());

  PrayerScheduleEntry? currentPrayerAt(DateTime now) {
    PrayerScheduleEntry? last;
    for (final entry in entries) {
      if (entry.time.isAfter(now)) break;
      last = entry;
    }
    return last;
  }

  PrayerScheduleEntry? get nextPrayer => nextPrayerAt(DateTime.now());

  PrayerScheduleEntry? nextPrayerAt(DateTime now) {
    for (final entry in entries) {
      if (entry.time.isAfter(now)) return entry;
    }
    return entries.isNotEmpty ? entries.first : null;
  }

  Duration? timeUntilNext() => timeUntilNextAt(DateTime.now());

  Duration? timeUntilNextAt(DateTime now) {
    final next = nextPrayerAt(now);
    if (next == null) return null;
    final diff = next.time.difference(now);
    if (diff.isNegative && next.key == 'fajr') {
      final tomorrowFajr = next.time.add(const Duration(days: 1));
      return tomorrowFajr.difference(now);
    }
    return diff.isNegative ? Duration.zero : diff;
  }

  PrayerScheduleEntry? entryFor(String key) {
    for (final entry in entries) {
      if (entry.key == key) return entry;
    }
    return null;
  }

  /// Progress from last obligatory prayer to next (0.0–1.0).
  double? progressUntilNext() => progressUntilNextAt(DateTime.now());

  double? progressUntilNextAt(DateTime now) {
    PrayerScheduleEntry? previous;
    PrayerScheduleEntry? upcoming;
    for (final entry in entries) {
      if (entry.isSunrise) continue;
      if (entry.time.isAfter(now)) {
        upcoming = entry;
        break;
      }
      previous = entry;
    }
    upcoming ??= entries.where((e) => !e.isSunrise).firstOrNull;
    if (previous == null || upcoming == null) return null;

    var start = previous.time;
    var end = upcoming.time;
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }
    final total = end.difference(start).inSeconds;
    if (total <= 0) return null;
    final elapsed = now.difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  DateTime? get sunsetTime => entryFor('maghrib')?.time;

  DateTime? get islamicMidnight {
    final maghrib = entryFor('maghrib')?.time;
    final fajr = entryFor('fajr')?.time;
    if (maghrib == null || fajr == null) return null;
    final nextFajr = fajr.isAfter(maghrib)
        ? fajr
        : fajr.add(const Duration(days: 1));
    final night = nextFajr.difference(maghrib);
    return maghrib.add(Duration(milliseconds: night.inMilliseconds ~/ 2));
  }

  DateTime? get lastThirdOfNight {
    final maghrib = entryFor('maghrib')?.time;
    final fajr = entryFor('fajr')?.time;
    if (maghrib == null || fajr == null) return null;
    final nextFajr = fajr.isAfter(maghrib)
        ? fajr
        : fajr.add(const Duration(days: 1));
    final night = nextFajr.difference(maghrib);
    return nextFajr.subtract(
      Duration(milliseconds: night.inMilliseconds ~/ 3),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}

class IslamicDailyContent {
  const IslamicDailyContent({
    required this.quote,
    required this.hadith,
    required this.dua,
    required this.verse,
    required this.morningAzkar,
    required this.eveningAzkar,
  });

  final String quote;
  final String hadith;
  final String dua;
  final String verse;
  final String morningAzkar;
  final String eveningAzkar;
}

class IslamicCalendarEvent {
  const IslamicCalendarEvent({
    required this.titleKey,
    required this.hijriMonth,
    required this.hijriDay,
    required this.gregorianDate,
    required this.emoji,
  });

  final String titleKey;
  final int hijriMonth;
  final int hijriDay;
  final DateTime gregorianDate;
  final String emoji;
}
