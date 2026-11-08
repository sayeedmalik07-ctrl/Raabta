import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/widgets/hub/hub_business_card.dart';
import 'package:raabta/core/widgets/hub/hub_detail_action_bar.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/presentation/l10n/business_quote_strings.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/screens/businesses/businesses_screen.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';
import 'package:raabta/screens/businesses/widgets/business_listing_detail_sheet_scaffold.dart';

BusinessListing _visitorListing({
  BusinessContactMode mode = BusinessContactMode.messageOnly,
  String? status,
  String? ownerUserId,
}) {
  return BusinessListing(
    id: 'biz-detail-1',
    name: 'Detail Test Cafe',
    category: 'Cafe',
    emoji: '☕',
    rating: 4.2,
    reviewCount: 3,
    location: 'Doha, Qatar',
    speciality: 'Coffee',
    trustScore: 88,
    phone: '+97450000001',
    whatsapp: '+97450000002',
    contactMode: mode,
    status: status,
    ownerUserId: ownerUserId,
  );
}

Widget _pumpBusinessHubForDetail({
  required WidgetTester tester,
  required List<BusinessListing> catalog,
  ComplianceFlags? flags,
}) {
  tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BusinessesScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      userLanguageProvider.overrideWith((ref) => 'English'),
      currentUserProvider.overrideWith((ref) => null),
      businessCatalogProvider.overrideWith((ref) => Stream.value(catalog)),
      userOwnedBusinessesProvider.overrideWith(
        (ref) => Stream.value(const <BusinessListing>[]),
      ),
      userSavedSearchesForVerticalProvider(SavedSearchVertical.business)
          .overrideWith((ref) => Stream.value(const <SavedSearch>[])),
      if (flags != null)
        complianceFlagsProvider.overrideWith((ref) => flags),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Business hub detail (Batch C)', () {
    testWidgets('sticky HubDetailActionBar shows Message for visitors',
        (tester) async {
      const locale = 'English';
      await tester.pumpWidget(
        _pumpBusinessHubForDetail(
          tester: tester,
          catalog: [_visitorListing()],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byType(HubBusinessCard));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(BusinessListingDetailActionBar.barKey),
        findsOneWidget,
      );
      expect(find.byType(HubDetailActionBar), findsOneWidget);
      expect(
        find.text(BusinessesStrings.t('detail_message', locale)),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.ios_share_outlined), findsOneWidget);
    });

    testWidgets('structured quote primary when flag on', (tester) async {
      await tester.pumpWidget(
        _pumpBusinessHubForDetail(
          tester: tester,
          catalog: [
            _visitorListing(
              mode: BusinessContactMode.quote,
              status: 'active',
              ownerUserId: 'owner-other',
            ),
          ],
          flags: const ComplianceFlags(
            offersEnabled: false,
            viewingsEnabled: false,
            quotesEnabled: false,
            paidBoostsEnabled: false,
            businessAdsEnabled: false,
            jobApplicationStatusEnabled: true,
            businessQuotesEnabled: true,
            businessAppointmentsEnabled: false,
            configReachable: true,
            configFresh: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Detail Test Cafe'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(BusinessListingDetailActionBar.barKey), findsOneWidget);
      expect(
        find.text(BusinessQuoteStrings.t('biz_quote_cta', 'English')),
        findsOneWidget,
      );
    });
  });
}
