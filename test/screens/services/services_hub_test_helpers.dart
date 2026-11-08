import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/screens/services/services_all_services_screen.dart';
import 'package:raabta/screens/services/services_home_screen.dart';

ServiceListing sampleServicesHubListing({
  required String id,
  ServiceListingType listingType = ServiceListingType.provider,
  bool identityVerified = true,
}) {
  return ServiceListing(
    id: id,
    userId: 'user-$id',
    serviceCategoryId: 'home_cleaning',
    serviceCategory: 'Home Cleaning',
    serviceName: 'Deep cleaning',
    title: 'Professional deep clean',
    description: 'Weekly or one-off home cleaning in Doha.',
    providerName: 'Fatima Al-Hajri',
    phone: '+97450000000',
    area: 'West Bay',
    imageUrl: '',
    status: 'active',
    createdAt: DateTime(2026, 3, 1),
    listingType: listingType,
    posterIdentityVerified: identityVerified,
    schemaFields: const {'hourly_rate': 80},
  );
}

Widget pumpServicesHub({
  required WidgetTester tester,
  required List<ServiceListing> listings,
  TextDirection direction = TextDirection.ltr,
  double width = 390,
  String locale = 'English',
  ServiceListingType browseType = ServiceListingType.provider,
}) {
  tester.view.physicalSize = Size(width * 3, 1600 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ServicesHomeScreen(),
      ),
      GoRoute(
        path: '/profile/saved-searches',
        builder: (context, state) =>
            const Scaffold(body: Text('saved searches')),
      ),
      GoRoute(
        path: '/services/my-listings',
        builder: (context, state) =>
            const Scaffold(body: Text('my listings')),
      ),
      GoRoute(
        path: '/services/all',
        builder: (context, state) => const ServicesAllServicesScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      userLanguageProvider.overrideWith((ref) => locale),
      currentUserProvider.overrideWith((ref) => null),
      servicesBrowseListingTypeProvider.overrideWith(
        (ref) => browseType,
      ),
      recentServiceListingsProvider.overrideWith(
        (ref) => Stream.value(listings),
      ),
      userSavedSearchesForVerticalProvider(SavedSearchVertical.services)
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

/// All services T2 — same chrome as production `/services/all` (tall viewport for goldens).
Widget pumpServicesAllServicesScreen({
  required WidgetTester tester,
  TextDirection direction = TextDirection.ltr,
  double width = 390,
  String locale = 'English',
}) {
  tester.view.physicalSize = Size(width * 3, 2200 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/services/all',
    routes: [
      GoRoute(
        path: '/services/all',
        builder: (context, state) => const ServicesAllServicesScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      userLanguageProvider.overrideWith((ref) => locale),
      currentUserProvider.overrideWith((ref) => null),
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
