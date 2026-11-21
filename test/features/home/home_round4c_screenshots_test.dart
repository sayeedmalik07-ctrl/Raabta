library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/home_personalization_providers.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/features/home/utils/home_responsive_layout.dart';
import 'package:raabta/features/home/widgets/home_essential_tools_zone.dart';
import 'package:raabta/features/home/widgets/home_qatar_life_zone.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Golden PNGs for Round 4C are written under [goldenSubdir] via `--update-goldens`.
const goldenSubdir = '../../../docs/round4c_screens';

Future<void> _pumpShot(
  WidgetTester tester, {
  required double width,
  required bool light,
  required String locale,
  required bool rtl,
}) async {
  AppColors.applyBrightness(light);
  await tester.binding.setSurfaceSize(Size(width, 920));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final inset = HomeResponsiveLayout.contentLeadingInset(width);
  final contentWidth = width - 2 * inset;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userLanguageProvider.overrideWith((ref) => locale),
        homeQatarLifeRoutesProvider.overrideWith(
          (ref) => HomeEssentialToolsZone.qatarLifeRoutes,
        ),
        for (final engine in TruthChipEngine.values)
          truthChipStatusProvider(engine).overrideWith((ref) async {
            return TruthChipStatus(
              engine: engine,
              state: TruthChipState.invite,
              tone: TruthChipTone.neutral,
              titleKey: 'tool_eosb_title',
              statusText: 'Check',
              freshnessText: '',
              deepLink: engine.homeRoute,
            );
          }),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: light ? Brightness.light : Brightness.dark),
        home: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData(size: Size(width, 920)),
            child: RepaintBoundary(
              key: const Key('round4c_responsive_shot'),
              child: ColoredBox(
                color: light
                    ? const Color(0xFFF5F7FA)
                    : const Color(0xFF0D1117),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: inset, vertical: 16),
                  child: SizedBox(
                    width: contentWidth,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HomeEssentialToolsZone(
                          routes: HomeEssentialToolsZone.truthEngineRoutes,
                          overlineKey: 'home_truth_engines_overline',
                          titleKey: 'home_truth_engines',
                          subtitleKey: 'home_truth_engines_sub',
                          truthEngineSection: true,
                          layout: HomeToolsLayout.grid,
                        ),
                        SizedBox(height: 28),
                        HomeQatarLifeZone(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final shots = <({String file, double width, bool light, String locale, bool rtl})>[
  (file: '360_light_en', width: 360, light: true, locale: 'English', rtl: false),
  (file: '390_light_en', width: 390, light: true, locale: 'English', rtl: false),
  (file: '390_dark_ar', width: 390, light: false, locale: 'Arabic', rtl: true),
  (file: '600_light_en', width: 600, light: true, locale: 'English', rtl: false),
  (file: '1024_light_en', width: 1024, light: true, locale: 'English', rtl: false),
  (file: '1280_dark_en', width: 1280, light: false, locale: 'English', rtl: false),
];

  for (final shot in shots) {
    testWidgets('golden ${shot.file}', (tester) async {
      await _pumpShot(
        tester,
        width: shot.width,
        light: shot.light,
        locale: shot.locale,
        rtl: shot.rtl,
      );
      await expectLater(
        find.byKey(const Key('round4c_responsive_shot')),
        matchesGoldenFile('$goldenSubdir/${shot.file}.png'),
      );
    });
  }
}