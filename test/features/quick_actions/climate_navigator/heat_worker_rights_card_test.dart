import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/heat_violation_rights_section.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/heat_worker_rights_card.dart';

void main() {
  const rightsKeys = [
    'section_worker_rights_overline',
    'section_worker_rights_title',
    'rights_applicability_art8_banner',
    'rights_disclaimer_informational',
    'rights_wbgt_workplace_vs_estimate',
    'rights_binding_law_heading',
    'rights_guidance_nonbinding_note',
    'rights_bullet_art1_definitions',
    'rights_bullet_art2_seasonal_restriction',
    'rights_bullet_art1_shaded_ventilated_qualification',
    'rights_bullet_art4_3_water',
    'rights_bullet_art4_4_shade_rest',
    'rights_bullet_art4_8_wbgt_adoption',
    'rights_bullet_art4_9_wbgt_stop',
    'rights_bullet_art6_stop_complaint_supervisor',
    'rights_bullet_art6_protection',
    'rights_bullet_art7_penalties',
    'rights_source_cite',
    'rights_al_meezan_verify_note',
  ];

  const forbiddenTokens = [
    '16008',
    'motorcycle',
    'bicycle',
    'anonymous',
    'confidential',
  ];

  Widget wrap({
    required Widget child,
    TextDirection direction = TextDirection.ltr,
    double width = 360,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Scaffold(
            body: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  test('rights keys cover all supported locales', () {
    final report = ClimateStrings.localeCoverageReport;
    for (final key in rightsKeys) {
      expect(report[key], isNull, reason: 'Missing locales for $key');
    }
  });

  test('all nine locales resolve non-empty rights strings', () {
    for (final key in rightsKeys) {
      for (final locale in AppLocale.supportedLocales) {
        final text = ClimateStrings.t(key, locale).trim();
        expect(text, isNotEmpty, reason: '$key / $locale');
      }
    }
  });

  test('English legal copy maps articles and exclusions', () {
    final art8 = ClimateStrings.t('rights_applicability_art8_banner', 'English');
    expect(art8.toLowerCase(), contains('art. 8'));
    expect(art8.toLowerCase(), contains('oil and gas'));
    expect(art8.toLowerCase(), contains('cannot infer'));

    final art48 = ClimateStrings.t('rights_bullet_art4_8_wbgt_adoption', 'English');
    final art49 = ClimateStrings.format(
      'rights_bullet_art4_9_wbgt_stop',
      'English',
      params: {
        'threshold': QatarOutdoorWorkRules.wbgtWorkStopThresholdC.toString(),
      },
    );
    expect(art48, contains('4(8)'));
    expect(art49, contains('4(9)'));
    expect(
      art49,
      contains(QatarOutdoorWorkRules.wbgtWorkStopThresholdC.toString()),
    );

    final shadedQual = ClimateStrings.t(
      'rights_bullet_art1_shaded_ventilated_qualification',
      'English',
    );
    expect(shadedQual.toLowerCase(), contains('art. 1'));
    expect(shadedQual.toLowerCase(), contains('art. 2'));
    expect(shadedQual.toLowerCase(), isNot(contains('below')));
    expect(shadedQual.toLowerCase(), isNot(contains('may work')));

    final wbgtSep = ClimateStrings.t('rights_wbgt_workplace_vs_estimate', 'English');
    expect(wbgtSep.toLowerCase(), contains('workplace wbgt'));
    expect(wbgtSep.toLowerCase(), contains('estimate'));

    final stringsSource = File(
      'lib/features/quick_actions/climate_navigator/l10n/climate_strings.dart',
    ).readAsStringSync();
    for (final token in forbiddenTokens) {
      expect(
        stringsSource.toLowerCase(),
        isNot(contains(token)),
        reason: 'rights catalog must not mention $token',
      );
    }
  });

  testWidgets('HeatViolationRightsSection shows static card (B1) without report',
      (tester) async {
    await tester.pumpWidget(
      wrap(child: const HeatViolationRightsSection(locale: 'English')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HeatWorkerRightsCard), findsOneWidget);
    expect(find.textContaining('Art. 4(8)'), findsOneWidget);
    expect(find.textContaining('Art. 4(9)'), findsWidgets);
    expect(find.textContaining('Art. 6'), findsWidgets);
    final sectionSize = tester.getSize(find.byType(HeatViolationRightsSection));
    expect(sectionSize.height, greaterThan(0));
  });

  testWidgets('Urdu RTL narrow layout renders worker rights', (tester) async {
    await tester.pumpWidget(
      wrap(
        direction: TextDirection.rtl,
        width: 320,
        themeMode: ThemeMode.dark,
        child: const HeatWorkerRightsCard(locale: 'Urdu'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HeatWorkerRightsCard), findsOneWidget);
    final rtlText = ClimateStrings.t('rights_binding_law_heading', 'Urdu');
    expect(find.textContaining(rtlText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
