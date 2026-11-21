import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/design/home_grain_tokens.dart';
import 'package:raabta/features/home/widgets/home_page_grain_layer.dart';

void main() {
  group('HomeGrainTokens.shouldShowGrain', () {
    test('returns false when reduce motion', () {
      expect(
        HomeGrainTokens.shouldShowGrain(
          reduceMotion: true,
          mediaQuery: const MediaQueryData(),
        ),
        isFalse,
      );
    });

    test('returns true under default accessibility', () {
      expect(
        HomeGrainTokens.shouldShowGrain(
          reduceMotion: false,
          mediaQuery: const MediaQueryData(),
        ),
        isTrue,
      );
    });
  });

  testWidgets('HomePageGrainLayer paints repeating asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              HomePageGrainLayer(),
            ],
          ),
        ),
      ),
    );

    final decor = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final image = decor.decoration as BoxDecoration;
    expect(image.image, isA<DecorationImage>());
    expect(image.image!.repeat, ImageRepeat.repeat);
    expect(image.image!.image, isA<AssetImage>());
  });

  testWidgets('grain hidden when reduce motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(
            body: HomePageGrainLayer(),
          ),
        ),
      ),
    );

    expect(find.byType(HomePageGrainLayer), findsOneWidget);
    expect(find.byType(DecoratedBox), findsNothing);
  });
}