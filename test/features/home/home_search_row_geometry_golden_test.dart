import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/features/home/widgets/animated_search_entry.dart';
import 'package:raabta/features/home/widgets/home_search_with_ai_row.dart';

/// Rendered verification vs PNG 01 / 17 / 19 (slim pill + separate orb).
void main() {
  testWidgets('home search row geometry golden', (tester) async {
    const orbKey = Key('geometry_golden_orb');
    const orb = SizedBox(
      key: orbKey,
      width: RaabtaOrbKitSizes.homeSparkle,
      height: RaabtaOrbKitSizes.homeSparkle,
      child: ColoredBox(color: Color(0xFF7A55EE)),
    );

    await tester.binding.setSurfaceSize(const Size(390, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: ColoredBox(
          color: Color(0xFF0B1020),
          child: Center(
            child: RepaintBoundary(
              key: const Key('home_search_geometry_repaint'),
              child: SizedBox(
                width: 358,
                child: HomeSearchWithAiRow(
                  search: AnimatedSearchEntry(
                    hint: 'Search jobs, housing, docs',
                    compact: false,
                    onTap: () {},
                  ),
                  aiOrb: orb,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byKey(const Key('home_search_geometry_repaint')),
      matchesGoldenFile('goldens/home_search_row_geometry.png'),
    );
  });
}
