import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

import 'community_hub_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Community hub chrome (Batch E)', () {
    testWidgets('RTL shows hub header and feed tab label', (tester) async {
      await tester.pumpWidget(
        pumpCommunityHub(
          tester: tester,
          direction: TextDirection.rtl,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HubLandingHeader), findsOneWidget);
      expect(
        find.text(CommunityStrings.t('community_tab_feed', 'English')),
        findsWidgets,
      );
    });

    testWidgets('text scale 1.3 still shows hub title', (tester) async {
      await tester.pumpWidget(
        pumpCommunityHub(
          tester: tester,
          textScale: 1.3,
          feedPosts: [sampleCommunityFeedPost()],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.descendant(
          of: find.byType(HubLandingHeader),
          matching: find.text(
            CommunityStrings.t('community_hub_title', 'English'),
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Sara M.'), findsWidgets);
    });
  });
}
