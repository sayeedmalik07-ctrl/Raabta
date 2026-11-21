import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/features/global_search/presentation/search_ask_ai_screen.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_category_icon_chip.dart';

void main() {
  group('SearchAskAiAnswerBody', () {
    testWidgets('renders markdown and strips action markers to chips', (tester) async {
      const raw =
          'Renew via **Metrash**.\n[[action:/visa|Open Visa]] [[cite:MOI|Metrash]]';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchAskAiAnswerBody(
              validatedAnswer: raw,
              disclaimerRequired: true,
              locale: 'English',
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('Metrash'), findsWidgets);
      expect(find.text('[[action:/visa|Open Visa]]'), findsNothing);
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('selectable text fallback when parser yields empty display',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchAskAiAnswerBody(
              validatedAnswer: 'Plain answer only',
              disclaimerRequired: false,
              locale: 'English',
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('Plain answer only'), findsOneWidget);
    });

    testWidgets('RTL markdown direction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SearchAskAiAnswerBody(
                validatedAnswer: '**مرحبا**',
                disclaimerRequired: false,
                locale: 'Arabic',
                isRtl: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
    });
  });

  group('SearchAskAiLoadingPanel', () {
    testWidgets('uses hub placeholder not circular progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchAskAiLoadingPanel(locale: 'English'),
          ),
        ),
      );

      expect(find.byType(HubLoadingPlaceholder), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('SearchAskAiErrorPanel', () {
    testWidgets('shows notice banner and retry', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchAskAiErrorPanel(
              locale: 'English',
              messageKey: 'global_search_ask_ai_error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.byType(HubNoticeBanner), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(retried, isTrue);
    });
  });

  group('SearchAskAiQuerySummary', () {
    testWidgets('shows brand chip and query', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchAskAiQuerySummary(
              query: 'QID renewal steps',
              locale: 'English',
            ),
          ),
        ),
      );

      expect(find.byType(GlobalSearchCategoryIconChip), findsOneWidget);
      expect(find.text('QID renewal steps'), findsOneWidget);
    });

    testWidgets('light and dark', (tester) async {
      for (final brightness in [Brightness.dark, Brightness.light]) {
        AppColors.applyBrightness(brightness == Brightness.light);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const Scaffold(
              body: SearchAskAiQuerySummary(
                query: 'jobs near pearl',
                locale: 'English',
              ),
            ),
          ),
        );
        expect(find.text('jobs near pearl'), findsOneWidget);
      }
    });
  });

  group('SearchAskAiAnswerPanel', () {
    testWidgets('brand header and markdown answer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchAskAiAnswerPanel(
              locale: 'English',
              isRtl: false,
              validatedAnswer: 'Use **Metrash** for renewal.',
              disclaimerRequired: true,
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
    });
  });

  group('SearchAskAiBackToSearchBar', () {
    testWidgets('invokes pop callback', (tester) async {
      var popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchAskAiBackToSearchBar(
              locale: 'English',
              onPressed: () => popped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SearchAskAiBackToSearchBar));
      expect(popped, isTrue);
    });

    testWidgets('RTL locale', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SearchAskAiBackToSearchBar(
                locale: 'Urdu',
                onPressed: _noop,
              ),
            ),
          ),
        ),
      );

      expect(AppLocale.isRtl('Urdu'), isTrue);
      expect(find.byType(SearchAskAiBackToSearchBar), findsOneWidget);
    });
  });
}

void _noop() {}
