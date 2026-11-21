import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/utils/service_listing_display_helpers.dart';
import 'package:raabta/screens/services/widgets/service_hub_listing_card.dart';

void main() {
  test('serviceListingCategoryLabel resolves taxonomy id', () {
    final listing = ServiceListing(
      id: '1',
      userId: 'u',
      serviceCategoryId: 'home_maintenance',
      serviceCategory: 'home_maintenance',
      serviceName: 'AC repair',
      title: 'Central AC tune-up',
      description: '',
      providerName: 'Ahmed',
      phone: '',
      area: 'Doha',
      imageUrl: '',
      status: 'active',
      createdAt: DateTime(2026, 1, 1),
    );
    expect(serviceListingCategoryLabel(listing), 'Home Maintenance');
    expect(serviceHubProviderHeadline(listing), 'Ahmed');
    expect(serviceHubProviderOfferLine(listing), 'Central AC tune-up');
    expect(
      serviceHubServiceTypeLine(listing),
      'Central AC tune-up · AC repair · Home Maintenance',
    );
  });
}
