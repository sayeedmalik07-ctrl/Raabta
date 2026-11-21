import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/raabta_orb_sparkle_glyph.dart';

void main() {
  testWidgets('RaabtaOrbSparkleGlyph paints brand link mark', (tester) async {
    const glyphSize = 28.0;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RaabtaOrbSparkleGlyph(size: glyphSize),
          ),
        ),
      ),
    );

    expect(find.byType(RaabtaOrbSparkleGlyph), findsOneWidget);
    expect(
      tester.getSize(find.byType(RaabtaOrbSparkleGlyph)),
      const Size.square(glyphSize),
    );

    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(RaabtaOrbSparkleGlyph),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(
      paint.painter.runtimeType.toString(),
      contains('RaabtaOrbBrandGlyphPainter'),
    );
  });
}