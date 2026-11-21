import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/providers/home_doha_day_part_provider.dart';
import 'package:raabta/features/home/widgets/home_doha_collapsing_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedHomeDohaDayPartNotifier extends HomeDohaDayPartNotifier {
  @override
  HomeDohaDayPartState build() {
    return HomeDohaDayPartState(
      part: DohaDayPart.golden,
      source: DohaDayPartSource.clockFallback,
      resolvedAt: DateTime(2024, 6, 15, 12),
    );
  }
}

HomeDohaHeaderConfig _goldenConfig() {
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
    searchRow: const SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0x33FFFFFF),
          borderRadius: BorderRadius.all(Radius.circular(23)),
        ),
        child: Center(child: Text('Search')),
      ),
    ),
  );
}

Future<void> _pumpTopZone(
  WidgetTester tester, {
  required double progress,
  required bool light,
}) async {
  AppColors.applyBrightness(light);
  homeDohaDayPartDebugOverride = DohaDayPart.golden;
  const topInset = 44.0;
  const width = 390.0;
  const height = topInset + 236;

  await tester.binding.setSurfaceSize(const Size(width, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeDohaDayPartProvider.overrideWith(_FixedHomeDohaDayPartNotifier.new),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: light ? Brightness.light : Brightness.dark,
        ),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: Key('doha_top_zone_t${(progress * 100).round()}'),
              child: SizedBox(
                width: width,
                height: height,
                child: HomeDohaTopZone.test(
                  progress: progress,
                  topSafeInset: topInset,
                  config: _goldenConfig(),
                  layersAvailable: false,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    AppColors.applyBrightness(false);
    homeDohaDayPartDebugOverride = null;
  });

  group('Doha top zone goldens', () {
    testWidgets('expanded light', (tester) async {
      await _pumpTopZone(tester, progress: 0, light: true);
      await expectLater(
        find.byKey(const Key('doha_top_zone_t0')),
        matchesGoldenFile('goldens/home_doha_top_zone_expanded_light_390.png'),
      );
    });

    testWidgets('expanded dark', (tester) async {
      await _pumpTopZone(tester, progress: 0, light: false);
      await expectLater(
        find.byKey(const Key('doha_top_zone_t0')),
        matchesGoldenFile('goldens/home_doha_top_zone_expanded_dark_390.png'),
      );
    });

    testWidgets('collapsed light', (tester) async {
      await _pumpTopZone(tester, progress: 1, light: true);
      await expectLater(
        find.byKey(const Key('doha_top_zone_t100')),
        matchesGoldenFile('goldens/home_doha_top_zone_collapsed_light_390.png'),
      );
    });

    testWidgets('collapsed dark', (tester) async {
      await _pumpTopZone(tester, progress: 1, light: false);
      await expectLater(
        find.byKey(const Key('doha_top_zone_t100')),
        matchesGoldenFile('goldens/home_doha_top_zone_collapsed_dark_390.png'),
      );
    });
  });
}