import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/l10n_catalog_registry.dart';
import 'package:raabta/core/l10n/l10n_coverage_finding.dart';
import 'package:raabta/features/home/l10n/home_ai_feed_strings.dart';

const batchKeys = <String>[
  'feed_business_cta',
  'feed_business_fallback_title',
  'feed_cache_relative',
  'feed_date_recently',
  'feed_day_today',
  'feed_day_tomorrow',
  'feed_day_week',
  'feed_event_cta',
  'feed_event_fallback_name',
  'feed_event_subtitle',
  'feed_event_title',
  'feed_exchange_cta',
  'feed_exchange_subtitle',
  'feed_exchange_title_down',
  'feed_exchange_title_up',
  'feed_gov_fallback_title',
  'feed_housing_cta',
  'feed_housing_subtitle',
  'feed_housing_title',
  'feed_job_cta',
  'feed_job_fallback_company',
  'feed_job_fallback_title',
  'feed_job_subtitle',
  'feed_job_title',
  'feed_learn_more',
  'feed_offline_note',
  'feed_price_free',
  'feed_property_fallback',
  'feed_referral_cta',
  'feed_referral_sub_boost',
  'feed_referral_sub_premium',
  'feed_referral_title',
  'feed_relative_days',
  'feed_relative_hours',
  'feed_relative_minutes',
  'feed_score_title',
  'feed_sponsor_label',
  'feed_sponsored_fallback',
  'feed_visa_cta',
  'feed_visa_fallback',
  'feed_visa_subtitle',
  'feed_visa_title',
  'feed_welcome_cta',
  'feed_welcome_subtitle',
  'feed_welcome_title',
  'for_you_because_event_area',
  'for_you_because_event_week',
  'for_you_because_exchange_down',
  'for_you_because_exchange_rates',
  'for_you_because_exchange_up',
  'for_you_because_housing_area',
  'for_you_because_housing_match',
  'for_you_because_job_match',
  'for_you_because_job_profession',
  'for_you_because_visa_update',
];

final _ph = RegExp(r'\{[a-zA-Z0-9_]+\}');

void main() {
  group('Home AI feed run 3', () {
    test('key count', () => expect(batchKeys, hasLength(55)));

    for (final key in batchKeys) {
      test('$key locales', () {
        final row = HomeAiFeedStrings.catalogForStrictCoverage[key]!;
        for (final locale in AppLocale.supportedLocales) {
          expect(row[locale]!.trim(), isNotEmpty, reason: locale);
        }
      });
      for (final locale in AppLocale.supportedLocales) {
        if (locale == 'English') continue;
        test('$key $locale not English', () {
          final row = HomeAiFeedStrings.catalogForStrictCoverage[key]!;
          expect(row[locale]!.trim(), isNot(row['English']!.trim()));
        });
      }
      test('$key placeholders', () {
        final row = HomeAiFeedStrings.catalogForStrictCoverage[key]!;
        final enPh = _ph.allMatches(row['English']!).map((m) => m.group(0)!).toSet();
        for (final locale in AppLocale.supportedLocales) {
          expect(_ph.allMatches(row[locale]!).map((m) => m.group(0)!).toSet(), enPh, reason: locale);
        }
      });
    }

    test('batch ein gate zero', () {
      final probe = L10nCatalogRegistry.probes.firstWhere((p) => p.id == 'HomeAiFeedStrings');
      final scope = batchKeys.toSet();
      final ein = probe.analyze().gateFailures.where((f) => scope.contains(f.key) && f.category == L10nCoverageFailureCategory.englishIdentical).toList();
      expect(ein, isEmpty);
    });
  });
}
