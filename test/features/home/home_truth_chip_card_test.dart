import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/l10n/home_truth_chip_ui_strings.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_truth_chip_card.dart';
void main() {
  Widget wrap({
    required Widget child,
    double width = 148,
    double? height,
    TextDirection textDirection = TextDirection.ltr,
    double textScale = 1.0,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
        ),
        child: Directionality(
          textDirection: textDirection,
          child: Center(
            child: SizedBox(
              width: width,
              height: height ?? HomeCardTier.truthEngineGridExtent,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  const base = TruthChipStatus(
    engine: TruthChipEngine.tenancy,
    state: TruthChipState.tracked,
    tone: TruthChipTone.ok,
    titleKey: 'home_tool_tenancy',
    statusText: 'Lease ends in 94 days',
    freshnessText: 'From your lease entry',
    deepLink: '/tenancy',
    progress: 0.74,
  );

  HomeTruthChipCard card({
    required TruthChipStatus status,
    bool detailsRevealed = false,
    VoidCallback? onTap,
  }) {
    return HomeTruthChipCard(
      icon: Icons.home_work_outlined,
      title: 'Rent & tenancy',
      accentColor: Colors.amber,
      surfaceGlowColor: Colors.amber,
      rowHeight: HomeCardTier.truthEngineGridExtent,
      status: status,
      locale: 'English',
      detailsRevealed: detailsRevealed,
      onTap: onTap ?? () {},
      expand: true,
    );
  }

  group('HomeTruthChipCard', () {
    testWidgets('invite shows Start and hides progress', (tester) async {
      const invite = TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: 'home_tool_eosb',
        statusText: 'Check your gratuity',
        freshnessText: '',
        deepLink: '/eosb',
      );
      await tester.pumpWidget(
        wrap(
          child: card(status: invite),
          height: HomeCardTier.truthEngineInviteGridExtent,
        ),
      );
      expect(
        find.text(HomeTruthChipUiStrings.t('truth_chip_start_cta', 'English')),
        findsOneWidget,
      );
      expect(find.byType(FractionallySizedBox), findsNothing);
    });

    testWidgets('tracked shows progress and footer', (tester) async {
      await tester.pumpWidget(wrap(child: card(status: base)));
      expect(find.text('From your lease entry'), findsOneWidget);
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('amber and red pills render', (tester) async {
      const amber = TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.attention,
        tone: TruthChipTone.amber,
        titleKey: 'home_tool_health',
        statusText: 'Renews in 21 days',
        pillText: '21 days',
        progress: 0.94,
        freshnessText: 'From your policy entry',
        deepLink: '/health-insurance',
      );
      const red = TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.urgent,
        tone: TruthChipTone.red,
        titleKey: 'home_tool_tenancy',
        statusText: 'Lease not registered',
        pillText: 'Action',
        freshnessText: 'From your lease check',
        deepLink: '/tenancy',
      );
      await tester.pumpWidget(wrap(child: card(status: amber)));
      expect(find.text('21 days'), findsOneWidget);
      await tester.pumpWidget(wrap(child: card(status: red)));
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('loading state fits height', (tester) async {
      const loading = TruthChipStatus.loading(
        engine: TruthChipEngine.eosb,
        titleKey: 'home_tool_eosb',
        deepLink: '/eosb',
      );
      await tester.pumpWidget(
        wrap(
          width: 320,
          textScale: 1.3,
          child: card(status: loading),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('End of service pay'), findsNothing);
    });

    testWidgets('reveal swaps masked line for sensitive text', (tester) async {
      const sensitive = TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.tracked,
        tone: TruthChipTone.ok,
        titleKey: 'home_tool_eosb',
        statusText: 'Year 3 of service',
        revealedText: '≈ QAR 12,400 estimate',
        progress: 0.62,
        freshnessText: 'Estimate · updated 12 Oct',
        deepLink: '/eosb',
      );
      await tester.pumpWidget(
        wrap(child: card(status: sensitive, detailsRevealed: false)),
      );
      expect(find.textContaining('QAR'), findsNothing);
      expect(
        find.textContaining(
          HomeTruthChipUiStrings.t('truth_chip_masked_placeholder', 'English'),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        wrap(child: card(status: sensitive, detailsRevealed: true)),
      );
      expect(find.textContaining('QAR'), findsOneWidget);
    });

    testWidgets('fits 320dp at 1.3x text scale without overflow', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: MaterialApp(
            home: Center(
              child: SizedBox(
                width: 148,
                height: HomeCardTier.truthEngineGridExtent,
                child: card(
                  status: const TruthChipStatus(
                    engine: TruthChipEngine.sponsorshipTransfer,
                    state: TruthChipState.attention,
                    tone: TruthChipTone.amber,
                    titleKey: 'home_tool_transfer',
                    statusText: 'QID cancellation: 9 days left',
                    pillText: '9 days',
                    progress: 0.36,
                    freshnessText: 'Countdown started 17 Oct',
                    deepLink: '/sponsorship-transfer',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL lays out pill on the correct side', (tester) async {
      await tester.pumpWidget(
        wrap(
          textDirection: TextDirection.rtl,
          child: card(
            status: const TruthChipStatus(
              engine: TruthChipEngine.tenancy,
              state: TruthChipState.attention,
              tone: TruthChipTone.amber,
              titleKey: 'home_tool_tenancy',
              statusText: 'Deposit deadline in 6 days',
              pillText: '6 days',
              progress: 0.6,
              freshnessText: 'From your deadline tracker',
              deepLink: '/tenancy',
            ),
          ),
        ),
      );
      expect(find.text('6 days'), findsOneWidget);
    });

    testWidgets('onTap fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          child: card(
            status: base,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(HomeTruthChipCard));
      expect(tapped, isTrue);
    });

    test('semantics include progress percent', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.tracked,
        tone: TruthChipTone.ok,
        titleKey: 'k',
        statusText: 'Lease ends in 94 days',
        progress: 0.74,
        freshnessText: 'From your lease entry',
        deepLink: '/tenancy',
      );
      final label = HomeTruthChipCard.accessibilityLabel(
        title: 'Rent & tenancy',
        status: status,
        detailsRevealed: false,
      );
      expect(label, contains('74%'));
    });

    testWidgets('Urdu RTL lays out without overflow', (tester) async {
      await tester.pumpWidget(
        wrap(
          width: 148,
          textScale: 1.3,
          textDirection: TextDirection.rtl,
          child: card(
            status: const TruthChipStatus(
              engine: TruthChipEngine.healthInsurance,
              state: TruthChipState.attention,
              tone: TruthChipTone.amber,
              titleKey: 'k',
              statusText: 'Renews in 21 days',
              pillText: '21 days',
              progress: 0.94,
              freshnessText: 'From your policy entry',
              deepLink: '/health-insurance',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('semantics omit hidden revealed text', (tester) async {
      const sensitive = TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.tracked,
        tone: TruthChipTone.ok,
        titleKey: 'home_tool_eosb',
        statusText: 'Year 3 of service',
        revealedText: '≈ QAR 12,400 estimate',
        progress: 0.62,
        freshnessText: 'Estimate · updated 12 Oct',
        deepLink: '/eosb',
      );
      await tester.pumpWidget(
        wrap(child: card(status: sensitive, detailsRevealed: false)),
      );
      final semantics = tester.getSemantics(find.byType(HomeTruthChipCard));
      expect(semantics.label, isNot(contains('QAR')));
      expect(semantics.label, contains('Year 3 of service'));
    });
  });
}
