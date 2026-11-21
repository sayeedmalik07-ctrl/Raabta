import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'services_hub_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Services hub goldens (Batch D)', () {
    testWidgets('landing feed dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpServicesHub(
          tester: tester,
          listings: [
            sampleServicesHubListing(id: 'golden-provider'),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/services_hub_landing_dark_390.png'),
      );
    });

    testWidgets('empty feed dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpServicesHub(tester: tester, listings: const []),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/services_hub_empty_dark_390.png'),
      );
    });

    testWidgets('all services list dark 390w', (tester) async {
      await tester.pumpWidget(
        pumpServicesAllServicesScreen(tester: tester),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/services_all_services_dark_390.png'),
      );
    });
  });
}
