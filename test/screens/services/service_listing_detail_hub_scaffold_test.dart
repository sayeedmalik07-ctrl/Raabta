import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/screens/services/service_listing_detail_screen.dart';
import 'package:raabta/screens/services/widgets/service_hub_subscreen_scaffold.dart';

void main() {
  testWidgets('detail uses hub subscreen header', (tester) async {
    final listing = ServiceListing(
      id: 'p1',
      userId: 'u1',
      serviceCategoryId: 'home_maintenance',
      serviceCategory: 'home_maintenance',
      serviceName: 'AC repair',
      title: 'Central AC service',
      description: 'Desc',
      providerName: 'Ahmed',
      phone: '+97450000001',
      area: 'Doha',
      imageUrl: '',
      status: 'active',
      createdAt: DateTime(2026, 3, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          currentUserProvider.overrideWith((ref) => null),
          serviceListingDetailProvider('p1').overrideWith(
            (ref) => Future.value(listing),
          ),
        ],
        child: const MaterialApp(
          home: ServiceListingDetailScreen(listingId: 'p1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(ServiceHubSubscreenScaffold.headerKey), findsOneWidget);
    expect(find.text('Service listing'), findsOneWidget);
    expect(find.textContaining('Home Maintenance'), findsWidgets);
  });
}
