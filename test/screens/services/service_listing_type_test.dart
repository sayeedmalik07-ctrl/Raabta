import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

void main() {
  group('ServiceListingType', () {
    test('fromStored defaults missing field to provider', () {
      expect(ServiceListingType.fromStored(null), ServiceListingType.provider);
      expect(ServiceListingType.fromStored(''), ServiceListingType.provider);
      expect(ServiceListingType.fromStored('provider'), ServiceListingType.provider);
      expect(ServiceListingType.fromStored('request'), ServiceListingType.request);
    });

    test('fromFirestore defaults listingType to provider', () {
      final listing = ServiceListing.fromFirestore(
        _FakeDoc({
          'userId': 'u1',
          'serviceCategoryId': 'home_maintenance',
          'serviceName': 'AC repair',
          'title': 'Legacy listing',
          'status': 'active',
          'createdAt': Timestamp.now(),
        }),
      );

      expect(listing.listingType, ServiceListingType.provider);
    });

    test('fromFirestore reads request listingType', () {
      final listing = ServiceListing.fromFirestore(
        _FakeDoc({
          'userId': 'u1',
          'serviceCategoryId': 'home_maintenance',
          'serviceName': 'AC repair',
          'title': 'Need AC help',
          'listingType': 'request',
          'status': 'active',
          'createdAt': Timestamp.now(),
        }),
      );

      expect(listing.listingType, ServiceListingType.request);
      expect(listing.isRequest, isTrue);
    });

    test('submission persists listingType on same collection', () {
      final data = const ServiceListingSubmission(
        userId: 'u1',
        serviceCategoryId: 'home_maintenance',
        serviceCategory: 'Home maintenance',
        serviceName: 'Plumbing',
        title: 'Plumbing request',
        description: 'Leak under sink',
        providerName: 'Ahmed',
        phone: '+97450000000',
        area: 'West Bay',
        imageUrl: '',
        listingType: ServiceListingType.request,
      ).toFirestore();

      expect(data['listingType'], 'request');
      expect(data['quotesOpen'], isTrue);
      expect(data.containsKey('userId'), isTrue);
    });
  });
}

class _FakeDoc implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeDoc(this._data);

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => 'test-id';

  @override
  bool get exists => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
