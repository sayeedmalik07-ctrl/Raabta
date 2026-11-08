import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';

void main() {
  group('CorridorResultCard MoneyComparatorStrings (Batch 1)', () {
    const batchKeys = <String>[
      'mc_community_reports_meta',
      'mc_community_stats_line',
      'mc_community_speed_hours',
      'mc_community_speed_days',
      'mc_community_updated_recently',
    ];

    test('all nine locales have non-empty templates for Batch 1 keys', () {
      for (final key in batchKeys) {
        for (final locale in AppLocale.supportedLocales) {
          expect(
            MoneyComparatorStrings.t(key, locale),
            isNotEmpty,
            reason: '$key / $locale',
          );
        }
      }
    });

    test('non-English locales do not fall back to English for Batch 1 keys',
        () {
      for (final key in batchKeys) {
        final english = MoneyComparatorStrings.t(key, 'English');
        for (final locale in AppLocale.supportedLocales) {
          if (locale == 'English') continue;
          expect(
            MoneyComparatorStrings.t(key, locale),
            isNot(equals(english)),
            reason: '$key must have a dedicated template for $locale',
          );
        }
      }
    });

    test('mc_community_reports_meta substitutes {count} and {updated}', () {
      for (final locale in AppLocale.supportedLocales) {
        final s = MoneyComparatorStrings.format(
          'mc_community_reports_meta',
          locale,
          params: {
            'count': '7',
            'updated': '2026-01-15',
          },
        );
        expect(s, contains('7'), reason: locale);
        expect(s, contains('2026-01-15'), reason: locale);
        expect(s, isNot(contains('{count}')), reason: locale);
        expect(s, isNot(contains('{updated}')), reason: locale);
      }
    });

    test('mc_community_stats_line substitutes all placeholders', () {
      for (final locale in AppLocale.supportedLocales) {
        final s = MoneyComparatorStrings.format(
          'mc_community_stats_line',
          locale,
          params: {
            'per100': '24.5',
            'code': 'INR',
            'fee': '18',
            'speed': '~12h',
          },
        );
        expect(s, contains('24.5'), reason: locale);
        expect(s, contains('INR'), reason: locale);
        expect(s, contains('18'), reason: locale);
        expect(s, contains('~12h'), reason: locale);
        expect(s, isNot(contains('{per100}')), reason: locale);
        expect(s, isNot(contains('{code}')), reason: locale);
        expect(s, isNot(contains('{fee}')), reason: locale);
        expect(s, isNot(contains('{speed}')), reason: locale);
      }
    });

    test('mc_community_speed_hours and mc_community_speed_days substitute hours/days',
        () {
      for (final locale in AppLocale.supportedLocales) {
        final hoursLine = MoneyComparatorStrings.format(
          'mc_community_speed_hours',
          locale,
          params: {'hours': '9'},
        );
        expect(hoursLine, contains('9'), reason: locale);
        expect(hoursLine, isNot(contains('{hours}')), reason: locale);

        final daysLine = MoneyComparatorStrings.format(
          'mc_community_speed_days',
          locale,
          params: {'days': '2.5'},
        );
        expect(daysLine, contains('2.5'), reason: locale);
        expect(daysLine, isNot(contains('{days}')), reason: locale);
      }
    });

    test('rte_recipient_gets and rte_go_to_provider used by community card', () {
      expect(
        MoneyComparatorStrings.t('rte_recipient_gets', 'Arabic'),
        isNot(equals(MoneyComparatorStrings.t('rte_recipient_gets', 'English'))),
      );
      final go = MoneyComparatorStrings.format(
        'rte_go_to_provider',
        'Hindi',
        params: {'provider': 'TestCo'},
      );
      expect(go, contains('TestCo'));
      expect(go, isNot(contains('{provider}')));
    });
  });
}
