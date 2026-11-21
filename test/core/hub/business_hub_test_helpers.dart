import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/businesses/businesses_screen.dart';

BusinessListing sampleBusinessHubListing({
  required String id,
  required String name,
  bool openNow = true,
}) {
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
    openNow: openNow,
  );
}

Widget pumpBusinessHub({
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
      businessCatalogProvider.overrideWith((ref) => Stream.value(catalog)),
      userOwnedBusinessesProvider.overrideWith(
        (ref) => Stream.value(const <BusinessListing>[]),
      ),
      userSavedSearchesForVerticalProvider(SavedSearchVertical.business)
          .overrideWith((ref) => Stream.value(const <SavedSearch>[])),
    ],
    child: MaterialApp.router(
      theme: ThemeData(brightness: Brightness.dark),
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: router,
    ),
  );
}
