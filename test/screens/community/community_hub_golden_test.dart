import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'community_hub_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Community hub goldens (Batch E)', () {
    testWidgets('landing feed empty dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpCommunityHub(tester: tester, feedPosts: const []),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/community_hub_empty_feed_dark_390.png'),
      );
    });

    testWidgets('landing feed with post dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpCommunityHub(
          tester: tester,
          feedPosts: [sampleCommunityFeedPost()],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/community_hub_feed_dark_390.png'),
      );
    });

    testWidgets('landing feed light 390w', (tester) async {
      await tester.pumpWidget(
        pumpCommunityHub(
          tester: tester,
          feedPosts: [sampleCommunityFeedPost()],
          brightness: Brightness.light,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/community_hub_feed_light_390.png'),
      );
    });
  });
}
