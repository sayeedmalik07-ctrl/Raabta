import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_home_priority.dart';
import 'package:raabta/features/home/domain/truth_home_priority_resolver.dart';

TruthChipStatus _status(
  TruthChipEngine engine,
  TruthChipState state, {
  TruthChipTone tone = TruthChipTone.neutral,
  String statusText = 'line',
}) {
  return TruthChipStatus(
    engine: engine,
    state: state,
    tone: tone,
    titleKey: 'k',
    statusText: statusText,
    freshnessText: '',
    deepLink: engine.homeRoute,
  );
}

void main() {
  group('TruthHomePriorityResolver.pickHighest', () {
    test('urgent beats attention', () {
      final pick = TruthHomePriorityResolver.pickHighest([
        _status(TruthChipEngine.eosb, TruthChipState.attention,
            tone: TruthChipTone.amber),
        _status(TruthChipEngine.tenancy, TruthChipState.urgent,
            tone: TruthChipTone.red),
      ]);
      expect(pick?.engine, TruthChipEngine.tenancy);
    });

    test('tie-breaks by engine order', () {
      final pick = TruthHomePriorityResolver.pickHighest([
        _status(TruthChipEngine.healthInsurance, TruthChipState.attention,
            tone: TruthChipTone.amber, statusText: 'a'),
        _status(TruthChipEngine.eosb, TruthChipState.attention,
            tone: TruthChipTone.amber, statusText: 'b'),
      ]);
      expect(pick?.engine, TruthChipEngine.eosb);
    });

    test('red tone beats amber at same state', () {
      final pick = TruthHomePriorityResolver.pickHighest([
        _status(TruthChipEngine.tenancy, TruthChipState.stale,
            tone: TruthChipTone.amber),
        _status(TruthChipEngine.eosb, TruthChipState.stale,
            tone: TruthChipTone.red),
      ]);
      expect(pick?.engine, TruthChipEngine.eosb);
    });
  });

  group('TruthHomePriorityResolver dedupe', () {
    test('suppresses matching chip line when banner shows same text', () {
      const chip = TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.urgent,
        tone: TruthChipTone.red,
        titleKey: 'k',
        statusText: 'Filing window · 9 days',
        freshnessText: 'From estimate',
        deepLink: '/eosb',
      );
      const priority = TruthHomePriority.ready(chip);
      expect(
        TruthHomePriorityResolver.shouldSuppressChipStatusLine(
          chip: chip,
          priority: priority,
        ),
        isTrue,
      );
      final display = TruthHomePriorityResolver.forChipDisplay(
        chip: chip,
        priority: priority,
      );
      expect(display.statusText, isEmpty);
      expect(display.pillText, chip.pillText);
    });

    test('does not suppress other engines', () {
      const chip = TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.attention,
        tone: TruthChipTone.amber,
        titleKey: 'k',
        statusText: 'Lease ends soon',
        freshnessText: '',
        deepLink: '/tenancy',
      );
      const priority = TruthHomePriority.ready(
        TruthChipStatus(
          engine: TruthChipEngine.eosb,
          state: TruthChipState.urgent,
          tone: TruthChipTone.red,
          titleKey: 'k',
          statusText: 'Other',
          freshnessText: '',
          deepLink: '/eosb',
        ),
      );
      expect(
        TruthHomePriorityResolver.forChipDisplay(chip: chip, priority: priority),
        chip,
      );
    });
  });
}
