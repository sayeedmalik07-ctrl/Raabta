import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/widgets/hub/hub_business_card.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/data/mock/businesses_mock_data.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/businesses/businesses_screen.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';

BusinessListing _sampleBusiness({required String id, required String name}) {
  return BusinessListing(
    id: id,
    name: name,
    category: 'Restaurant',
    emoji: '🍛',
    rating: 4.5,
    reviewCount: 10,
    location: 'Doha, Qatar',
    speciality: 'Test',
    trustScore: 90,
    phone: '+97450000000',
    servicesOffered: const ['Delivery', 'Dine-in'],
  );
}

Widget _pumpBusinessHub({
  required WidgetTester tester,
  required List<BusinessListing> catalog,
  TextDirection direction = TextDirection.ltr,
  double width = 390,
  String locale = 'English',
}) {
  tester.view.physicalSize = Size(width * 3, 1400 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BusinessesScreen(),
      ),
      GoRoute(
        path: '/profile/saved-searches',
        builder: (context, state) =>
            const Scaffold(body: Text('saved searches')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      userLanguageProvider.overrideWith((ref) => locale),
      currentUserProvider.overrideWith((ref) => null),
      businessCatalogProvider.overrideWith(
        (ref) => Stream.value(catalog),
      ),
      userOwnedBusinessesProvider.overrideWith(
        (ref) => Stream.value(const <BusinessListing>[]),
      ),
      userSavedSearchesForVerticalProvider(SavedSearchVertical.business)
          .overrideWith((ref) => Stream.value(const <SavedSearch>[])),
    ],
    child: MaterialApp.router(
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: router,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Business hub landing (Batch B)', () {
    testWidgets('shows Housing-style header, search, and HubBusinessCard feed',
        (tester) async {
      const locale = 'English';
      final sample = _sampleBusiness(id: 'b1', name: 'Test Cafe');

      await tester.pumpWidget(
        _pumpBusinessHub(tester: tester, catalog: [sample]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const Key('business_hub_landing_header')),
        findsOneWidget,
      );
      expect(find.byType(HubLandingHeader), findsOneWidget);
      expect(
        find.text(BusinessesStrings.t('hub_title', locale)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('business_hub_search')), findsOneWidget);
      expect(
        find.text(BusinessesStrings.t('search_hint', locale)),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('business_hub_filter_toggle')),
        findsOneWidget,
      );
      expect(
        find.text(BusinessesStrings.t('quick_saved', locale)),
        findsOneWidget,
      );
      expect(find.byType(HubBusinessCard), findsOneWidget);
      expect(find.byKey(const Key('business_hub_card_b1')), findsOneWidget);
      expect(find.text('Test Cafe'), findsOneWidget);
    });

    testWidgets('empty catalog shows business_hub_empty_state', (tester) async {
      await tester.pumpWidget(
        _pumpBusinessHub(tester: tester, catalog: const []),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('business_hub_empty_state')), findsOneWidget);
      expect(find.byType(HubBusinessCard), findsNothing);
    });

    testWidgets('landing chrome at 320dp does not overflow', (tester) async {
      await tester.pumpWidget(
        _pumpBusinessHub(
          tester: tester,
          width: 320,
          catalog: [kMockBusinesses.first],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  });

  group('Business hub states (Batch D)', () {
    testWidgets('catalog loading shows business_hub_loading_skeleton',
        (tester) async {
      final pending = StreamController<List<BusinessListing>>();
      addTearDown(pending.close);

      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userLanguageProvider.overrideWith((ref) => 'English'),
            currentUserProvider.overrideWith((ref) => null),
            businessCatalogProvider.overrideWith((ref) => pending.stream),
            userOwnedBusinessesProvider.overrideWith(
              (ref) => Stream.value(const <BusinessListing>[]),
            ),
            userSavedSearchesForVerticalProvider(SavedSearchVertical.business)
                .overrideWith((ref) => Stream.value(const <SavedSearch>[])),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const BusinessesScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('business_hub_loading_skeleton')),
        findsOneWidget,
      );
    });

    testWidgets('filtered zero-result uses business_hub_zero_result_state',
        (tester) async {
      await tester.pumpWidget(
        _pumpBusinessHub(
          tester: tester,
          catalog: [
            BusinessListing(
              id: 'closed',
              name: 'Closed Cafe',
              category: 'Restaurant',
              emoji: '🍛',
              rating: 4.0,
              reviewCount: 1,
              location: 'Doha, Qatar',
              speciality: 'Test',
              trustScore: 80,
              phone: '+97450000000',
              openNow: false,
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(
        find.byKey(const Key('business_hub_filter_open_now')),
      );
      await tester.tap(find.byKey(const Key('business_hub_filter_open_now')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byKey(const Key('business_hub_zero_result_state')),
        findsOneWidget,
      );
    });

    testWidgets('RTL landing chrome uses directional back in header',
        (tester) async {
      await tester.pumpWidget(
        _pumpBusinessHub(
          tester: tester,
          direction: TextDirection.rtl,
          catalog: [_sampleBusiness(id: 'b1', name: 'Test Cafe')],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.descendant(
          of: find.byType(HubLandingHeader),
          matching: find.byIcon(Icons.arrow_forward),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Arabic 320dp hub subtitle ellipsizes without overflow',
        (tester) async {
      await tester.pumpWidget(
        _pumpBusinessHub(
          tester: tester,
          width: 320,
          locale: 'Arabic',
          direction: TextDirection.rtl,
          catalog: [_sampleBusiness(id: 'b1', name: 'Test Cafe')],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final subtitle = find.descendant(
        of: find.byKey(const Key('business_hub_landing_header')),
        matching: find.text(BusinessesStrings.t('hub_subtitle', 'Arabic')),
      );
      expect(subtitle, findsOneWidget);
      final subtitleText = tester.widget<Text>(subtitle);
      expect(subtitleText.maxLines, 1);
      expect(subtitleText.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });
  });
}
