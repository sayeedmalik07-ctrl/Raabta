import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';

void main() {
  const acclimatizationKeys = [
    'section_acclimat_overline',
    'section_acclimat_title',
    'acclimat_outdoor_question',
    'acclimat_outdoor_yes',
    'acclimat_outdoor_no',
    'acclimat_entry_prompt',
    'acclimat_choice_new',
    'acclimat_choice_returning',
    'acclimat_start_date_label',
    'acclimat_concierge_prefill',
    'acclimat_concierge_prefill_unavailable',
    'acclimat_save',
    'acclimat_edit',
    'acclimat_clear',
    'acclimat_active_summary',
    'acclimat_scaffold_note',
    'acclimat_heat_guide_link',
    'acclimat_storage_error',
    'acclimat_concierge_prefill_error',
    'acclimat_schedule_disclaimer_occupational',
    'acclimat_schedule_disclaimer_not_proof',
    'acclimat_schedule_disclaimer_risk',
    'acclimat_schedule_plan_day',
    'acclimat_schedule_exposure_cap',
    'acclimat_schedule_baseline_explainer',
    'acclimat_schedule_guidance_ramp',
    'acclimat_schedule_guidance_supervision',
    'acclimat_schedule_guidance_after_supervision',
    'acclimat_schedule_guidance_not_started',
    'acclimat_schedule_not_started',
    'acclimat_schedule_source',
  ];

  test('acclimatization keys cover all supported locales', () {
    final report = ClimateStrings.localeCoverageReport;
    for (final key in acclimatizationKeys) {
      expect(report[key], isNull, reason: 'Missing locales for $key');
    }
  });

  const reminderKeys = [
    'heat_reminder_title',
    'heat_reminder_body',
    'heat_reminder_body_restricted',
    'heat_reminder_before_shift_title',
    'heat_reminder_before_shift_body',
    'heat_reminder_forecast_basis',
    'heat_reminder_active_start',
    'heat_reminder_active_end',
    'heat_reminder_quiet_start',
    'heat_reminder_quiet_end',
    'heat_reminder_before_shift_label',
    'heat_reminder_permission_denied',
    'heat_reminder_open_settings',
    'hydration_reminder_toggle_label',
    'hydration_reminder_toggle_subtitle',
  ];

  test('reminder keys are not missing locales in catalog coverage', () {
    final report = ClimateStrings.localeCoverageReport;
    for (final key in reminderKeys) {
      expect(report[key], isNull, reason: 'Missing locales for $key');
    }
  });

  test('Malayalam and Nepali are not English copies for reminder keys', () {
    for (final key in reminderKeys) {
      final english = ClimateStrings.t(key, 'English');
      final malayalam = ClimateStrings.t(key, 'Malayalam');
      final nepali = ClimateStrings.t(key, 'Nepali');
      expect(malayalam, isNot(equals(english)), reason: key);
      expect(nepali, isNot(equals(english)), reason: key);
    }
  });

  test('all nine locales resolve non-empty reminder strings', () {
    for (final key in reminderKeys) {
      for (final locale in AppLocale.supportedLocales) {
        expect(ClimateStrings.t(key, locale).trim(), isNotEmpty);
      }
    }
  });

  const workerRightsKeys = [
    'section_worker_rights_overline',
    'section_worker_rights_title',
    'rights_applicability_art8_banner',
    'rights_wbgt_workplace_vs_estimate',
    'rights_bullet_art4_8_wbgt_adoption',
    'rights_bullet_art4_9_wbgt_stop',
  ];

  test('worker rights keys are not missing locales in catalog coverage', () {
    final report = ClimateStrings.localeCoverageReport;
    for (final key in workerRightsKeys) {
      expect(report[key], isNull, reason: 'Missing locales for $key');
    }
  });
}
