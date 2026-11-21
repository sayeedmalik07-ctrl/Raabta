import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_eligibility.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_ask_ai.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_category_icon_chip.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_idle_body.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';

void main() {
  const offer = SearchAskAiResult(
    displayTitle: 'Ask RAABTA AI',
    displaySubtitle: 'Get an AI answer to your question',
    originalQuery: 'visa renewal steps',
    reason: SearchAskAiEligibilityReason.eligibleWeakResults,
  );

  group('GlobalSearchAskAiView', () {
    testWidgets('uses brand result row and forwards tap', (tester) async {
      var tapped = false;
      AppColors.applyBrightness(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchAskAiView(
              offer: offer,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(GlobalSearchResultRow), findsOneWidget);
      expect(find.byType(GlobalSearchCategoryIconChip), findsOneWidget);
      expect(find.text('Ask RAABTA AI'), findsOneWidget);

      await tester.tap(find.byType(GlobalSearchResultRow));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('RTL uses leading chevron on result row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: GlobalSearchAskAiView(
                offer: offer,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('light and dark themes render row', (tester) async {
      for (final brightness in [Brightness.dark, Brightness.light]) {
        AppColors.applyBrightness(brightness == Brightness.light);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: GlobalSearchAskAiView(
                offer: offer,
                onTap: () {},
              ),
            ),
          ),
        );
        expect(find.byType(GlobalSearchResultRow), findsOneWidget);
      }
    });
  });

  group('GlobalSearchIdleBody empty', () {
    testWidgets('uses brand empty state chip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalSearchIdleBody(
              recent: [],
              locale: 'English',
              onTap: _noop,
              onRemove: _noop,
            ),
          ),
        ),
      );

      final empty = tester.widget<GlassEmptyState>(find.byType(GlassEmptyState));
      expect(empty.accent, GlassEmptyStateAccent.brand);
      expect(find.byType(HomeIconBadge), findsOneWidget);
    });
  });

  group('no results empty copy', () {
    testWidgets('brand accent empty state for no-results strings', (tester) async {
      final title = AppShellStrings.t('global_search_no_results', 'English');
      final desc = AppShellStrings.t('global_search_empty_desc', 'English');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.search_off_rounded,
              title: title,
              description: desc,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      final empty = tester.widget<GlassEmptyState>(find.byType(GlassEmptyState));
      expect(empty.accent, GlassEmptyStateAccent.brand);
    });
  });
}

void _noop(String _) {}
