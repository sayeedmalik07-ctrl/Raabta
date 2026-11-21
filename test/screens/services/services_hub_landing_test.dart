import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/hub/hub_post_fab.dart';
import 'package:raabta/core/widgets/hub/hub_service_card.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/widgets/services_hub_all_services_row.dart';
import 'package:raabta/screens/services/widgets/services_hub_describe_card.dart';
import 'package:raabta/screens/services/widgets/services_hub_front_group_grid.dart';

import 'services_hub_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Services hub landing chrome', () {
    testWidgets('exposes kit keys and HubServiceCard feed', (tester) async {
      await tester.pumpWidget(
        pumpServicesHub(
          tester: tester,
          listings: [sampleServicesHubListing(id: 'hub-1')],
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('services_hub_landing_header')), findsOneWidget);
      expect(find.byKey(const Key('services_hub_search')), findsOneWidget);
      expect(find.byKey(ServicesHubDescribeCard.cardKey), findsOneWidget);
      expect(find.byKey(ServicesHubFrontGroupGrid.sectionKey), findsOneWidget);
      expect(find.byKey(ServicesHubAllServicesRow.rowKey), findsOneWidget);
      expect(find.byKey(const Key('services_hub_segment_providers')), findsOneWidget);
      expect(find.byKey(const Key('services_hub_segment_requests')), findsOneWidget);
      expect(find.byKey(const Key('services_hub_post_fab')), findsOneWidget);
      expect(find.byType(HubPostFab), findsOneWidget);
      expect(find.byType(HubServiceCard), findsOneWidget);
    });

    testWidgets('empty state uses brand empty key', (tester) async {
      await tester.pumpWidget(
        pumpServicesHub(tester: tester, listings: const []),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('services_hub_empty_state')), findsOneWidget);
    });

    testWidgets('requests segment shows request card silhouette', (tester) async {
      await tester.pumpWidget(
        pumpServicesHub(
          tester: tester,
          listings: [
            sampleServicesHubListing(
              id: 'req-1',
              listingType: ServiceListingType.request,
            ),
          ],
          browseType: ServiceListingType.request,
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('services_hub_segment_requests')), findsOneWidget);
      expect(find.textContaining('Needs:'), findsOneWidget);
    });
  });
}
