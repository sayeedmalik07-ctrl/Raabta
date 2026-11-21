import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/providers/home_doha_day_part_provider.dart';

void main() {
  final realAnchors = HomeDohaPrayerAnchorTimes(
    fajr: DateTime(2025, 6, 15, 4, 30),
    sunrise: DateTime(2025, 6, 15, 5, 45),
    asr: DateTime(2025, 6, 15, 15, 20),
    maghrib: DateTime(2025, 6, 15, 18, 10),
  );

  group('homeDohaDayPartProvider', () {
    test('notifier resolves prayer bands from strip anchors', () {
      final container = ProviderContainer();
      final notifier = container.read(homeDohaDayPartProvider.notifier);
      notifier.debugSetPrayerAnchors(realAnchors);
      notifier.debugSetNow(() => DateTime(2025, 6, 15, 6, 15));

      final state = container.read(homeDohaDayPartProvider);
      expect(state.part, DohaDayPart.day);
      expect(state.source, DohaDayPartSource.prayerTimes);
      container.dispose();
    });

    test('debug override forces part', () {
      final container = ProviderContainer();
      final notifier = container.read(homeDohaDayPartProvider.notifier);
      notifier.debugForceDayPart(DohaDayPart.night);

      final state = container.read(homeDohaDayPartProvider);
      expect(state.part, DohaDayPart.night);
      expect(state.source, DohaDayPartSource.debugOverride);

      homeDohaDayPartDebugOverride = null;
      container.dispose();
    });

    test('delay until next boundary matches prayer sunrise+30', () {
      expect(
        dohaDayPartDelayUntilNextBoundary(
          now: DateTime(2025, 6, 15, 4, 45),
          prayerTimes: realAnchors,
        ),
        const Duration(minutes: 90),
      );
    });
  });
}