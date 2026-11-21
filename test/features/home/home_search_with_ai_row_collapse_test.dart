import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/features/home/widgets/animated_search_entry.dart';
import 'package:raabta/features/home/widgets/home_doha_header_choreography.dart';
import 'package:raabta/features/home/widgets/home_doha_header_collapse_scope.dart';
import 'package:raabta/features/home/widgets/home_search_with_ai_row.dart';

Widget _pumpRow(WidgetTester tester, {required double progress}) {
  const orb = SizedBox(
    width: RaabtaOrbKitSizes.homeSparkle,
    height: RaabtaOrbKitSizes.homeSparkle,
    child: ColoredBox(color: Color(0xFF7A55EE)),
  );

  return MaterialApp(
    home: Scaffold(
      body: HomeDohaHeaderCollapseScope(
        progress: progress,
        child: HomeSearchWithAiRow(
          search: AnimatedSearchEntry(
            hint: 'Search jobs, housing, docs',
            onTap: () {},
          ),
          aiOrb: orb,
        ),
      ),
    ),
  );
}

void main() {
  group('HomeSearchWithAiRow Doha collapse padding', () {
    test('t=0 keeps 12 top and 8 bottom', () {
      final padding = HomeSearchWithAiRow.dohaOuterPaddingForCollapse(0);
      expect(padding.top, HomeSearchWithAiRow.inlineTopInset);
      expect(padding.bottom, 8);
      expect(
        HomeSearchWithAiRow.verticalFootprintForCollapse(0),
        HomeSearchWithAiRow.rowHeight + 20,
      );
    });

    test('t=0.5 halves outer padding', () {
      final padding = HomeSearchWithAiRow.dohaOuterPaddingForCollapse(0.5);
      expect(padding.top, 6);
      expect(padding.bottom, 4);
    });

    test('t=1 removes outer padding', () {
      final padding = HomeSearchWithAiRow.dohaOuterPaddingForCollapse(1);
      expect(padding, EdgeInsets.zero);
      expect(
        HomeSearchWithAiRow.verticalFootprintForCollapse(1),
        HomeSearchWithAiRow.rowHeight,
      );
    });

    test('t=1 fits collapsed body at y=10', () {
      final bottomInBody =
          HomeDohaTopZoneMetrics.searchRowYCollapsed +
          HomeSearchWithAiRow.verticalFootprintForCollapse(1);
      expect(
        bottomInBody,
        HomeDohaTopZoneMetrics.collapsedBodyHeight,
      );
    });

    test('t=0.5 fits mid scroll body viewport', () {
      final t = 0.5;
      final visibleBody =
          HomeDohaTopZoneMetrics.expandedBodyHeight -
          HomeDohaTopZoneMetrics.collapseRange * t;
      final searchTop = HomeDohaTopZoneMetrics.searchRowTopY(t, reduceMotion: false);
      final footprint = HomeSearchWithAiRow.verticalFootprintForCollapse(t);
      expect(searchTop + footprint, lessThanOrEqualTo(visibleBody));
    });

    testWidgets('widget height tracks collapse progress', (tester) async {
      await tester.pumpWidget(_pumpRow(tester, progress: 0));
      await tester.pump();
      expect(
        tester.getSize(find.byType(HomeSearchWithAiRow)).height,
        HomeSearchWithAiRow.verticalFootprintForCollapse(0),
      );

      await tester.pumpWidget(_pumpRow(tester, progress: 1));
      await tester.pump();
      expect(
        tester.getSize(find.byType(HomeSearchWithAiRow)).height,
        HomeSearchWithAiRow.rowHeight,
      );
    });

    testWidgets('without scope keeps expanded padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeSearchWithAiRow(
              search: AnimatedSearchEntry(
                hint: 'Search jobs, housing, docs',
                onTap: () {},
              ),
              aiOrb: const SizedBox(
                width: RaabtaOrbKitSizes.homeSparkle,
                height: RaabtaOrbKitSizes.homeSparkle,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byType(HomeSearchWithAiRow)).height,
        HomeSearchWithAiRow.verticalFootprintForCollapse(0),
      );
    });

    testWidgets('text scale 1.3 at t=1 keeps 54dp row height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
              body: HomeDohaHeaderCollapseScope(
                progress: 1,
                child: HomeSearchWithAiRow(
                  search: AnimatedSearchEntry(
                    hint: 'Search jobs, housing, docs',
                    onTap: () {},
                  ),
                  aiOrb: const SizedBox(
                    width: RaabtaOrbKitSizes.homeSparkle,
                    height: RaabtaOrbKitSizes.homeSparkle,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byType(HomeSearchWithAiRow)).height,
        HomeSearchWithAiRow.rowHeight,
      );
    });

    testWidgets('RTL row remains usable at t=1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: HomeDohaHeaderCollapseScope(
                progress: 1,
                child: HomeSearchWithAiRow(
                  search: AnimatedSearchEntry(
                    hint: 'Search jobs, housing, docs',
                    onTap: () {},
                  ),
                  aiOrb: const SizedBox(
                    width: RaabtaOrbKitSizes.homeSparkle,
                    height: RaabtaOrbKitSizes.homeSparkle,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(HomeSearchWithAiRow), findsOneWidget);
      expect(
        tester.getSize(find.byType(HomeSearchWithAiRow)).height,
        HomeSearchWithAiRow.rowHeight,
      );
    });
  });
}