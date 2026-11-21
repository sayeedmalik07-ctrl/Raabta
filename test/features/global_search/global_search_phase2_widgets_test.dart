import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/instant_answer.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_result.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_source.dart';
import 'package:raabta/features/global_search/domain/search_best_match.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_autocomplete.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_best_match.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_category_icon_chip.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_instant_answer_view.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_group.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';

void main() {
  final sampleItem = GlobalSearchResultItem(
    id: 'job-1',
    category: GlobalSearchCategory.jobs,
    title: 'Site electrician',
    subtitle: 'Industrial Area',
    routePath: '/jobs',
    score: 42,
  );

  group('GlobalSearchResultGroupView', () {
    testWidgets('renders section header and result rows', (tester) async {
      final group = GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.jobs,
        items: [sampleItem],
        totalMatched: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchResultGroupView(
              group: group,
              locale: 'English',
              onTapItem: (_) {},
              onSeeAll: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GlobalSearchResultRow), findsOneWidget);
      expect(find.byType(GlobalSearchCategoryIconChip), findsWidgets);
      expect(find.text('Site electrician'), findsOneWidget);
    });
  });

  group('GlobalSearchBestMatchView', () {
    testWidgets('renders best match row', (tester) async {
      final bestMatch = SearchBestMatch(
        result: sampleItem,
        score: 50,
        reasonKey: 'global_search_best_match_job',
        source: SearchBestMatchSource.destination,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchBestMatchView(
              bestMatch: bestMatch,
              locale: 'English',
              onTapItem: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Site electrician'), findsOneWidget);
      expect(find.byType(GlobalSearchResultRow), findsOneWidget);
    });
  });

  group('GlobalSearchInstantAnswerView', () {
    testWidgets('renders primary line', (tester) async {
      const answer = InstantAnswer(
        type: InstantAnswerType.currencyIntent,
        primaryLineKey: 'global_search_action_currency_title',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchInstantAnswerView(
              answer: answer,
              locale: 'English',
              fromCache: false,
              onTapItem: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GlobalSearchInstantAnswerView), findsOneWidget);
    });
  });

  group('GlobalSearchAutocompleteView', () {
    testWidgets('renders suggestion tiles', (tester) async {
      const suggestions = [
        SearchAutocompleteResult(
          displayText: 'housing in pearl',
          submitQuery: 'housing in pearl',
          subtitle: 'Housing',
          source: SearchAutocompleteSource.starter,
          normalizedText: 'housing in pearl',
          relevanceScore: 10,
          icon: Icons.home_outlined,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchAutocompleteView(
              suggestions: suggestions,
              locale: 'English',
              onSelect: (_) {},
              onRemoveRecent: (_) {},
              onClearRecent: () {},
            ),
          ),
        ),
      );

      expect(find.text('housing in pearl'), findsOneWidget);
      expect(find.byType(GlobalSearchResultRow), findsOneWidget);
    });
  });

  group('theme parity', () {
    testWidgets('result row uses brand accent in light and dark', (tester) async {
      Future<void> pumpTheme(Brightness brightness) async {
        AppColors.applyBrightness(brightness == Brightness.light);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: GlobalSearchResultRow(
                icon: Icons.work_outline_rounded,
                accent: AppColors.brandFamilyMain,
                title: 'Test',
                onTap: () {},
              ),
            ),
          ),
        );
      }

      await pumpTheme(Brightness.dark);
      expect(find.byType(GlobalSearchCategoryIconChip), findsOneWidget);

      await pumpTheme(Brightness.light);
      expect(find.byType(GlobalSearchCategoryIconChip), findsOneWidget);
    });
  });
}
