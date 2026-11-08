import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/screens/services/data/service_front_groups.dart';
import 'package:raabta/screens/services/data/service_taxonomy.dart';

void main() {
  test('taxonomy has 24 categories and 184 sub-services', () {
    expect(kServiceCategories.length, 24);
    final subs = kServiceCategories
        .expand((category) => category.subServices)
        .toList();
    expect(subs.length, 184);
    expect(subs.toSet().length, greaterThanOrEqualTo(180));
  });

  test('every category id resolves and has sub-services', () {
    for (final category in kServiceCategories) {
      expect(findServiceCategoryById(category.id)?.id, category.id);
      expect(category.subServices, isNotEmpty);
    }
  });

  test('search taxonomy returns hits for known sub-service', () {
    final hits = searchServiceTaxonomy('AC repair');
    expect(hits, isNotEmpty);
  });

  test('every category maps to a front group and orders are unique', () {
    final orders = <int>{};
    final fgSeen = <String, int>{};
    for (final c in kServiceCategories) {
      expect(c.frontGroupId, isNotEmpty);
      expect(ServiceFrontGroupIds.orderedIds, contains(c.frontGroupId));
      expect(orders.add(c.presentationOrder), isTrue,
          reason: 'duplicate presentationOrder ${c.presentationOrder}');
      fgSeen[c.frontGroupId] = (fgSeen[c.frontGroupId] ?? 0) + 1;
    }
    expect(fgSeen.length, ServiceFrontGroupIds.orderedIds.length);
    for (final fg in ServiceFrontGroupIds.orderedIds) {
      expect(fgSeen[fg], greaterThanOrEqualTo(1));
    }
  });

  test('search matches front-group label english', () {
    final hits = searchServiceTaxonomy('Car care');
    expect(hits.map((h) => h.category.id).toSet(), contains('automotive'));
  });

  test('All services: empty query lists 12 groups in hub order', () {
    expect(matchingFrontGroupIds(''), ServiceFrontGroupIds.orderedIds);
  });

  test('All services: tap target prefers category that matches leaf query', () {
    expect(
      primaryCategoryIdForFrontGroupTap(
        ServiceFrontGroupIds.repairInstallation,
        'AC repair',
      ),
      'home_maintenance',
    );
    expect(
      matchingFrontGroupIds('zzzznomatchplz999'),
      isEmpty,
    );
  });
}
