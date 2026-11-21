import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/home/utils/home_send_money_rate_utils.dart';
import 'package:raabta/services/exchange_rate_service.dart';

void main() {
  group('homeSendMoneyHomeCardSparklineValues', () {
    test('returns null without market history', () {
      expect(homeSendMoneyHomeCardSparklineValues(null), isNull);
    });

    test('returns null when history is too flat', () {
      final points = List.generate(
        7,
        (i) => RateHistoryPoint(date: '2026-01-0${i + 1}', rate: 25.86),
      );
      expect(homeSendMoneyHomeCardSparklineValues(points), isNull);
    });

    test('returns values when history has range', () {
      final points = [
        RateHistoryPoint(date: '2026-01-01', rate: 25.50),
        RateHistoryPoint(date: '2026-01-02', rate: 25.62),
        RateHistoryPoint(date: '2026-01-03', rate: 25.86),
        RateHistoryPoint(date: '2026-01-04', rate: 25.74),
      ];
      final values = homeSendMoneyHomeCardSparklineValues(points);
      expect(values, isNotNull);
      expect(values!.length, 4);
    });
  });

  test('home_feat_money catalog says Compare rates in English', () {
    expect(
      AppShellStrings.t('home_feat_money', 'English'),
      'Compare rates',
    );
  });

  test('Money Hub header action stays Money Hub', () {
    expect(
      AppShellStrings.t('home_money_hub_action', 'English'),
      'Money Hub',
    );
  });
}