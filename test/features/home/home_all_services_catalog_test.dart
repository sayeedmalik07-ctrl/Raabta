import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/data/home_all_services_catalog.dart';

void main() {
  test('all services lists six hubs including marketplace', () {
    expect(kHomeAllServiceEntries, hasLength(6));
    expect(
      kHomeAllServiceEntries.map((e) => e.route).toList(),
      containsAll(<String>[
        '/housing',
        '/jobs',
        '/marketplace',
        '/businesses',
        '/services',
        '/money',
      ]),
    );
    expect(
      kHomeAllServiceEntries.any((e) => e.route == '/visa'),
      isFalse,
    );
  });
}