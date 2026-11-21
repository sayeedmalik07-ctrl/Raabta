import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/home/domain/eosb_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/services/legal_deadline_service.dart';

void main() {
  final now = DateTime(2026, 6, 15);

  CalculationHistoryEntry entry({
    EosbEmployeeInput? input,
    DateTime? savedAt,
    DateTime? calculatedAt,
  }) {
    return CalculationHistoryEntry(
      id: 'e1',
      input: input ?? const EosbEmployeeInput(),
      result: EosbResult(
        totalEntitlement: 0,
        breakdown: const [],
        warnings: const [],
        violations: const [],
        explanation: const CalculationExplanation(
          summaryKey: 'eosb_explanation_default',
          confidenceScore: 0.8,
          stepsKeys: [],
        ),
        calculatedAt: calculatedAt ?? now,
      ),
      savedAt: savedAt ?? now,
    );
  }

  final hiddenMoneyPattern = RegExp(
    r'QAR|\d{1,3}(?:,\d{3})+(?:\.\d+)?',
    caseSensitive: false,
  );

  group('EosbTruthChipMapper — invite', () {
    test('empty history → invite', () {
      final status = EosbTruthChipMapper.map(history: const [], now: now);
      expect(status.state, TruthChipState.invite);
      expect(status.tone, TruthChipTone.neutral);
      expect(status.statusText, contains('gratuity'));
      expect(status.showsProgressBar, isFalse);
      expect(status.deepLink, '/eosb');
    });
  });

  group('EosbTruthChipMapper — tracked', () {
    test('joining date → service year line and progress', () {
      final status = EosbTruthChipMapper.map(
        history: [
          entry(
            input: EosbEmployeeInput(
              joiningDate: DateTime(2024, 6, 15),
              basicSalary: 5000,
            ),
            savedAt: now,
          ),
        ],
        now: now,
      );
      expect(status.state, TruthChipState.tracked);
      expect(status.tone, TruthChipTone.ok);
      expect(status.statusText, 'Year 3 of service');
      expect(status.progress, isNotNull);
      expect(status.progress!, greaterThanOrEqualTo(0));
      expect(status.progress!, lessThanOrEqualTo(1));
    });

    test('no joining date → estimate on file', () {
      final status = EosbTruthChipMapper.map(
        history: [entry(savedAt: now)],
        now: now,
      );
      expect(status.state, TruthChipState.tracked);
      expect(status.statusText, 'Estimate on file');
      expect(status.progress, isNull);
    });
  });

  group('EosbTruthChipMapper — legal deadlines', () {
    CalculationHistoryEntry claimEntry(int daysRemaining) {
      final lastWorking = now.subtract(Duration(days: 365 - daysRemaining));
      return entry(
        input: EosbEmployeeInput(
          joiningDate: DateTime(2020, 1, 1),
          lastWorkingDate: lastWorking,
          basicSalary: 4000,
        ),
        savedAt: now,
      );
    }

    test('approaching labour claim (30d) → attention + pill', () {
      final status = EosbTruthChipMapper.map(
        history: [claimEntry(30)],
        now: now,
      );
      expect(status.state, TruthChipState.attention);
      expect(status.tone, TruthChipTone.amber);
      expect(status.pillText, '30d');
      expect(status.statusText, contains('30'));
      expect(status.deepLink, contains('/case-timeline/'));
    });

    test('urgent labour claim (10d) → urgent + Action', () {
      final status = EosbTruthChipMapper.map(
        history: [claimEntry(10)],
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.tone, TruthChipTone.red);
      expect(status.pillText, 'Action');
    });

    test('boundary 15d approaching vs 14d urgent', () {
      final at15 = EosbTruthChipMapper.map(
        history: [claimEntry(15)],
        now: now,
      );
      final at14 = EosbTruthChipMapper.map(
        history: [claimEntry(14)],
        now: now,
      );
      expect(at15.state, TruthChipState.attention);
      expect(
        at15.tone,
        TruthChipUrgencyThresholds.toneForLegalUrgency(
          LegalDeadlineService.urgencyForDaysRemaining(15),
        ),
      );
      expect(at14.state, TruthChipState.urgent);
      expect(
        at14.tone,
        TruthChipUrgencyThresholds.toneForLegalUrgency(
          LegalDeadlineService.urgencyForDaysRemaining(14),
        ),
      );
    });

    test('boundary 61d informational tracked vs 60d attention', () {
      final tracked = EosbTruthChipMapper.map(
        history: [claimEntry(61)],
        now: now,
      );
      final attention = EosbTruthChipMapper.map(
        history: [claimEntry(60)],
        now: now,
      );
      expect(tracked.state, TruthChipState.tracked);
      expect(attention.state, TruthChipState.attention);
    });
  });

  group('EosbTruthChipMapper — stale', () {
    test('saved older than 90 days → stale Refresh pill', () {
      final status = EosbTruthChipMapper.map(
        history: [
          entry(
            input: EosbEmployeeInput(
              joiningDate: DateTime(2022, 1, 1),
              basicSalary: 3000,
            ),
            savedAt: now.subtract(
              Duration(days: TruthChipUrgencyThresholds.staleDataAgeDays + 1),
            ),
          ),
        ],
        now: now,
      );
      expect(status.state, TruthChipState.stale);
      expect(status.tone, TruthChipTone.neutral);
      expect(status.pillText, 'Refresh');
      expect(status.countsTowardAttentionBadge, isFalse);
    });

    test('urgent deadline beats stale save age', () {
      final lastWorking = now.subtract(const Duration(days: 355));
      final status = EosbTruthChipMapper.map(
        history: [
          entry(
            input: EosbEmployeeInput(
              joiningDate: DateTime(2020, 1, 1),
              lastWorkingDate: lastWorking,
              basicSalary: 5000,
            ),
            savedAt: now.subtract(const Duration(days: 120)),
          ),
        ],
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
    });
  });

  group('EosbTruthChipMapper — privacy', () {
    test('statusText never contains QAR or formatted money', () {
      final cases = [
        EosbTruthChipMapper.map(history: const [], now: now),
        EosbTruthChipMapper.map(
          history: [
            entry(
              input: EosbEmployeeInput(
                joiningDate: DateTime(2020, 6, 1),
                basicSalary: 12_500,
                companyName: 'Acme Corp',
              ),
            ),
          ],
          now: now,
        ),
        EosbTruthChipMapper.map(
          history: [
            entry(
              input: EosbEmployeeInput(
                joiningDate: DateTime(2020, 1, 1),
                lastWorkingDate: now.subtract(const Duration(days: 355)),
                basicSalary: 8000,
                companyName: 'Hidden Employer LLC',
              ),
            ),
          ],
          now: now,
        ),
      ];

      for (final status in cases) {
        expect(status.statusText.toLowerCase(), isNot(contains('acme')));
        expect(status.statusText.toLowerCase(), isNot(contains('employer')));
        expect(hiddenMoneyPattern.hasMatch(status.statusText), isFalse);
      }
    });

    test('revealedText may show estimate amount only in reveal field', () {
      final status = EosbTruthChipMapper.map(
        history: [
          entry(
            input: EosbEmployeeInput(
              joiningDate: DateTime(2018, 1, 1),
              lastWorkingDate: DateTime(2026, 1, 1),
              basicSalary: 6000,
            ),
            savedAt: now,
          ),
        ],
        now: now,
      );
      expect(status.hasRevealableDetail, isTrue);
      expect(status.revealedText, contains('Estimate'));
      expect(status.revealedText, contains('QAR'));
      expect(hiddenMoneyPattern.hasMatch(status.statusText), isFalse);
    });
  });
}
