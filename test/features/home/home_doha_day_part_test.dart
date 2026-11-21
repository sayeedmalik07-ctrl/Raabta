import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';

void main() {
  final anchors = HomeDohaPrayerAnchorTimes(
    fajr: DateTime(2025, 6, 15, 4, 30),
    sunrise: DateTime(2025, 6, 15, 5, 45),
    asr: DateTime(2025, 6, 15, 15, 20),
    maghrib: DateTime(2025, 6, 15, 18, 10),
  );

  group('dohaDayPartFromPrayerTimes', () {
    test('before fajr is night', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: DateTime(2025, 6, 15, 4, 29, 59),
          prayerTimes: anchors,
        ),
        DohaDayPart.night,
      );
    });

    test('at fajr is dawn', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: anchors.fajr!,
          prayerTimes: anchors,
        ),
        DohaDayPart.dawn,
      );
    });

    test('sunrise + 29m is still dawn', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: anchors.sunrise!.add(const Duration(minutes: 29)),
          prayerTimes: anchors,
        ),
        DohaDayPart.dawn,
      );
    });

    test('sunrise + 30m is day', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: anchors.sunrise!.add(const Duration(minutes: 30)),
          prayerTimes: anchors,
        ),
        DohaDayPart.day,
      );
    });

    test('just before asr is day', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: anchors.asr!.subtract(const Duration(seconds: 1)),
          prayerTimes: anchors,
        ),
        DohaDayPart.day,
      );
    });

    test('at asr is golden', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: anchors.asr!,
          prayerTimes: anchors,
        ),
        DohaDayPart.golden,
      );
    });

    test('maghrib + 19m is still golden', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: anchors.maghrib!.add(const Duration(minutes: 19)),
          prayerTimes: anchors,
        ),
        DohaDayPart.golden,
      );
    });

    test('maghrib + 20m is night', () {
      expect(
        dohaDayPartFromPrayerTimes(
          now: anchors.maghrib!.add(const Duration(minutes: 20)),
          prayerTimes: anchors,
        ),
        DohaDayPart.night,
      );
    });
  });

  group('dohaDayPartFromClock', () {
    test('04:00 is night', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 4, 0)),
        DohaDayPart.night,
      );
    });

    test('05:00 is dawn', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 5, 0)),
        DohaDayPart.dawn,
      );
    });

    test('06:44 is dawn', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 6, 44)),
        DohaDayPart.dawn,
      );
    });

    test('06:45 is day', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 6, 45)),
        DohaDayPart.day,
      );
    });

    test('15:14 is day', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 15, 14)),
        DohaDayPart.day,
      );
    });

    test('15:15 is golden', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 15, 15)),
        DohaDayPart.golden,
      );
    });

    test('18:29 is golden', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 18, 29)),
        DohaDayPart.golden,
      );
    });

    test('18:30 is night', () {
      expect(
        dohaDayPartFromClock(DateTime(2025, 6, 15, 18, 30)),
        DohaDayPart.night,
      );
    });
  });

  group('resolveDohaDayPart missing anchors', () {
    test('falls back to clock when fajr missing', () {
      expect(
        resolveDohaDayPart(
          now: DateTime(2025, 6, 15, 7, 0),
          prayerTimes: const HomeDohaPrayerAnchorTimes(
            sunrise: null,
          ),
        ),
        DohaDayPart.day,
      );
    });

    test('null prayerTimes uses clock', () {
      expect(
        resolveDohaDayPart(
          now: DateTime(2025, 6, 15, 22, 0),
          prayerTimes: null,
        ),
        DohaDayPart.night,
      );
    });
  });

  group('nextDohaDayPartBoundary', () {
    test('prayer: next after dawn start is sunrise+30', () {
      final next = nextDohaDayPartBoundary(
        now: DateTime(2025, 6, 15, 4, 45),
        prayerTimes: anchors,
      );
      expect(next, anchors.sunrise!.add(const Duration(minutes: 30)));
    });

    test('clock: before dawn next is 05:00', () {
      final next = nextDohaDayPartBoundary(
        now: DateTime(2025, 6, 15, 3, 0),
        prayerTimes: null,
      );
      expect(next, DateTime(2025, 6, 15, 5, 0));
    });
  });
}