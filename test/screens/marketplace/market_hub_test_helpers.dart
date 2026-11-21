import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/marketplace/marketplace_screen.dart';

/// Golden sample: featured + hot rows plus full fallback catalog for feed.
List<MarketplaceListing> sampleMarketHubListings() {
  return [
    sampleMarketListing(
      id: 'golden-featured',
      badge: ListingBoostBadge.featured,
    ),
    sampleMarketListing(id: 'golden-hot', badge: ListingBoostBadge.hot),
    ...fallbackMarketplaceListings(),
  ];
}

MarketplaceListing sampleMarketListing({
  required String id,
  ListingBoostBadge? badge,
}) {
  final base = fallbackMarketplaceListings().first;
  return MarketplaceListing(
    id: id,
    categoryId: base.categoryId,
    emoji: base.emoji,
    title: base.title,
    price: base.price,
    area: base.area,
    posted: base.posted,
    condition: base.condition,
    sellerFlag: base.sellerFlag,
    views: base.views,
    distanceKm: base.distanceKm,
    badge: badge,
    trendingViews: 2000,
  );
}

Widget pumpMarketplaceHub({
  required WidgetTester tester,
  required List<MarketplaceListing> listings,
  Brightness brightness = Brightness.dark,
  TextDirection direction = TextDirection.ltr,
  double width = 390,
  String locale = 'English',
}) {
  tester.view.physicalSize = Size(width * 3, 2200 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MarketplaceScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      userLanguageProvider.overrideWith((ref) => locale),
      currentUserProvider.overrideWith((ref) => null),
      marketplaceListingsProvider.overrideWith((ref) async => listings),
    ],
    child: MaterialApp.router(
      theme: ThemeData(brightness: brightness),
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: router,
    ),
  );
}
