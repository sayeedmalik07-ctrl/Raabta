import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/home/l10n/home_truth_engine_section_strings.dart';

void main() {
  group('HomeTruthEngineSectionStrings', () {
    test('all keys have nine-locale coverage', () {
      final report = HomeTruthEngineSectionStrings.localeCoverageReport;
      expect(report, isEmpty);
    });

    test('attention count substitutes count per locale', () {
      for (final locale in AppLocale.supportedLocales) {
        final s = HomeTruthEngineSectionStrings.format(
          'home_truth_attention_count',
          locale,
          params: {'count': '3'},
        );
        expect(s, contains('3'), reason: locale);
      }
    });

    test('Arabic eye labels differ from English', () {
      expect(
        HomeTruthEngineSectionStrings.t('home_truth_eye_show', 'Arabic'),
        isNot(
          HomeTruthEngineSectionStrings.t('home_truth_eye_show', 'English'),
        ),
      );
    });
  });
}
