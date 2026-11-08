import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/screens/services/domain/service_quote.dart';

void main() {
  test('ServiceQuote round-trips through json', () {
    final quote = ServiceQuote(
      id: 'provider-1',
      requestListingId: 'req-1',
      providerId: 'provider-1',
      providerName: 'Ali Services',
      price: 250,
      includedDescription: 'Labour and basic parts',
      priceChangeNote: 'Extra parts on site',
      createdAt: _fixedTime,
    );

    final restored = ServiceQuote.fromJson('provider-1', quote.toJson());
    expect(restored.price, 250);
    expect(restored.includedDescription, 'Labour and basic parts');
    expect(restored.priceChangeNote, 'Extra parts on site');
    expect(restored.status, ServiceQuoteStatus.submitted);
  });

  test('ServiceQuoteStatus selected deserializes', () {
    final quote = ServiceQuote.fromJson('provider-1', {
      'requestListingId': 'req-1',
      'providerId': 'provider-1',
      'providerName': 'Ali',
      'price': 100,
      'includedDescription': 'Visit',
      'createdAt': _fixedTime.toIso8601String(),
      'status': 'selected',
    });
    expect(quote.status, ServiceQuoteStatus.selected);
  });
}

final _fixedTime = DateTime(2026, 3, 21, 12);
