import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/l10n_catalog_registry.dart';
import 'package:raabta/core/l10n/l10n_coverage_finding.dart';
import 'package:raabta/features/home/l10n/home_floating_ai_strings.dart';

const batchKeys = <String>[
  'action_expat_score',
  'action_find_work',
  'action_home_alert',
  'action_housing_help',
  'action_intelligence',
  'action_today_focus',
  'action_understand_expat_score',
  'action_visa_guidance',
  'assistant_semantics_label',
  'assistant_tooltip',
  'context_ask_generic',
  'context_expat_score',
  'context_expat_score_body',
  'context_home',
  'context_intelligence',
  'context_today_focus',
  'dismiss',
  'empty_context_message',
  'summary_complete_profile',
  'summary_find_work',
  'summary_home_alert',
  'summary_housing_help',
  'summary_understand_expat_score',
  'summary_visa_guidance',
  'surface_subtitle',
  'surface_title',
];

final _ph = RegExp(r'\{[a-zA-Z0-9_]+\}');

void main() {
  group('Home floating AI run 3', () {
    test('key count', () => expect(batchKeys, hasLength(26)));

    for (final key in batchKeys) {
      test('$key locales', () {
        final row = HomeFloatingAiStrings.catalogForStrictCoverage[key]!;
        for (final locale in AppLocale.supportedLocales) {
          expect(row[locale]!.trim(), isNotEmpty, reason: locale);
        }
      });
      for (final locale in AppLocale.supportedLocales) {
        if (locale == 'English') continue;
        test('$key $locale not English', () {
          final row = HomeFloatingAiStrings.catalogForStrictCoverage[key]!;
          expect(row[locale]!.trim(), isNot(row['English']!.trim()));
        });
      }
      test('$key placeholders', () {
        final row = HomeFloatingAiStrings.catalogForStrictCoverage[key]!;
        final enPh = _ph.allMatches(row['English']!).map((m) => m.group(0)!).toSet();
        for (final locale in AppLocale.supportedLocales) {
          expect(_ph.allMatches(row[locale]!).map((m) => m.group(0)!).toSet(), enPh, reason: locale);
        }
      });
    }

    test('batch ein gate zero', () {
      final probe = L10nCatalogRegistry.probes.firstWhere((p) => p.id == 'HomeFloatingAiStrings');
      final scope = batchKeys.toSet();
      final ein = probe.analyze().gateFailures.where((f) => scope.contains(f.key) && f.category == L10nCoverageFailureCategory.englishIdentical).toList();
      expect(ein, isEmpty);
    });
  });
}
