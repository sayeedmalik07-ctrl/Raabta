import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'market_hub_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Market hub goldens (Batch A)', () {
    testWidgets('landing feed dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpMarketplaceHub(
          tester: tester,
          listings: sampleMarketHubListings(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/market_hub_landing_dark_390.png'),
      );
    });

    testWidgets('landing feed light 390w', (tester) async {
      await tester.pumpWidget(
        pumpMarketplaceHub(
          tester: tester,
          listings: sampleMarketHubListings(),
          brightness: Brightness.light,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/market_hub_landing_light_390.png'),
      );
    });
  });
}
