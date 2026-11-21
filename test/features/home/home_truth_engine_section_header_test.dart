import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/features/home/widgets/home_truth_engine_section_header.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    required String locale,
    int attentionCount = 0,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          for (final engine in TruthChipEngine.values)
            truthChipStatusProvider(engine).overrideWith((ref) async {
              final attentionEngines = attentionCount <= 0
                  ? <TruthChipEngine>{}
                  : attentionCount == 1
                      ? {TruthChipEngine.eosb}
                      : {TruthChipEngine.eosb, TruthChipEngine.tenancy};
              final counts = attentionEngines.contains(engine);
              return TruthChipStatus(
                engine: engine,
                state: counts
                    ? TruthChipState.attention
                    : TruthChipState.tracked,
                tone: counts ? TruthChipTone.amber : TruthChipTone.ok,
                titleKey: 'k',
                statusText: 'x',
                freshnessText: '',
                deepLink: engine.homeRoute,
                revealedText:
                    engine == TruthChipEngine.eosb ? 'QAR ••••' : null,
              );
            }),
        ],
        child: MaterialApp(
          home: Directionality(
            textDirection: textDirection,
            child: Scaffold(
              body: HomeTruthEngineSectionHeader(
                overline: 'Know your rights',
                title: 'Truth Engines',
                locale: locale,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HomeTruthEngineSectionHeader', () {
    testWidgets('hides attention badge when count is zero', (tester) async {
      await pumpHeader(tester, locale: 'English');
      expect(find.textContaining('need attention'), findsNothing);
    });

    testWidgets('shows attention badge when count is positive', (tester) async {
      await pumpHeader(tester, locale: 'English', attentionCount: 2);
      expect(find.textContaining('2'), findsOneWidget);
    });

    testWidgets('eye toggles reveal provider', (tester) async {
      await pumpHeader(tester, locale: 'English');
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeTruthEngineSectionHeader)),
      );
      expect(container.read(homeTruthEngineDetailsRevealedProvider), isFalse);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(container.read(homeTruthEngineDetailsRevealedProvider), isTrue);
    });

    testWidgets('RTL keeps eyebrow casing', (tester) async {
      await pumpHeader(
        tester,
        locale: 'Arabic',
        textDirection: TextDirection.rtl,
      );
      expect(find.text('Know your rights'), findsOneWidget);
      expect(find.text('KNOW YOUR RIGHTS'), findsNothing);
    });
  });
}
