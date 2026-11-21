import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/core/widgets/raabta_orb_sparkle_glyph.dart';
import 'package:raabta/features/home/l10n/home_floating_ai_strings.dart';
import 'package:raabta/features/home/widgets/home_floating_ai_assistant.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';

void main() {
  testWidgets('Home AI orb exposes Ask Raabta semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeAliveAiOrb(
            locale: 'English',
            persona: KnowQatarPersona.newResident,
            showProactiveDot: false,
            animationsEnabled: false,
          ),
        ),
      ),
    );

    final expected = HomeFloatingAiStrings.t('ask_raabta', 'English');
    expect(find.bySemanticsLabel(expected), findsOneWidget);
    expect(find.byKey(const Key('home_floating_ai_orb')), findsOneWidget);
  });

  testWidgets('idle orb renders sphere glyph stack at 54dp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeAliveAiOrb(
            locale: 'English',
            persona: KnowQatarPersona.newResident,
            showProactiveDot: false,
            animationsEnabled: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RaabtaOrb), findsOneWidget);
    expect(find.byType(RaabtaOrbSparkleGlyph), findsOneWidget);
    final glyphPainter = tester
        .widget<CustomPaint>(find.descendant(
          of: find.byType(RaabtaOrbSparkleGlyph),
          matching: find.byType(CustomPaint),
        ))
        .painter;
    expect(
      glyphPainter.runtimeType.toString(),
      contains('RaabtaOrbBrandGlyphPainter'),
    );
    expect(
      tester.getSize(find.byType(HomeAliveAiOrb)).height,
      HomeAiAssistantHost.aiOrbSize,
    );
  });
}
