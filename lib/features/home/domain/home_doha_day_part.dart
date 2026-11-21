import 'package:flutter/foundation.dart';
import 'package:raabta/features/home/domain/home_doha_scene_palette.dart';

/// Scene time-of-day band for the Home Doha top zone (decision D3).
enum DohaDayPart {
  dawn,
  day,
  golden,
  night,
}

/// How [resolveDohaDayPart] chose its result.
enum DohaDayPartSource {
  prayerTimes,
  clockFallback,
  debugOverride,
}

/// Prayer anchors used for day-part rules (local wall-clock [DateTime]s).
@immutable
class HomeDohaPrayerAnchorTimes {
  const HomeDohaPrayerAnchorTimes({
    this.fajr,
    this.sunrise,
    this.asr,
    this.maghrib,
  });

  final DateTime? fajr;
  final DateTime? sunrise;
  final DateTime? asr;
  final DateTime? maghrib;

  /// True when all prayer anchors required by D3 are present.
  bool get isComplete =>
      fajr != null && sunrise != null && asr != null && maghrib != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeDohaPrayerAnchorTimes &&
          fajr == other.fajr &&
          sunrise == other.sunrise &&
          asr == other.asr &&
          maghrib == other.maghrib;

  @override
  int get hashCode => Object.hash(fajr, sunrise, asr, maghrib);
}

/// Clock-band fallback boundaries (local time, decision D3).
@visibleForTesting
const kDohaDayPartClockDawnStartHour = 5;
@visibleForTesting
const kDohaDayPartClockDawnStartMinute = 0;
@visibleForTesting
const kDohaDayPartClockDayStartHour = 6;
@visibleForTesting
const kDohaDayPartClockDayStartMinute = 45;
@visibleForTesting
const kDohaDayPartClockGoldenStartHour = 15;
@visibleForTesting
const kDohaDayPartClockGoldenStartMinute = 15;
@visibleForTesting
const kDohaDayPartClockNightStartHour = 18;
@visibleForTesting
const kDohaDayPartClockNightStartMinute = 30;

const _dawnAfterSunrise = Duration(minutes: 30);
const _goldenAfterMaghrib = Duration(minutes: 20);

/// Resolves the active day part at [now]. Uses [prayerTimes] when complete,
/// otherwise [dohaDayPartFromClock].
DohaDayPart resolveDohaDayPart({
  required DateTime now,
  HomeDohaPrayerAnchorTimes? prayerTimes,
}) {
  if (prayerTimes != null && prayerTimes.isComplete) {
    return dohaDayPartFromPrayerTimes(now: now, prayerTimes: prayerTimes);
  }
  return dohaDayPartFromClock(now);
}

/// Prayer-based bands: Dawn → Day → Golden → Night (D3).
@visibleForTesting
DohaDayPart dohaDayPartFromPrayerTimes({
  required DateTime now,
  required HomeDohaPrayerAnchorTimes prayerTimes,
}) {
  assert(prayerTimes.isComplete);
  final fajr = prayerTimes.fajr!;
  final dawnEnd = prayerTimes.sunrise!.add(_dawnAfterSunrise);
  final asr = prayerTimes.asr!;
  final goldenEnd = prayerTimes.maghrib!.add(_goldenAfterMaghrib);

  if (now.isBefore(fajr)) return DohaDayPart.night;
  if (now.isBefore(dawnEnd)) return DohaDayPart.dawn;
  if (now.isBefore(asr)) return DohaDayPart.day;
  if (now.isBefore(goldenEnd)) return DohaDayPart.golden;
  return DohaDayPart.night;
}

/// Clock fallback when prayer anchors are incomplete (D3).
@visibleForTesting
DohaDayPart dohaDayPartFromClock(DateTime now) {
  final dawnStart = _clockTime(
    now,
    kDohaDayPartClockDawnStartHour,
    kDohaDayPartClockDawnStartMinute,
  );
  final dayStart = _clockTime(
    now,
    kDohaDayPartClockDayStartHour,
    kDohaDayPartClockDayStartMinute,
  );
  final goldenStart = _clockTime(
    now,
    kDohaDayPartClockGoldenStartHour,
    kDohaDayPartClockGoldenStartMinute,
  );
  final nightStart = _clockTime(
    now,
    kDohaDayPartClockNightStartHour,
    kDohaDayPartClockNightStartMinute,
  );

  if (!now.isBefore(dawnStart) && now.isBefore(dayStart)) {
    return DohaDayPart.dawn;
  }
  if (!now.isBefore(dayStart) && now.isBefore(goldenStart)) {
    return DohaDayPart.day;
  }
  if (!now.isBefore(goldenStart) && now.isBefore(nightStart)) {
    return DohaDayPart.golden;
  }
  return DohaDayPart.night;
}

DateTime _clockTime(DateTime ref, int hour, int minute) =>
    DateTime(ref.year, ref.month, ref.day, hour, minute);

/// Next local instant when [resolveDohaDayPart] would change (or null if unknown).
DateTime? nextDohaDayPartBoundary({
  required DateTime now,
  HomeDohaPrayerAnchorTimes? prayerTimes,
}) {
  if (prayerTimes != null && prayerTimes.isComplete) {
    return _nextPrayerBoundary(now: now, prayerTimes: prayerTimes);
  }
  return _nextClockBoundary(now);
}

DateTime? _nextPrayerBoundary({
  required DateTime now,
  required HomeDohaPrayerAnchorTimes prayerTimes,
}) {
  final fajr = prayerTimes.fajr!;
  final dawnEnd = prayerTimes.sunrise!.add(_dawnAfterSunrise);
  final asr = prayerTimes.asr!;
  final goldenEnd = prayerTimes.maghrib!.add(_goldenAfterMaghrib);
  final nextFajr = fajr.add(const Duration(days: 1));

  final transitions = <DateTime>[fajr, dawnEnd, asr, goldenEnd, nextFajr];
  transitions.sort();
  for (final t in transitions) {
    if (t.isAfter(now)) return t;
  }
  return null;
}

DateTime? _nextClockBoundary(DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  final tomorrow = day.add(const Duration(days: 1));
  final transitions = <DateTime>[
    _clockTime(day, kDohaDayPartClockDawnStartHour, kDohaDayPartClockDawnStartMinute),
    _clockTime(day, kDohaDayPartClockDayStartHour, kDohaDayPartClockDayStartMinute),
    _clockTime(
      day,
      kDohaDayPartClockGoldenStartHour,
      kDohaDayPartClockGoldenStartMinute,
    ),
    _clockTime(
      day,
      kDohaDayPartClockNightStartHour,
      kDohaDayPartClockNightStartMinute,
    ),
    _clockTime(
      tomorrow,
      kDohaDayPartClockDawnStartHour,
      kDohaDayPartClockDawnStartMinute,
    ),
  ];
  transitions.sort();
  for (final t in transitions) {
    if (t.isAfter(now)) return t;
  }
  return null;
}

/// Delay until the next boundary (minimum 1 second to avoid zero-length timers).
@visibleForTesting
Duration dohaDayPartDelayUntilNextBoundary({
  required DateTime now,
  HomeDohaPrayerAnchorTimes? prayerTimes,
}) {
  final next = nextDohaDayPartBoundary(now: now, prayerTimes: prayerTimes);
  if (next == null) return const Duration(hours: 12);
  final delay = next.difference(now);
  if (delay <= Duration.zero) return const Duration(seconds: 1);
  return delay;
}

/// Palette for UI layers (Batch C consumer).
DohaScenePalette dohaScenePaletteForPart(DohaDayPart part) =>
    DohaScenePalette.forPart(part);