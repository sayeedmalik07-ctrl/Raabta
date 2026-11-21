import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';

void main() {
  test('HomeZoneSpacing matches polish kit rhythm', () {
    expect(HomeZoneSpacing.afterSectionHeader, 12);
    expect(HomeZoneSpacing.betweenZones, 28);
    expect(HomeZoneSpacing.afterHero, 14);
    expect(HomeCardTier.truthEngineInviteGridExtent, 132);
  });

  testWidgets('HomeSectionHeader gap under title is at most 16dp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeSectionHeader(title: 'Qatar Life'),
        ),
      ),
    );

    final gap = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(HomeSectionHeader),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.height == HomeZoneSpacing.afterSectionHeader,
        ),
      ),
    );
    expect(gap.height!, lessThanOrEqualTo(16));
  });
}