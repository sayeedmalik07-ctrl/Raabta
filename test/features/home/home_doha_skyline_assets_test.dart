import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/data/home_doha_skyline_assets.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/domain/home_doha_scene_palette.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeDohaSkylineAssets', () {
    test('bundled layer pngs load from asset bundle', () async {
      for (final path in HomeDohaSkylineAssets.layerAssetPaths) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(1000), reason: path);
      }
    });

    test('layer specs produce five tinted layers', () {
      final specs = dohaSkylineLayerSpecsForPalette(
        DohaScenePalette.forPart(DohaDayPart.golden),
      );
      expect(specs.specs, hasLength(5));
      for (final spec in specs.specs) {
        expect(spec.tint.a, greaterThan(0));
      }
    });

    testWidgets('missing layers show gradient only', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeDohaSkylineStack(
              palette: DohaScenePalette.forPart(DohaDayPart.day),
              width: 400,
              height: 236,
              layersAvailable: false,
            ),
          ),
        ),
      );
      expect(find.byType(HomeDohaSkyGradientBackdrop), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('available layers render tinted images', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeDohaSkylineStack(
              palette: DohaScenePalette.forPart(DohaDayPart.night),
              width: 390,
              height: 236,
              layersAvailable: true,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('availability probe succeeds in widget tree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final context = tester.element(find.byType(Scaffold));
      expect(await homeDohaSkylineAssetsAvailable(context), isTrue);
      expect(skylineDecodeWidthForDisplay(context, 390), greaterThan(100));
    });
  });
}