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

typedef _MatrixCase = ({
  double width,
  double height,
  double textScale,
  bool light,
  bool rtl,
  String locale,
});

const _matrixCases = <_MatrixCase>[
  (width: 360, height: 800, textScale: 1.0, light: true, rtl: false, locale: 'English'),
  (width: 390, height: 844, textScale: 1.3, light: true, rtl: false, locale: 'English'),
  (width: 390, height: 844, textScale: 1.0, light: false, rtl: true, locale: 'Arabic'),
  (width: 600, height: 900, textScale: 1.0, light: true, rtl: false, locale: 'English'),
  (width: 1024, height: 900, textScale: 1.0, light: true, rtl: false, locale: 'English'),
  (width: 1280, height: 900, textScale: 1.3, light: false, rtl: false, locale: 'English'),
  (width: 844, height: 390, textScale: 1.0, light: true, rtl: false, locale: 'English'),
];

Future<void> _pumpResponsiveHarness(
  WidgetTester tester, {
  required _MatrixCase matrix,
}) async {
  AppColors.applyBrightness(matrix.light);

  await tester.binding.setSurfaceSize(Size(matrix.width, matrix.height));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final horizontalInset =
      HomeResponsiveLayout.contentLeadingInset(matrix.width);
  final contentWidth = matrix.width - 2 * horizontalInset;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userLanguageProvider.overrideWith((ref) => matrix.locale),
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
        theme: ThemeData(brightness: matrix.light ? Brightness.light : Brightness.dark),
        home: Directionality(
          textDirection: matrix.rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData(
              size: Size(matrix.width, matrix.height),
              textScaler: TextScaler.linear(matrix.textScale),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalInset),
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
  await tester.pumpAndSettle(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Round 4C responsive matrix', () {
    for (final matrix in _matrixCases) {
      final label =
          '${matrix.width.toInt()}x${matrix.height.toInt()}_'
          '${matrix.light ? 'light' : 'dark'}_'
          '${matrix.locale}_'
          's${matrix.textScale.toStringAsFixed(1)}'
          '${matrix.rtl ? '_rtl' : ''}';

      testWidgets('no overflow: $label', (tester) async {
        await _pumpResponsiveHarness(tester, matrix: matrix);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('truth grid is 1x4 at 1024 content', (tester) async {
      const matrix = (
        width: 1024.0,
        height: 900.0,
        textScale: 1.0,
        light: true,
        rtl: false,
        locale: 'English',
      );
      await _pumpResponsiveHarness(tester, matrix: matrix);

      final grid = tester.widget<GridView>(find.byType(GridView).first);
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        4,
      );
    });

    testWidgets('Qatar Life uses ListView on 360', (tester) async {
      const matrix = (
        width: 360.0,
        height: 800.0,
        textScale: 1.0,
        light: true,
        rtl: false,
        locale: 'English',
      );
      await _pumpResponsiveHarness(tester, matrix: matrix);
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('Qatar Life uses Row on 600', (tester) async {
      const matrix = (
        width: 600.0,
        height: 900.0,
        textScale: 1.0,
        light: true,
        rtl: false,
        locale: 'English',
      );
      await _pumpResponsiveHarness(tester, matrix: matrix);
      expect(
        find.descendant(
          of: find.byType(HomeQatarLifeZone),
          matching: find.byType(Row),
        ),
        findsOneWidget,
      );
    });
  });
}