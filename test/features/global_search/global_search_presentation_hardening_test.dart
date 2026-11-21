import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_loading_indicator.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_group.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';

void main() {
  const sampleItem = GlobalSearchResultItem(
    id: 'job-1',
    category: GlobalSearchCategory.jobs,
    title: 'Site electrician',
    subtitle: 'Industrial Area',
    routePath: '/jobs',
    score: 42,
  );

  Future<void> pumpResultRow(
    WidgetTester tester, {
    required String locale,
    required TextDirection textDirection,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(_localeCode(locale)),
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            body: GlobalSearchResultRow(
              icon: Icons.work_outline_rounded,
              accent: AppColors.brandFamilyMain,
              title: sampleItem.title,
              subtitle: sampleItem.subtitle,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }

  group('RTL result row chevrons', () {
    testWidgets('Arabic uses leading chevron affordance', (tester) async {
      await pumpResultRow(
        tester,
        locale: 'Arabic',
        textDirection: TextDirection.rtl,
      );

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('Urdu uses leading chevron affordance', (tester) async {
      await pumpResultRow(
        tester,
        locale: 'Urdu',
        textDirection: TextDirection.rtl,
      );

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });
  });

  group('text scaling', () {
    testWidgets('result group tolerates 1.3x text scale', (tester) async {
      AppColors.applyBrightness(false);
      final group = GlobalSearchCategoryGroup(
        category: GlobalSearchCategory.jobs,
        items: const [sampleItem],
        totalMatched: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
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
        ),
      );

      expect(find.text('Site electrician'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('reduced motion', () {
    testWidgets('loading indicator skips shimmer tween when animations disabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: GlobalSearchLoadingIndicator(locale: 'English'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    });
  });
}

String _localeCode(String locale) {
  return switch (locale) {
    'Arabic' => 'ar',
    'Urdu' => 'ur',
    _ => 'en',
  };
}
