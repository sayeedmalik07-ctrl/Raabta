import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';

void main() {
  testWidgets('HubLandingHeader uses hub title and subtitle styles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HubLandingHeader(
            title: 'Housing',
            subtitle: 'Find your next home',
            onBack: () {},
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Housing'));
    final subtitle = tester.widget<Text>(find.text('Find your next home'));

    expect(title.style?.fontSize, HubTypography.hubTitle.fontSize);
    expect(title.style?.fontWeight, HubTypography.hubTitle.fontWeight);
    expect(subtitle.style?.fontSize, HubTypography.hubSubtitle.fontSize);
    expect(subtitle.style?.color, HubTypography.hubSubtitle.color);
  });

  testWidgets('compactBackTitleGap defaults off for Housing-style headers',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HubLandingHeader(
            title: 'Housing',
            subtitle: 'Find your next home',
            onBack: () {},
          ),
        ),
      ),
    );

    final header = tester.widget<HubLandingHeader>(find.byType(HubLandingHeader));
    expect(header.compactBackTitleGap, isFalse);
  });

  testWidgets('HubLandingHeader back icon mirrors in RTL', (tester) async {
    Future<void> pumpHeader(TextDirection direction) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: HubLandingHeader(
                title: 'Jobs',
                subtitle: 'Find work',
                onBack: () {},
              ),
            ),
          ),
        ),
      );
    }

    await pumpHeader(TextDirection.ltr);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsNothing);

    await pumpHeader(TextDirection.rtl);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('HubSummaryStripPadding uses directional insets in LTR and RTL',
      (tester) async {
    Future<void> pumpStrip(TextDirection direction) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: const Scaffold(
              body: HubSummaryStripPadding(
                child: SizedBox(height: 8),
              ),
            ),
          ),
        ),
      );
    }

    Finder stripPadding() {
      return find.descendant(
        of: find.byType(HubSummaryStripPadding),
        matching: find.byType(Padding),
      );
    }

    await pumpStrip(TextDirection.ltr);
    var padding = tester.widget<Padding>(stripPadding());
    var insets = padding.padding as EdgeInsetsDirectional;
    expect(insets.start, AppSpacing.xl);
    expect(insets.end, AppSpacing.xl);
    expect(insets.top, AppSpacing.md);
    expect(insets.bottom, 0);

    await pumpStrip(TextDirection.rtl);
    padding = tester.widget<Padding>(stripPadding());
    insets = padding.padding as EdgeInsetsDirectional;
    expect(insets.start, AppSpacing.xl);
    expect(insets.end, AppSpacing.xl);
    expect(insets.top, AppSpacing.md);
    expect(insets.bottom, 0);
  });
}
