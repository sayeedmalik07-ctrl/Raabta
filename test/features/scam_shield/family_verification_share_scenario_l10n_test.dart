import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';

void main() {
  group('FamilyVerificationKitStrings redesign section keys', () {
    const keys = <String>[
      'ss_fvk_share_subtitle',
      'ss_fvk_scenario_subtitle',
      'ss_fvk_share_screen_title',
      'ss_fvk_share_picker_label',
      'ss_fvk_share_cta',
      'ss_fvk_scenario_title',
      'ss_fvk_kit_hero_badge',
      'ss_fvk_kit_section_steps',
      'ss_fvk_kit_section_device',
      'ss_fvk_kit_section_family_actions',
      'ss_fvk_share_section_language',
      'ss_fvk_share_section_preview',
      'ss_fvk_share_preview_rules_heading',
      'ss_fvk_scenario_section_situation',
      'ss_fvk_scenario_section_choices',
      'ss_fvk_scenario_section_feedback',
      'ss_fvk_scenario_section_emergency',
      'ss_fvk_scenario_progress_template',
    ];

    test('non-empty for all nine locales', () {
      for (final key in keys) {
        for (final locale in AppLocale.supportedLocales) {
          expect(
            FamilyVerificationKitStrings.t(key, locale),
            isNotEmpty,
            reason: '$key / $locale',
          );
        }
      }
    });

    test('non-English differs from English for explicit keys', () {
      for (final key in keys) {
        final english = FamilyVerificationKitStrings.t(key, 'English');
        for (final locale in AppLocale.supportedLocales) {
          if (locale == 'English') continue;
          expect(
            FamilyVerificationKitStrings.t(key, locale),
            isNot(equals(english)),
            reason: '$key / $locale',
          );
        }
      }
    });

    test('scenarioProgressLine substitutes placeholders', () {
      for (final locale in AppLocale.supportedLocales) {
        final line = FamilyVerificationKitStrings.scenarioProgressLine(
          locale,
          2,
          4,
        );
        expect(line.contains('2'), isTrue, reason: locale);
        expect(line.contains('4'), isTrue, reason: locale);
        expect(line.contains('{n}'), isFalse, reason: locale);
        expect(line.contains('{m}'), isFalse, reason: locale);
      }
    });
  });
}
