import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/features/home/widgets/animated_search_entry.dart';
import 'package:raabta/features/home/widgets/home_floating_search_bar.dart';
import 'package:raabta/features/home/widgets/home_search_with_ai_row.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';

void main() {
  const orbKey = Key('capsule_test_orb');
  const screenWidth = 320.0;

  Widget capsuleHarness({
    required TextDirection appDirection,
    required bool compact,
    bool includeSticky = false,
    bool stickyVisible = false,
  }) {
    const orb = SizedBox(
      key: orbKey,
      width: RaabtaOrbKitSizes.homeSparkle,
      height: RaabtaOrbKitSizes.homeSparkle,
    );

    return MaterialApp(
      home: Directionality(
        textDirection: appDirection,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(screenWidth, 700)),
          child: Scaffold(
            body: Column(
              children: [
                HomeSearchWithAiRow(
                  search: AnimatedSearchEntry(
                    hint: 'Search Raabta',
                    compact: compact,
                    onTap: () {},
                  ),
                  aiOrb: orb,
                ),
                if (includeSticky)
                  HomeFloatingSearchBar(
                    visible: stickyVisible,
                    searchEntry: const AnimatedSearchEntry(
                      hint: 'Sticky',
                      compact: true,
                      onTap: _noop,
                    ),
                    aiOrb: orb,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void expectOrbOnVisualRight(WidgetTester tester) {
    final orbRect = tester.getRect(find.byKey(orbKey).first);
    final rowRect = tester.getRect(find.byType(HomeSearchWithAiRow).first);
    expect(orbRect.right, closeTo(rowRect.right, 1));
  }

  testWidgets('search uses slim 44dp glass pill beside 54dp orb', (
    tester,
  ) async {
    await tester.pumpWidget(
      capsuleHarness(appDirection: TextDirection.ltr, compact: false),
    );
    await tester.pump();

    expect(find.byType(HomeSearchWithAiRow), findsOneWidget);

    final searchGlassFinder = find.descendant(
      of: find.byType(AnimatedSearchEntry),
      matching: find.byType(GlassContainer),
    );
    expect(searchGlassFinder, findsOneWidget);

    final searchGlass = tester.widget<GlassContainer>(searchGlassFinder);
    expect(searchGlass.height, AnimatedSearchEntry.designPillHeight);
    expect(searchGlass.borderRadius, AnimatedSearchEntry.designPillRadius);
    expect(
      searchGlass.solidSurfaceFamily,
      RaabtaSolidSurfaceFamily.neutral,
    );

    final searchGlassSize = tester.getSize(searchGlassFinder);
    expect(
      searchGlassSize.height,
      closeTo(AnimatedSearchEntry.designPillHeight, 2),
    );

    final orbSize = tester.getSize(find.byKey(orbKey).first);
    expect(orbSize.width, RaabtaOrbKitSizes.homeSparkle);
    expect(orbSize.height, RaabtaOrbKitSizes.homeSparkle);

    final searchRect = tester.getRect(find.byType(AnimatedSearchEntry).first);
    final orbRect = tester.getRect(find.byKey(orbKey).first);
    expect(
      orbRect.left - searchRect.right,
      closeTo(HomeSearchWithAiRow.searchOrbGap, 2),
    );

    expect(
      tester.getSize(find.byType(AnimatedSearchEntry).first).height,
      closeTo(AnimatedSearchEntry.designPillHeight, 2),
    );

    expectOrbOnVisualRight(tester);
  });

  testWidgets(
    'orb stays on visual right in RTL with locale-aware search text',
    (tester) async {
      await tester.pumpWidget(
        capsuleHarness(appDirection: TextDirection.rtl, compact: false),
      );
      await tester.pump();

      expectOrbOnVisualRight(tester);

      final hint = tester.widget<Text>(
        find.descendant(
          of: find.byType(AnimatedSearchEntry),
          matching: find.text('Search Raabta'),
        ),
      );
      expect(hint.textDirection, TextDirection.rtl);
    },
  );

  testWidgets('sticky row keeps slim search height', (tester) async {
    await tester.pumpWidget(
      capsuleHarness(
        appDirection: TextDirection.ltr,
        compact: true,
        includeSticky: true,
        stickyVisible: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      tester.getSize(find.byType(HomeSearchWithAiRow).last).height,
      HomeSearchWithAiRow.rowHeight,
    );
  });

  testWidgets('narrow width does not overflow', (tester) async {
    await tester.pumpWidget(
      capsuleHarness(appDirection: TextDirection.ltr, compact: false),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(orbKey), findsWidgets);
  });
}

void _noop() {}
