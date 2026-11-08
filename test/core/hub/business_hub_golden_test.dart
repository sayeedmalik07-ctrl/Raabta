import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/data/models/business_listing.dart';

import 'business_hub_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Business hub goldens (Batch D)', () {
    testWidgets('landing feed dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpBusinessHub(
          tester: tester,
          catalog: [
            sampleBusinessHubListing(id: 'golden-1', name: 'Golden Cafe'),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/business_hub_landing_dark_390.png'),
      );
    });

    testWidgets('empty catalog dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpBusinessHub(tester: tester, catalog: const <BusinessListing>[]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/business_hub_empty_dark_390.png'),
      );
    });
  });
}
