import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_workload_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/workload_guidance_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap({
    required Widget child,
    required String locale,
    TextDirection direction = TextDirection.ltr,
    ThemeMode themeMode = ThemeMode.light,
    double width = 360,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
  }

  testWidgets('shows ACGIH table without safe/unsafe comparison copy',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        child: const WorkloadGuidanceSection(locale: 'English'),
        locale: 'English',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Guidance based on ACGIH reference values'),
      findsOneWidget,
    );
    expect(find.text('28.0°C'), findsNWidgets(2));
    expect(find.text('31.0°C'), findsOneWidget);
    expect(find.text('25.0°C'), findsOneWidget);
    expect(
      find.textContaining('Not provided for continuous screening'),
      findsNWidgets(4),
    );

    final source = File(
      'lib/features/quick_actions/climate_navigator/widgets/workload_guidance_section.dart',
    ).readAsStringSync();
    expect(source.contains('wbgtEstimateC'), isFalse);
    expect(source.contains('QatarWeather'), isFalse);
    expect(source.toLowerCase(), isNot(contains('safe')));
    expect(source.toLowerCase(), isNot(contains('unsafe')));
  });

  testWidgets('heavy selection shows no continuous screening notice',
      (tester) async {
    await ClimateWorkloadPreferences.save(ClimateWorkloadCategory.heavy);
    await tester.pumpWidget(
      wrap(
        child: const WorkloadGuidanceSection(locale: 'English'),
        locale: 'English',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ACGIH does not publish continuous-work screening'),
      findsOneWidget,
    );
  });

  testWidgets('renders under RTL Urdu without overflow', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: const WorkloadGuidanceSection(locale: 'Urdu'),
        locale: 'Urdu',
        direction: TextDirection.rtl,
        width: 320,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text(ClimateStrings.t('workload_disclaimer_not_law', 'Urdu')),
      findsOneWidget,
    );
  });

  testWidgets('clear workload choice resets selection and prefs', (tester) async {
    await ClimateWorkloadPreferences.save(ClimateWorkloadCategory.moderate);
    await tester.pumpWidget(
      wrap(
        child: const WorkloadGuidanceSection(locale: 'English'),
        locale: 'English',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clear workload choice'), findsOneWidget);
    expect(
      find.text(ClimateStrings.t('workload_unset_hint', 'English')),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.text('Clear workload choice'),
      120,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Clear workload choice'));
    await tester.pumpAndSettle();

    expect(
      find.text(ClimateStrings.t('workload_unset_hint', 'English')),
      findsOneWidget,
    );
    expect(find.text('Clear workload choice'), findsNothing);

    final loaded = await ClimateWorkloadPreferences.load();
    expect(loaded.category, ClimateWorkloadCategory.unset);
  });

  testWidgets('renders in dark theme at narrow width', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: const WorkloadGuidanceSection(locale: 'English'),
        locale: 'English',
        themeMode: ThemeMode.dark,
        width: 300,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  const workloadLocaleKeys = [
  'section_workload_overline',
  'section_workload_title',
  'workload_disclaimer_not_law',
  'workload_disclaimer_weather_estimate',
  'workload_selector_prompt',
  'workload_unset_hint',
  'workload_option_light',
  'workload_option_moderate',
  'workload_option_heavy',
  'workload_option_very_heavy',
  'workload_example_light',
  'workload_example_moderate',
  'workload_example_heavy',
  'workload_example_very_heavy',
  'workload_clear_choice',
  ];

  const workloadDisclosureKeys = [
    'workload_disclaimer_not_law',
    'workload_disclaimer_weather_estimate',
    'workload_acgih_cite',
    'workload_acgih_assumptions',
    'workload_acgih_value_not_provided',
    'workload_acgih_no_continuous_screening',
  ];

  test('Malayalam and Nepali disclosure strings are not English copies', () {
    for (final key in workloadDisclosureKeys) {
      final english = ClimateStrings.t(key, 'English');
      final malayalam = ClimateStrings.t(key, 'Malayalam');
      final nepali = ClimateStrings.t(key, 'Nepali');
      expect(malayalam, isNot(equals(english)), reason: key);
      expect(nepali, isNot(equals(english)), reason: key);
      expect(malayalam.trim(), isNotEmpty, reason: key);
      expect(nepali.trim(), isNotEmpty, reason: key);
    }
  });

  test('workload keys cover all supported locales', () {
    final report = ClimateStrings.localeCoverageReport;
    for (final key in workloadLocaleKeys) {
      expect(report[key], isNull, reason: 'Missing locales for $key');
    }
  });

  test('all nine locales resolve non-empty workload labels and examples', () {
    const labelAndExampleKeys = [
      'workload_option_light',
      'workload_option_moderate',
      'workload_option_heavy',
      'workload_option_very_heavy',
      'workload_example_light',
      'workload_example_moderate',
      'workload_example_heavy',
      'workload_example_very_heavy',
    ];
    for (final key in labelAndExampleKeys) {
      for (final locale in AppLocale.supportedLocales) {
        expect(ClimateStrings.t(key, locale).trim(), isNotEmpty);
      }
    }
  });
}
