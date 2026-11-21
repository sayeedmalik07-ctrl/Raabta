import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/sponsorship_transfer_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/domain/services/transfer_readiness_checker.dart';
import 'package:raabta/services/legal_deadline_service.dart';

void main() {
  final now = DateTime(2026, 6, 15);

  TransferReadinessResult savedAt({
    required TransferReadinessInput input,
    required DateTime checkedAt,
    DateTime? referenceForFields,
  }) {
    final snapshot = TransferReadinessChecker(
      referenceDate: referenceForFields ?? now,
    ).check(input);
    return TransferReadinessResult(
      items: snapshot.items,
      checkedAt: checkedAt,
      noticeMonths: snapshot.noticeMonths,
      permitWindowStatus: snapshot.permitWindowStatus,
      daysSincePermitExpiry: snapshot.daysSincePermitExpiry,
      monthsEmployed: snapshot.monthsEmployed,
      probationNoticeApplies: snapshot.probationNoticeApplies,
    );
  }

  final sensitivePattern = RegExp(
    r'QID|employer|sponsor name',
    caseSensitive: false,
  );

  group('SponsorshipTransferTruthChipMapper — invite', () {
    test('missing saved result → invite', () {
      final status = SponsorshipTransferTruthChipMapper.map(
        input: const TransferReadinessInput(),
        result: null,
        now: now,
      );
      expect(status.state, TruthChipState.invite);
      expect(status.statusText, contains('rights'));
      expect(status.deepLink, '/sponsorship-transfer');
    });
  });

  group('SponsorshipTransferTruthChipMapper — tracked', () {
    test('valid permit → transfer window days', () {
      final input = TransferReadinessInput(
        residencePermitExpiry: now.add(const Duration(days: 120)),
        employmentStartDate: DateTime(2024, 1, 1),
      );
      final status = SponsorshipTransferTruthChipMapper.map(
        input: input,
        result: savedAt(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.tracked);
      expect(status.tone, TruthChipTone.ok);
      expect(status.statusText, contains('120'));
      expect(status.progress, isNotNull);
    });

    test('missing permit date → readiness on file', () {
      const input = TransferReadinessInput();
      final status = SponsorshipTransferTruthChipMapper.map(
        input: input,
        result: savedAt(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.tracked);
      expect(status.statusText, 'Readiness check on file');
    });
  });

  group('SponsorshipTransferTruthChipMapper — grace deadlines', () {
    TransferReadinessInput graceInput(int daysRemainingOnGrace) {
      final expiry = now.subtract(
        Duration(days: 90 - daysRemainingOnGrace),
      );
      return TransferReadinessInput(
        residencePermitExpiry: expiry,
        employmentStartDate: DateTime(2020, 1, 1),
      );
    }

    test('approaching grace end (30d) → attention', () {
      final input = graceInput(30);
      final status = SponsorshipTransferTruthChipMapper.map(
        input: input,
        result: savedAt(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.attention);
      expect(status.tone, TruthChipTone.amber);
      expect(status.pillText, '30d');
      expect(status.statusText, contains('30'));
    });

    test('urgent grace end (10d) → Action', () {
      final input = graceInput(10);
      final status = SponsorshipTransferTruthChipMapper.map(
        input: input,
        result: savedAt(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.pillText, 'Action');
    });

    test('boundary 15d attention vs 14d urgent', () {
      final at15 = SponsorshipTransferTruthChipMapper.map(
        input: graceInput(15),
        result: savedAt(
          input: graceInput(15),
          checkedAt: now,
        ),
        now: now,
      );
      final at14 = SponsorshipTransferTruthChipMapper.map(
        input: graceInput(14),
        result: savedAt(
          input: graceInput(14),
          checkedAt: now,
        ),
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
    });

    test('outside 90-day grace → urgent', () {
      final input = TransferReadinessInput(
        residencePermitExpiry: now.subtract(const Duration(days: 100)),
        employmentStartDate: DateTime(2019, 1, 1),
      );
      final status = SponsorshipTransferTruthChipMapper.map(
        input: input,
        result: savedAt(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.statusText, contains('grace closed'));
      expect(status.deepLink, contains('/case-timeline/'));
    });
  });

  group('SponsorshipTransferTruthChipMapper — stale', () {
    test('checkedAt older than 90 days → Refresh', () {
      final input = TransferReadinessInput(
        residencePermitExpiry: now.add(const Duration(days: 200)),
        employmentStartDate: DateTime(2022, 1, 1),
      );
      final status = SponsorshipTransferTruthChipMapper.map(
        input: input,
        result: savedAt(
          input: input,
          checkedAt: now.subtract(
            Duration(days: TruthChipUrgencyThresholds.staleDataAgeDays + 1),
          ),
        ),
        now: now,
      );
      expect(status.state, TruthChipState.stale);
      expect(status.pillText, 'Refresh');
    });

    test('urgent grace beats stale checkedAt', () {
      final input = TransferReadinessInput(
        residencePermitExpiry: now.subtract(const Duration(days: 85)),
        employmentStartDate: DateTime(2020, 1, 1),
      );
      final status = SponsorshipTransferTruthChipMapper.map(
        input: input,
        result: savedAt(
          input: input,
          checkedAt: now.subtract(const Duration(days: 120)),
        ),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
    });
  });

  group('SponsorshipTransferTruthChipMapper — privacy', () {
    test('status text has no QID countdown or employer references', () {
      final samples = [
        SponsorshipTransferTruthChipMapper.map(
          input: null,
          result: null,
          now: now,
        ),
        SponsorshipTransferTruthChipMapper.map(
          input: TransferReadinessInput(
            residencePermitExpiry: now.add(const Duration(days: 45)),
          ),
          result: savedAt(
            input: TransferReadinessInput(
              residencePermitExpiry: now.add(const Duration(days: 45)),
            ),
            checkedAt: now,
          ),
          now: now,
        ),
        SponsorshipTransferTruthChipMapper.map(
          input: TransferReadinessInput(
            residencePermitExpiry: now.subtract(const Duration(days: 70)),
          ),
          result: savedAt(
            input: TransferReadinessInput(
              residencePermitExpiry: now.subtract(const Duration(days: 70)),
            ),
            checkedAt: now,
          ),
          now: now,
        ),
      ];

      for (final status in samples) {
        expect(sensitivePattern.hasMatch(status.statusText), isFalse);
        expect(status.statusText, isNot(contains('14-day')));
      }
    });
  });
}
