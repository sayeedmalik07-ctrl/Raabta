import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_prayer_strip.dart';
import 'package:raabta/features/home/widgets/home_truth_chip_card.dart';
import 'package:raabta/features/home/widgets/home_truth_engine_section_header.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';

void main() {
  Widget truthChip({
    required String title,
    required double width,
    String locale = 'English',
  }) {
    const invite = TruthChipStatus(
      engine: TruthChipEngine.eosb,
      state: TruthChipState.invite,
      tone: TruthChipTone.neutral,
      titleKey: 'tool_eosb_title',
      statusText: 'Check your gratuity',
      freshnessText: '',
      deepLink: '/eosb',
    );
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 640),
          textScaler: const TextScaler.linear(1.3),
        ),
        child: Center(
          child: SizedBox(
            width: (width - 32 - 12) / 2,
            height: HomeCardTier.truthEngineInviteGridExtent,
            child: HomeTruthChipCard(
              icon: Icons.account_balance_wallet_outlined,
              title: title,
              accentColor: Colors.amber,
              surfaceGlowColor: Colors.amber,
              rowHeight: HomeCardTier.truthEngineInviteGridExtent,
              status: invite,
              locale: locale,
              detailsRevealed: false,
              onTap: () {},
              expand: true,
            ),
          ),
        ),
      ),
    );
  }

  group('Batch A truth invite cards', () {
    testWidgets('longest title fits 320 grid without overflow', (tester) async {
      for (final locale in ['English', 'Malayalam', 'Arabic', 'Urdu']) {
        final title = QuickActionsStrings.t('tool_eosb_title', locale);
        await tester.pumpWidget(truthChip(title: title, width: 320, locale: locale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('…'), findsNothing);
      }
    });
  });

  group('Batch A privacy eye', () {
    Future<void> pumpHeader(
      WidgetTester tester, {
      required List<TruthChipEngine> revealEngines,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            for (final engine in TruthChipEngine.values)
              truthChipStatusProvider(engine).overrideWith((ref) async {
                final reveal = revealEngines.contains(engine);
                return TruthChipStatus(
                  engine: engine,
                  state: reveal
                      ? TruthChipState.tracked
                      : TruthChipState.invite,
                  tone: TruthChipTone.neutral,
                  titleKey: 'tool_eosb_title',
                  statusText: reveal ? 'Tracked' : 'Check your gratuity',
                  freshnessText: '',
                  deepLink: engine.homeRoute,
                  revealedText: reveal ? 'QAR 12,000' : null,
                );
              }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeTruthEngineSectionHeader(
                overline: 'Raabta Truth Engines',
                title: 'Know your rights',
                locale: 'English',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('guest-style invite grid hides privacy eye', (tester) async {
      await pumpHeader(tester, revealEngines: []);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('signed-in saved data shows privacy eye', (tester) async {
      await pumpHeader(tester, revealEngines: [TruthChipEngine.eosb]);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('Batch A glance chips', () {
    test('prayer compact keeps countdown on time line', () {
      final line = HomePrayerStrip.timeRemainingLine(
        locale: 'English',
        remaining: const Duration(hours: 3, minutes: 12),
      );
      expect(line, contains('3h 12m'));
      expect(line, isNot(contains('Next:')));
    });
  });
}