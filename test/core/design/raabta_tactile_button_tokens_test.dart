import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/design/raabta_physical_shadow_tokens.dart';
import 'package:raabta/core/design/raabta_tactile_button_tokens.dart';

void main() {
  group('RaabtaTactileButtonTokens', () {
    test('press metrics match physical tokens', () {
      expect(
        RaabtaTactileButtonTokens.pressedOffsetY,
        RaabtaPhysicalShadowTokens.tactilePressedOffsetY,
      );
      expect(
        RaabtaTactileButtonTokens.pressScale(true),
        RaabtaPhysicalShadowTokens.tactilePressedScale,
      );
      expect(RaabtaTactileButtonTokens.pressTranslation(false), Offset.zero);
    });

    test('circle and shape decorations carry tactile shadows', () {
      final circle = RaabtaTactileButtonTokens.circleDecoration(
        brightness: Brightness.dark,
      );
      expect(circle.boxShadow, isNotEmpty);

      final pill = RaabtaTactileButtonTokens.shapeDecoration(
        brightness: Brightness.light,
        radius: 24,
      );
      expect(pill.shadows, isNotEmpty);
      expect(pill.gradient, isNotNull);
    });
  });
}