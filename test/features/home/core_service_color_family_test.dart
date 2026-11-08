import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/design/color_family.dart';
import 'package:raabta/features/home/data/core_service_color_family.dart';

void main() {
  group('CoreServiceColorFamily', () {
    test('every core service title maps to brand', () {
      for (final title in CoreServiceColorFamily.coreServiceTitles) {
        expect(
          CoreServiceColorFamily.forTitle(title),
          RaabtaColorFamilies.brand,
        );
      }
    });

    test('only brand is allowed on the core services grid', () {
      for (final family in RaabtaColorFamilies.all) {
        final allowed =
            CoreServiceColorFamily.isAllowedOnCoreServicesGrid(family);
        expect(allowed, identical(family, RaabtaColorFamilies.brand));
      }
    });

    test('unknown title throws', () {
      expect(
        () => CoreServiceColorFamily.forTitle('Unknown'),
        throwsArgumentError,
      );
    });
  });
}
