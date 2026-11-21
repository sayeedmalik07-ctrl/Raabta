import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/utils/home_truth_chip_navigation.dart';

void main() {
  group('resolveTruthChipTapRoute', () {
    test('attention uses deepLink', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.attention,
        tone: TruthChipTone.amber,
        titleKey: 'tool_tenancy_title',
        statusText: 'Deposit deadline in 6 days',
        freshnessText: '',
        deepLink: '/tenancy/deadlines',
      );
      expect(resolveTruthChipTapRoute(status), '/tenancy/deadlines');
    });

    test('urgent uses deepLink', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.urgent,
        tone: TruthChipTone.red,
        titleKey: 'tool_health_insurance_title',
        statusText: 'Gap in cover',
        freshnessText: '',
        deepLink: '/health-insurance/compliance/results',
      );
      expect(
        resolveTruthChipTapRoute(status),
        '/health-insurance/compliance/results',
      );
    });

    test('tracked uses engine home route', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.tracked,
        tone: TruthChipTone.ok,
        titleKey: 'tool_eosb_title',
        statusText: 'Year 2 of service',
        freshnessText: '',
        deepLink: '/eosb/case-timeline',
      );
      expect(resolveTruthChipTapRoute(status), '/eosb');
    });

    test('invite uses engine home route', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.sponsorshipTransfer,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: 'tool_sponsorship_transfer_title',
        statusText: 'Know your rights',
        freshnessText: '',
        deepLink: '/sponsorship-transfer',
      );
      expect(resolveTruthChipTapRoute(status), '/sponsorship-transfer');
    });
  });
}
