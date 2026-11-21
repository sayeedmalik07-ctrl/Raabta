import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/l10n_catalog_registry.dart';
import 'package:raabta/core/l10n/l10n_coverage_finding.dart';
import 'package:raabta/features/home/l10n/home_recommendation_strings.dart';

const batchKeys = <String>[
  'advice_add_signals',
  'advice_category_attention',
  'advice_category_grow',
  'advice_category_low',
  'advice_default_empty',
  'advice_low_confidence',
  'advice_on_track',
  'advice_unlock_profile',
  'advice_weekly_up',
  'community_group_fallback',
  'gap_category_action',
  'gap_community_action',
  'gap_housing_action',
  'improve_ask_qatar_desc',
  'improve_ask_qatar_title',
  'improve_browse_housing_desc',
  'improve_browse_housing_title',
  'improve_budget_desc',
  'improve_budget_title',
  'improve_certs_desc',
  'improve_certs_title',
  'improve_doctor_desc',
  'improve_doctor_title',
  'improve_exchange_desc',
  'improve_exchange_title',
  'improve_explore_jobs_desc',
  'improve_explore_jobs_title',
  'improve_housing_desc',
  'improve_housing_title',
  'improve_iqama_desc',
  'improve_iqama_title',
  'improve_join_group_desc',
  'improve_join_group_title',
  'improve_passport_desc',
  'improve_passport_title',
  'improve_profession_desc',
  'improve_profession_title',
  'improve_refer_desc',
  'improve_refer_title',
  'improve_save_job_desc',
  'improve_save_job_title',
  'improve_skills_desc',
  'improve_skills_title',
  'improve_transfer_desc',
  'improve_transfer_title',
  'time_1_min',
  'time_1_tap',
  'time_2_min',
  'time_3_min',
  'time_5_min',
];

final _ph = RegExp(r'\{[a-zA-Z0-9_]+\}');

void main() {
  group('Home recommendation run 3', () {
    test('key count', () => expect(batchKeys, hasLength(50)));

    for (final key in batchKeys) {
      test('$key locales', () {
        final row = HomeRecommendationStrings.catalogForStrictCoverage[key]!;
        for (final locale in AppLocale.supportedLocales) {
          expect(row[locale]!.trim(), isNotEmpty, reason: locale);
        }
      });
      for (final locale in AppLocale.supportedLocales) {
        if (locale == 'English') continue;
        test('$key $locale not English', () {
          final row = HomeRecommendationStrings.catalogForStrictCoverage[key]!;
          expect(row[locale]!.trim(), isNot(row['English']!.trim()));
        });
      }
      test('$key placeholders', () {
        final row = HomeRecommendationStrings.catalogForStrictCoverage[key]!;
        final enPh = _ph.allMatches(row['English']!).map((m) => m.group(0)!).toSet();
        for (final locale in AppLocale.supportedLocales) {
          expect(_ph.allMatches(row[locale]!).map((m) => m.group(0)!).toSet(), enPh, reason: locale);
        }
      });
    }

    test('batch ein gate zero', () {
      final probe = L10nCatalogRegistry.probes.firstWhere((p) => p.id == 'HomeRecommendationStrings');
      final scope = batchKeys.toSet();
      final ein = probe.analyze().gateFailures.where((f) => scope.contains(f.key) && f.category == L10nCoverageFailureCategory.englishIdentical).toList();
      expect(ein, isEmpty);
    });
  });
}
