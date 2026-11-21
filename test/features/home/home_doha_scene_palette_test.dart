import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/domain/home_doha_scene_palette.dart';

void main() {
  group('DohaScenePalette', () {
    for (final part in DohaDayPart.values) {
      test('$part has three sky stops and layer tints', () {
        final palette = DohaScenePalette.forPart(part);
        expect(palette.skyGradientStops, hasLength(3));
        expect(palette.layerTints, hasLength(3));
        expect(palette.part, part);
      });

      test(
        '$part header text contrast at least 4.5:1 over top scrim',
        () {
          final palette = DohaScenePalette.forPart(part);
          expect(
            palette.headerTextContrastRatio(),
            greaterThanOrEqualTo(4.5),
          );
        },
      );
    }
  });
}