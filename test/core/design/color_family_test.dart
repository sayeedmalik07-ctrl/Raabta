import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/design/color_family.dart';

import 'color_contrast_utils.dart';

void main() {
  group('ColorFamily token resolution', () {
    for (final family in RaabtaColorFamilies.all) {
      test('main/text follow brightness for ${family.lightDeep}', () {
        expect(family.main(Brightness.dark), family.dark);
        expect(family.main(Brightness.light), family.light);
        expect(family.text(Brightness.dark), family.dark);
        expect(family.text(Brightness.light), family.lightDeep);
      });
    }

    test('brand kit hex values', () {
      expect(RaabtaColorFamilies.brand.dark, const Color(0xFF9B7BFF));
      expect(RaabtaColorFamilies.brand.light, const Color(0xFF6C3FC5));
      expect(RaabtaColorFamilies.brand.lightDeep, const Color(0xFF4A2A96));
    });
  });

  group('premiumSurfaceDecoration', () {
    test('light brand decoration uses gradient, border, and shadows', () {
      final decoration = premiumSurfaceDecoration(
        family: RaabtaColorFamilies.brand,
        brightness: Brightness.light,
        borderRadius: 16,
      );
      expect(decoration.gradient, isNotNull);
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, hasLength(2));
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    test('dark brand decoration has no box shadow', () {
      final decoration = premiumSurfaceDecoration(
        family: RaabtaColorFamilies.brand,
        brightness: Brightness.dark,
        borderRadius: 16,
      );
      expect(decoration.gradient, isNotNull);
      expect(decoration.boxShadow, isNull);
    });
  });

  group('light-mode contrast (brand core service tile)', () {
    const pageBackground = Color(0xFFF4F6FA);
    const titleColor = Color(0xFF0F172A);
    late Color cardSample;
    late Color lightSubtitleColor;
    late Color borderColor;

    setUpAll(() {
      cardSample = premiumSurfaceSampleColor(
        family: RaabtaColorFamilies.brand,
        brightness: Brightness.light,
      );
      borderColor = premiumSurfaceBorderColor(
        family: RaabtaColorFamilies.brand,
        brightness: Brightness.light,
      );
      lightSubtitleColor = RaabtaColorFamilies.brand.text(Brightness.light);
    });

    test('title text on card surface >= 4.5:1', () {
      final ratio = contrastRatio(titleColor, cardSample);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('light subtitle (family lightDeep) on worst-case card >= 4.5:1', () {
      final ratio = contrastRatio(lightSubtitleColor, cardSample);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('brand border and card edge vs page — known a11y limitation', () {
      final borderVsPage = contrastRatio(borderColor, pageBackground);
      final cardOnPage = contrastRatio(Colors.white, pageBackground);
      expect(borderVsPage, lessThan(3.0));
      expect(cardOnPage, lessThan(1.2));
    });
  });
}
