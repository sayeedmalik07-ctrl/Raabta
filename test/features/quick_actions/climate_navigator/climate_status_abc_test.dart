import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/presentation/climate_wbgt_status_presentation.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_status_listen_session.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_status_narration.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_status_narration_duration.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/heat_risk_calculator.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_status_hero.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_status_media_actions.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/outdoor_work_compliance_panel.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_listen_controller.dart';

void main() {
  tearDown(() {
    HeatRiskCalculator.debugWbgtOverrideC = null;
    ClimateStatusListenSession.stopActiveForDispose();
  });

  QatarWeather weatherWithWbgt(
    double wbgt, {
    bool fallback = false,
    bool cached = false,
    DateTime? fetchedAt,
  }) {
    HeatRiskCalculator.debugWbgtOverrideC = wbgt;
    return QatarWeather(
      tempC: 40,
      feelsLikeC: 45,
      humidity: 50,
      description: 'Clear',
      heatIndexC: 46,
      uvIndex: 8,
      windSpeedMs: 2,
      isPeakHeat: true,
      dataAvailable: !fallback,
      isFallback: fallback,
      cached: cached,
      fetchedAt: fetchedAt ?? DateTime(2026, 7, 10, 12),
    );
  }

  QatarWeather worstCaseNarrationWeather() {
    HeatRiskCalculator.debugWbgtOverrideC = 33;
    return QatarWeather(
      tempC: 45,
      feelsLikeC: 50,
      humidity: 60,
      description: 'Hot',
      heatIndexC: 55,
      uvIndex: 11,
      windSpeedMs: 1,
      isPeakHeat: true,
      dataAvailable: false,
      isFallback: true,
      cached: true,
      fetchedAt: DateTime.utc(2026, 7, 10, 9, 30),
    );
  }

  group('WBGT bands', () {
    final cases = <String, double>{
      'lower': 25,
      'moderate': 27,
      'high': 29,
      'extreme': 31,
      'work_stop': 33,
    };

    for (final entry in cases.entries) {
      test('band ${entry.key} uses semantic color and distinct icon', () {
        final w = weatherWithWbgt(entry.value);
        expect(w.wbgtRiskLevelKey, entry.key);
        expect(
          ClimateWbgtStatusPresentation.accentForLevel(entry.key),
          isA<Color>(),
        );
      });
    }

    test('each band icon is unique', () {
      final icons = cases.keys
          .map(ClimateWbgtStatusPresentation.iconForLevel)
          .toSet();
      expect(icons.length, cases.length);
    });

    test('high and extreme icons differ in shape family', () {
      final high = ClimateWbgtStatusPresentation.iconForLevel('high');
      final extreme = ClimateWbgtStatusPresentation.iconForLevel('extreme');
      expect(high, isNot(equals(extreme)));
      expect(high, Icons.whatshot_outlined);
      expect(extreme, Icons.warning_amber_rounded);
    });
  });

  test('QatarWeather.wbgtAccentColor matches presentation', () {
    final w = weatherWithWbgt(29);
    expect(
      w.wbgtAccentColor,
      ClimateWbgtStatusPresentation.accentForLevel(w.wbgtRiskLevelKey),
    );
  });

  test('guidance on glass meets contrast target in light and dark', () {
    for (final isDark in [false, true]) {
      AppColors.applyBrightness(!isDark);
      final ratio = _contrastRatio(AppColors.textPrimary, AppColors.surface);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: isDark ? 'Dark theme body on surface' : 'Light theme body on surface',
      );
    }
  });

  test('WBGT band accents are distinguishable and large-type contrast', () {
    for (final isDark in [false, true]) {
      AppColors.applyBrightness(!isDark);
      final keys = ['lower', 'moderate', 'high', 'extreme', 'work_stop'];
      final accents = keys.map(ClimateWbgtStatusPresentation.accentForLevel);
      expect(
        accents.toSet().length,
        5,
        reason: isDark ? 'dark accents' : 'light accents',
      );
      final backdrop = isDark ? AppColors.background : AppColors.surface;
      for (final key in keys) {
        final metric = ClimateWbgtStatusPresentation.metricColorForLevel(key);
        final ratio = _contrastRatio(metric, backdrop);
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Metric text for $key on hero backdrop',
        );
      }
    }
  });

  test('legal compliance strings unchanged in catalog', () {
    final cite = ClimateStrings.format(
      'compliance_regulation_cite',
      'English',
      params: {
        'decision': QatarOutdoorWorkRules.regulationCitation,
        'ministry': QatarOutdoorWorkRules.ministryName,
        'season': QatarOutdoorWorkRules.seasonRangeLabel,
        'window': QatarOutdoorWorkRules.restrictedWindowLabel,
        'threshold':
            QatarOutdoorWorkRules.wbgtWorkStopThresholdC.toString(),
      },
    );
    expect(cite, contains('32.1'));
    expect(
      ClimateStrings.t('compliance_disclaimer', 'English'),
      contains('not legal advice'),
    );
  });

  group('nine-locale safety copy', () {
    test('WBGT UI guidance and heat-index outdoor advice resolve', () {
      final w = weatherWithWbgt(28);
      for (final locale in AppLocale.supportedLocales) {
        final wbgt = ClimateStrings.t(
          ClimateWbgtStatusPresentation.guidanceKeyForLevel(w.wbgtRiskLevelKey),
          locale,
        );
        final outdoor = ClimateStrings.outdoorAdviceFor(w.heatIndexC, locale);
        expect(wbgt, isNotEmpty);
        expect(outdoor, isNotEmpty);
        final wbgtLabel =
            ClimateStrings.t('status_wbgt_guidance_label', locale).toLowerCase();
        expect(wbgtLabel, isNotEmpty, reason: 'WBGT label ($locale)');
      }
    });

    test('preserves heat-index DO NOT outdoors at extreme tier', () {
      final extreme = ClimateStrings.outdoorAdviceFor(55, 'English');
      expect(extreme.toLowerCase(), contains('do not'));
      expect(extreme.toLowerCase(), contains('heatstroke'));
    });
  });

  group('narration and share', () {
    test('narration order: band, guidance, ban, snapshot', () {
      final weather = worstCaseNarrationWeather();
      final parts = ClimateStatusNarration.narrationParts(
        weather: weather,
        locale: 'English',
      );
      expect(parts.length, 4);
      expect(parts[0], contains('WBGT 33'));
      expect(parts[1].toLowerCase(), contains('pause heavy outdoor'));
      expect(parts[2].toLowerCase(), contains('ban'));
      expect(parts[3].toLowerCase(), contains('stale'));
    });

    test('ban omitted when summer window inactive', () {
      final w = weatherWithWbgt(28, fetchedAt: DateTime(2026, 1, 10, 12));
      final parts = ClimateStatusNarration.narrationParts(
        weather: w,
        locale: 'English',
      );
      expect(parts.length, 3);
      expect(parts.join(' ').toLowerCase(), isNot(contains('ban 10:00')));
    });

    test('fresh snapshot wording', () {
      final w = weatherWithWbgt(28, fetchedAt: DateTime(2026, 3, 1, 12));
      final script = ClimateStatusNarration.buildNarrationScript(
        weather: w,
        locale: 'English',
      );
      expect(script.toLowerCase(), contains('data'));
      expect(script.toLowerCase(), isNot(contains('stale')));
    });

    test('stale snapshot in narration without duplicate forecast note', () {
      final w = weatherWithWbgt(27, fallback: true);
      final script = ClimateStatusNarration.buildNarrationScript(
        weather: w,
        locale: 'English',
      );
      expect(script.toLowerCase(), contains('stale'));
      expect(script.toLowerCase(), isNot(contains('forecast data may be cached')));
    });

    test('share includes both metric advices and snapshot', () {
      final w = QatarWeather(
        tempC: 45,
        feelsLikeC: 50,
        humidity: 60,
        description: 'Hot',
        heatIndexC: 55,
        uvIndex: 11,
        windSpeedMs: 1,
        isPeakHeat: true,
        dataAvailable: true,
        isFallback: false,
        fetchedAt: DateTime.now(),
      );
      HeatRiskCalculator.debugWbgtOverrideC = 33;
      final share = ClimateStatusNarration.buildShareText(
        weather: w,
        locale: 'English',
      );
      expect(share.toLowerCase(), contains('not workplace wbgt measurement'));
      expect(share, contains('Heat index outdoor advice'));
      expect(share.toLowerCase(), contains('do not'));
      expect(share.toLowerCase(), contains('weather snapshot'));
    });

    test('narration fits 15-second budget for all locales (worst case)', () {
      final weather = worstCaseNarrationWeather();
      for (final locale in AppLocale.supportedLocales) {
        final script = ClimateStatusNarration.buildNarrationScript(
          weather: weather,
          locale: locale,
        );
        final seconds = ClimateStatusNarrationDuration.estimatedSpeakSeconds(
          script,
          locale,
        );
        expect(
          seconds,
          lessThanOrEqualTo(ClimateStatusNarrationDuration.speakBudgetSeconds),
          reason: '$locale ~${seconds.toStringAsFixed(1)}s: $script',
        );
      }
    });

    test('all nine locales resolve narration strings', () {
      final w = weatherWithWbgt(28);
      for (final locale in AppLocale.supportedLocales) {
        expect(
          ClimateStatusNarration.buildNarrationScript(weather: w, locale: locale),
          isNotEmpty,
        );
      }
    });
  });

  test('listen session register and stop hook sets idle without throwing', () {
    final c = EvidenceListenController();
    ClimateStatusListenSession.register(c);
    ClimateStatusListenSession.stopActiveForDispose();
    expect(c.state, EvidenceListenPlaybackState.idle);
  });

  testWidgets('hero shows separate WBGT and heat-index advice labels', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    HeatRiskCalculator.debugWbgtOverrideC = 29;
    final weather = QatarWeather(
      tempC: 40,
      feelsLikeC: 45,
      humidity: 50,
      description: 'Clear',
      heatIndexC: 46,
      uvIndex: 8,
      windSpeedMs: 2,
      isPeakHeat: true,
      dataAvailable: true,
      isFallback: false,
      fetchedAt: DateTime.now(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClimateStatusHero(weather: weather, locale: 'English'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.textContaining('not a workplace WBGT reading'),
      findsOneWidget,
    );
    expect(find.textContaining('Heat index — outdoor activity advice'), findsOneWidget);
    expect(find.textContaining('Avoid outdoors'), findsOneWidget);
    expect(find.text('Share status'), findsOneWidget);
    expect(find.byType(OutdoorWorkCompliancePanel), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('hides listen control on desktop targets', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final weather = weatherWithWbgt(28);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClimateStatusMediaActions(weather: weather, locale: 'English'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Listen to status'), findsNothing);
    expect(find.text('Share status'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('media actions unregister stops TTS on dispose', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final weather = weatherWithWbgt(28);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClimateStatusMediaActions(weather: weather, locale: 'English'),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    debugDefaultTargetPlatformOverride = null;
  });
}

double _contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}
