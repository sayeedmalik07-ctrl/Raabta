import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/core/widgets/hub/hub_detail_action_bar.dart';
import 'package:raabta/screens/services/l10n/service_quote_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/widgets/service_listing_detail_action_bar.dart';

ServiceListing _requestListing() {
  return ServiceListing(
    id: 'req1',
    userId: 'customer1',
    serviceCategoryId: 'cleaning',
    serviceCategory: 'Cleaning',
    serviceName: 'Deep clean',
    title: 'Need deep clean',
    description: 'Test',
    providerName: 'Customer',
    phone: '+97450000000',
    area: 'West Bay',
    imageUrl: '',
    status: 'active',
    createdAt: DateTime(2026, 1, 1),
    listingType: ServiceListingType.request,
  );
}

void main() {
  testWidgets('hides submit quote secondary when quotes flag is off', (tester) async {
    ComplianceFlagsGate.update(ComplianceFlags.failClosed());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ServiceListingDetailActionBar(
              listing: _requestListing(),
              locale: 'English',
              isSaved: false,
              isCustomerOwner: false,
              isProviderViewer: true,
              onSave: () {},
              onShare: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(ServiceQuoteStrings.t('svc_submit_quote', 'English')),
      findsNothing,
    );
    expect(find.byType(HubDetailActionBar), findsOneWidget);
  });
}
