import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/utils/home_responsive_layout.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

void main() {
  group('HomeResponsiveLayout', () {
    test('tier breakpoints', () {
      expect(HomeResponsiveLayout.tierFor(599), HomeWidthTier.compact);
      expect(HomeResponsiveLayout.tierFor(600), HomeWidthTier.medium);
      expect(HomeResponsiveLayout.tierFor(1023), HomeWidthTier.medium);
      expect(HomeResponsiveLayout.tierFor(1024), HomeWidthTier.expanded);
    });

    test('contentLeadingInset centers at 680 on wide viewports', () {
      expect(
        HomeResponsiveLayout.contentLeadingInset(390),
        HomeZoneSpacing.sectionHorizontalPadding,
      );
      expect(
        HomeResponsiveLayout.contentLeadingInset(680),
        HomeZoneSpacing.sectionHorizontalPadding,
      );
      expect(HomeResponsiveLayout.contentLeadingInset(1280), closeTo(300, 0.1));
      expect(
        1280 -
            2 * HomeResponsiveLayout.contentLeadingInset(1280),
        closeTo(HomeResponsiveLayout.contentMaxWidth, 0.1),
      );
    });

    test('truth grid columns', () {
      expect(
        HomeResponsiveLayout.truthEngineGridCrossAxisCount(
          viewportWidth: 390,
          itemCount: 4,
        ),
        2,
      );
      expect(
        HomeResponsiveLayout.truthEngineGridCrossAxisCount(
          viewportWidth: 800,
          itemCount: 4,
        ),
        2,
      );
      expect(
        HomeResponsiveLayout.truthEngineGridCrossAxisCount(
          viewportWidth: 1024,
          itemCount: 4,
        ),
        4,
      );
    });

    test('Qatar Life scroll only on compact', () {
      expect(
        HomeResponsiveLayout.qatarLifeUsesHorizontalScroll(360),
        isTrue,
      );
      expect(
        HomeResponsiveLayout.qatarLifeUsesHorizontalScroll(600),
        isFalse,
      );
    });
  });
}