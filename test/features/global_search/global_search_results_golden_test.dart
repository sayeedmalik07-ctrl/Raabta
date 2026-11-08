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
import 'package:raabta/features/global_search/presentation/widgets/global_search_idle_body.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_instant_answer_view.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_group.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpResultGroup(
    WidgetTester tester, {
    required Brightness brightness,
  }) async {
    AppColors.applyBrightness(brightness == Brightness.light);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final group = GlobalSearchCategoryGroup(
      category: GlobalSearchCategory.money,
      items: const [
        GlobalSearchResultItem(
          id: 'm1',
          category: GlobalSearchCategory.money,
          title: 'Send money home',
          subtitle: 'Compare rates',
          routePath: '/money',
          score: 1,
        ),
      ],
      totalMatched: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(
          body: SingleChildScrollView(
            child: GlobalSearchResultGroupView(
              group: group,
              locale: 'English',
              onTapItem: (_) {},
              onSeeAll: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('GlobalSearchResultGroup golden dark', (tester) async {
    await pumpResultGroup(tester, brightness: Brightness.dark);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/global_search_result_group_dark.png'),
    );
  });

  testWidgets('GlobalSearchResultGroup golden light', (tester) async {
    await pumpResultGroup(tester, brightness: Brightness.light);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/global_search_result_group_light.png'),
    );
  });

  Future<void> configureGoldenSurface(WidgetTester tester) async {
    AppColors.applyBrightness(false);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('GlobalSearchBestMatch golden dark', (tester) async {
    await configureGoldenSurface(tester);

    const sampleItem = GlobalSearchResultItem(
      id: 'job-1',
      category: GlobalSearchCategory.jobs,
      title: 'Site electrician',
      subtitle: 'Industrial Area',
      routePath: '/jobs',
      score: 42,
    );
    final bestMatch = SearchBestMatch(
      result: sampleItem,
      score: 50,
      reasonKey: 'global_search_best_match_job',
      source: SearchBestMatchSource.destination,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: SingleChildScrollView(
            child: GlobalSearchBestMatchView(
              bestMatch: bestMatch,
              locale: 'English',
              onTapItem: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/global_search_best_match_dark.png'),
    );
  });

  testWidgets('GlobalSearchInstantAnswer golden dark', (tester) async {
    await configureGoldenSurface(tester);

    const answer = InstantAnswer(
      type: InstantAnswerType.currencyIntent,
      primaryLineKey: 'global_search_action_currency_title',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: SingleChildScrollView(
            child: GlobalSearchInstantAnswerView(
              answer: answer,
              locale: 'English',
              fromCache: false,
              onTapItem: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/global_search_instant_answer_dark.png'),
    );
  });

  testWidgets('GlobalSearchAutocomplete golden dark', (tester) async {
    await configureGoldenSurface(tester);

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
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: SingleChildScrollView(
            child: GlobalSearchAutocompleteView(
              suggestions: suggestions,
              locale: 'English',
              onSelect: (_) {},
              onRemoveRecent: (_) {},
              onClearRecent: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/global_search_autocomplete_dark.png'),
    );
  });

  testWidgets('GlobalSearchIdleBody golden dark', (tester) async {
    await configureGoldenSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: GlobalSearchIdleBody(
            recent: const [],
            locale: 'English',
            onTap: _noop,
            onRemove: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/global_search_idle_dark.png'),
    );
  });
}

void _noop(String _) {}
