import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/design/home_grain_tokens.dart';
import 'package:raabta/core/design/raabta_continuous_shape.dart';
import 'package:raabta/core/design/raabta_physical_shadow_tokens.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';

void main() {
  group('RaabtaSolidSurfaceTokens', () {
    test('dark fills match kit hex', () {
      expect(
        RaabtaSolidSurfaceTokens.fill(
          RaabtaSolidSurfaceFamily.gold,
          Brightness.dark,
        ),
        const Color(0xFF1A1508),
      );
      expect(
        RaabtaSolidSurfaceTokens.fill(
          RaabtaSolidSurfaceFamily.teal,
          Brightness.dark,
        ),
        const Color(0xFF08151A),
      );
      expect(
        RaabtaSolidSurfaceTokens.fill(
          RaabtaSolidSurfaceFamily.brand,
          Brightness.dark,
        ),
        const Color(0xFF130F24),
      );
      expect(
        RaabtaSolidSurfaceTokens.fill(
          RaabtaSolidSurfaceFamily.neutral,
          Brightness.dark,
        ),
        const Color(0xFF10162B),
      );
    });

    test('light fills match kit hex', () {
      expect(
        RaabtaSolidSurfaceTokens.fill(
          RaabtaSolidSurfaceFamily.gold,
          Brightness.light,
        ),
        const Color(0xFFFFF6E0),
      );
      expect(
        RaabtaSolidSurfaceTokens.fill(
          RaabtaSolidSurfaceFamily.teal,
          Brightness.light,
        ),
        const Color(0xFFE7F7F4),
      );
      expect(
        RaabtaSolidSurfaceTokens.fill(
          RaabtaSolidSurfaceFamily.brand,
          Brightness.light,
        ),
        const Color(0xFFF1ECFD),
      );
    });

    test('cardDecoration uses fill hairline and shadow', () {
      final decoration = RaabtaSolidSurfaceTokens.cardDecoration(
        family: RaabtaSolidSurfaceFamily.gold,
        brightness: Brightness.dark,
        radius: 24,
      );
      expect(decoration.color, const Color(0xFF1A1508));
      expect(decoration.shadows, isNotEmpty);
      expect(decoration.shape, isA<ShapeBorder>());
    });

    test('hairline alphas are non-zero', () {
      for (final family in RaabtaSolidSurfaceFamily.values) {
        final dark = RaabtaSolidSurfaceTokens.hairline(family, Brightness.dark);
        final light =
            RaabtaSolidSurfaceTokens.hairline(family, Brightness.light);
        expect(dark.a, greaterThan(0));
        expect(light.a, greaterThan(0));
      }
    });
  });

  group('RaabtaPhysicalShadowTokens', () {
    test('card and tactile shadows differ by theme', () {
      expect(RaabtaPhysicalShadowTokens.card(Brightness.dark), hasLength(1));
      expect(RaabtaPhysicalShadowTokens.card(Brightness.light), hasLength(2));
      expect(
        RaabtaPhysicalShadowTokens.tactileButton(Brightness.dark),
        hasLength(1),
      );
    });

    test('tactile highlight and fill', () {
      expect(
        RaabtaTactileHighlightTokens.solidBrandFill(Brightness.dark),
        const Color(0xFF7A55EE),
      );
      expect(
        RaabtaTactileHighlightTokens.solidBrandFill(Brightness.light),
        const Color(0xFF6C3FC5),
      );
      expect(
        RaabtaTactileHighlightTokens.innerTopEdge(Brightness.dark).a,
        closeTo(0.35, 0.01),
      );
    });
  });

  group('RaabtaContinuousShape', () {
    test('produces continuous and superellipse borders', () {
      final rect = RaabtaContinuousShape.rectangle(24);
      final superellipse = RaabtaContinuousShape.superellipse(24);
      expect(rect, isA<ContinuousRectangleBorder>());
      expect(superellipse, isA<RoundedSuperellipseBorder>());
    });

    test('surface decoration matches platform kit shape', () {
      final shape = RaabtaContinuousShape.surface(24);
      expect(
        shape,
        anyOf(isA<RoundedSuperellipseBorder>(), isA<ContinuousRectangleBorder>()),
      );
      final deco = RaabtaContinuousShape.decoration(
        radius: 24,
        color: Colors.black,
      );
      expect(
        deco.shape,
        anyOf(isA<RoundedSuperellipseBorder>(), isA<ContinuousRectangleBorder>()),
      );
    });
  });

  group('HomeGrainTokens', () {
    test('tile size scales with DPR', () {
      expect(HomeGrainTokens.logicalTileSize(2), 64);
      expect(HomeGrainTokens.logicalTileSize(1), 128);
    });

    test('asset paths', () {
      expect(
        HomeGrainTokens.assetPathFor(Brightness.dark),
        contains('home_grain_dark'),
      );
      expect(
        HomeGrainTokens.assetPathFor(Brightness.light),
        contains('home_grain_light_soft'),
      );
    });

    test('shouldShowGrain respects motion flags', () {
      expect(
        HomeGrainTokens.shouldShowGrain(
          reduceMotion: true,
          mediaQuery: const MediaQueryData(),
        ),
        isFalse,
      );
    });
  });
}