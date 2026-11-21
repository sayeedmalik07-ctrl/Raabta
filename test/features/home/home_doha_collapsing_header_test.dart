import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/utils/home_doha_qatar_clock.dart';
import 'package:raabta/features/home/widgets/home_doha_collapsing_header.dart';
import 'package:raabta/features/home/widgets/home_doha_header_choreography.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:raabta/features/home/widgets/home_doha_skyline_greeting_row.dart';

HomeDohaHeaderConfig _testConfig() {
  return (
    locale: 'English',
    greetingLine: 'Hello',
    profileInitials: 'R',
    showGuestProfileIcon: false,
    profilePhotoUrl: null,
    notificationCount: 0,
    onProfileTap: () {},
    onNotificationTap: () {},
    onDiscoverQatar: () {},
    profileMenuSemanticsLabel: 'Profile',
    notificationSemanticsLabel: 'Notifications',
    searchRow: const SizedBox(height: 46, child: Text('search')),
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('HomeDohaTopZoneMetrics', () {
    test('progress at collapse range is 1', () {
      expect(
        HomeDohaTopZoneMetrics.progressFromShrinkOffset(172),
        1,
      );
    });

    test('snap mid range picks collapsed', () {
      expect(
        HomeDohaTopZoneMetrics.snapTargetOffset(100),
        HomeDohaTopZoneMetrics.collapseRange,
      );
    });

    test('interpolation at t=0, 0.5, 1', () {
      expect(HomeDohaTopZoneMetrics.progressFromShrinkOffset(0), 0);
      expect(
        HomeDohaTopZoneMetrics.progressFromShrinkOffset(
          HomeDohaTopZoneMetrics.collapseRange / 2,
        ),
        closeTo(0.5, 0.001),
      );
      expect(
        HomeDohaTopZoneMetrics.progressFromShrinkOffset(
          HomeDohaTopZoneMetrics.collapseRange,
        ),
        1,
      );

      expect(HomeDohaTopZoneMetrics.greetingOpacity(0), 1);
      expect(
        HomeDohaTopZoneMetrics.greetingOpacity(0.5),
        closeTo(1 - (0.5 / HomeDohaTopZoneMetrics.greetingFadeEndT), 0.001),
      );
      expect(HomeDohaTopZoneMetrics.greetingOpacity(0.55), 0);
      expect(HomeDohaTopZoneMetrics.greetingOpacity(1), 0);

      expect(HomeDohaTopZoneMetrics.searchRowTopY(0, reduceMotion: false), 68);
      expect(
        HomeDohaTopZoneMetrics.searchRowTopY(1, reduceMotion: false),
        10,
      );
      expect(HomeDohaTopZoneMetrics.searchRowTopY(0.5, reduceMotion: false),
          closeTo(39, 0.5));

      expect(HomeDohaTopZoneMetrics.skylineOpacity(0), 1);
      expect(HomeDohaTopZoneMetrics.skylineOpacity(1), 0);

      expect(HomeDohaTopZoneMetrics.glassBarOpacity(0), 0);
      expect(HomeDohaTopZoneMetrics.glassBarOpacity(1), 1);

      final anchorNight = HomeDohaTopZoneMetrics.celestialAnchorBesideHomeOrb(
        width: 390,
        collapseProgress: 0,
        part: DohaDayPart.night,
        qatarLocalNow: DateTime(2026, 3, 15, 21, 0),
        topSafeInset: 0,
      );
      expect(anchorNight.dy, lessThan(40));
      expect(anchorNight.dx, greaterThan(150));
      expect(anchorNight.dx, lessThan(240));
    });

    test('sun arc drifts east to west across day part', () {
      final prayer = HomeDohaPrayerAnchorTimes(
        fajr: DateTime(2025, 6, 15, 4, 30),
        sunrise: DateTime(2025, 6, 15, 5, 45),
        asr: DateTime(2025, 6, 15, 15, 20),
        maghrib: DateTime(2025, 6, 15, 18, 10),
      );

      final dawnStart = HomeDohaQatarClock.now(
        clock: () => DateTime(2025, 6, 15, 4, 30),
      );
      final dayMid = HomeDohaQatarClock.now(
        clock: () => DateTime(2025, 6, 15, 10, 0),
      );
      final goldenLate = HomeDohaQatarClock.now(
        clock: () => DateTime(2025, 6, 15, 17, 30),
      );

      final anchorDawnEarly = HomeDohaTopZoneMetrics.celestialAnchorBesideHomeOrb(
        width: 390,
        collapseProgress: 0,
        part: DohaDayPart.dawn,
        qatarLocalNow: dawnStart,
        prayerTimes: prayer,
      );
      final anchorDayMid = HomeDohaTopZoneMetrics.celestialAnchorBesideHomeOrb(
        width: 390,
        collapseProgress: 0,
        part: DohaDayPart.day,
        qatarLocalNow: dayMid,
        prayerTimes: prayer,
      );
      final anchorGolden = HomeDohaTopZoneMetrics.celestialAnchorBesideHomeOrb(
        width: 390,
        collapseProgress: 0,
        part: DohaDayPart.golden,
        qatarLocalNow: goldenLate,
        prayerTimes: prayer,
      );

      expect(anchorDawnEarly.dx, lessThan(anchorDayMid.dx));
      expect(anchorDayMid.dx, lessThan(anchorGolden.dx));

      expect(
        HomeDohaTopZoneMetrics.celestialSunArcProgress(
          part: DohaDayPart.day,
          qatarNow: dayMid,
          prayerTimes: null,
        ),
        closeTo(((10.0 - 6.75) / 8.5), 0.02),
      );
    });
  });

  group('HomeDohaTopZone', () {
    testWidgets('expanded shows greeting row', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeDohaTopZone.test(
                progress: 0,
                topSafeInset: 44,
                config: _testConfig(),
                layersAvailable: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HomeDohaSkylineGreetingRow), findsOneWidget);
      expect(find.text('search'), findsOneWidget);
    });

    testWidgets('collapsed hides greeting', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeDohaTopZone.test(
                progress: 1,
                topSafeInset: 44,
                config: _testConfig(),
                layersAvailable: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HomeDohaSkylineGreetingRow), findsNothing);
      expect(find.text('search'), findsOneWidget);
    });

    testWidgets('mid scroll keeps search visible', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeDohaTopZone.test(
                progress: 0.5,
                topSafeInset: 44,
                config: _testConfig(),
                layersAvailable: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('search'), findsOneWidget);
    });
  });
}