import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/heat_violation_report_config.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/heat_violation_rights_section.dart';

void main() {
  group('HeatViolationReportConfig', () {
    test('B1 static card on while B2 report stays off', () {
      expect(HeatViolationReportConfig.verified, isFalse);
      expect(HeatViolationReportConfig.showStaticWorkerRightsCard, isTrue);
      expect(HeatViolationReportConfig.showRightsCard, isTrue);
      expect(HeatViolationReportConfig.showReportActions, isFalse);
    });

    test('report not visible in season while unverified', () {
      final summer = DateTime(2026, 7, 15);
      expect(
        HeatViolationReportConfig.isReportVisible(
          evaluatedAtQatarLocal: summer,
        ),
        isFalse,
      );
    });

    test('report not visible out of season while unverified', () {
      final winter = DateTime(2026, 1, 10);
      expect(
        HeatViolationReportConfig.isReportVisible(
          evaluatedAtQatarLocal: winter,
        ),
        isFalse,
      );
    });
  });

  testWidgets('HeatViolationRightsSection visible for B1 static card',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 2000)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: HeatViolationRightsSection(locale: 'English'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HeatViolationRightsSection), findsOneWidget);
    expect(
      tester.getSize(find.byType(HeatViolationRightsSection)).height,
      greaterThan(0),
    );
  });
}
