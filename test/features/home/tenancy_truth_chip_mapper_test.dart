import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/tenancy_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_compliance_checker.dart';
import 'package:raabta/services/legal_deadline_service.dart';

void main() {
  final now = DateTime(2026, 6, 15);

  TenancyComplianceResult savedResult({
    required TenancyLeaseInput input,
    required DateTime checkedAt,
  }) {
    final live = const TenancyComplianceChecker().check(input);
    return TenancyComplianceResult(
      items: live.items,
      checkedAt: checkedAt,
      lateFeeEstimate: live.lateFeeEstimate,
    );
  }

  final sensitivePattern = RegExp(
    r'QAR|landlord|\brent\b',
    caseSensitive: false,
  );

  group('TenancyTruthChipMapper — invite', () {
    test('missing saved data → invite', () {
      final status = TenancyTruthChipMapper.map(
        input: null,
        result: null,
        now: now,
      );
      expect(status.state, TruthChipState.invite);
      expect(status.statusText, contains('lease'));
    });
  });

  group('TenancyTruthChipMapper — tracked', () {
    test('future lease end → days and progress', () {
      final input = TenancyLeaseInput(
        leaseStartDate: DateTime(2025, 1, 1),
        leaseEndDate: now.add(const Duration(days: 200)),
        registrationStatus: TenancyRegistrationStatus.yes,
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.tracked);
      expect(status.statusText, contains('200'));
      expect(status.progress, isNotNull);
    });
  });

  group('TenancyTruthChipMapper — unregistered urgent', () {
    test('unregistered input + critical registration item → urgent', () {
      final input = TenancyLeaseInput(
        registrationStatus: TenancyRegistrationStatus.no,
        leaseStartDate: DateTime(2025, 1, 1),
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.statusText, 'Lease not registered');
      expect(status.pillText, 'Action');
    });

    test('registered lease → not unregistered urgent', () {
      final input = TenancyLeaseInput(
        registrationStatus: TenancyRegistrationStatus.yes,
        leaseEndDate: now.add(const Duration(days: 120)),
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.statusText, isNot('Lease not registered'));
    });
  });

  group('TenancyTruthChipMapper — lease end bands', () {
    test('70 days to end → attention', () {
      final input = TenancyLeaseInput(
        leaseStartDate: DateTime(2025, 1, 1),
        leaseEndDate: now.add(const Duration(days: 70)),
        registrationStatus: TenancyRegistrationStatus.yes,
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.attention);
      expect(status.pillText, '70d');
    });

    test('20 days to end → urgent', () {
      final input = TenancyLeaseInput(
        leaseStartDate: DateTime(2025, 1, 1),
        leaseEndDate: now.add(const Duration(days: 20)),
        registrationStatus: TenancyRegistrationStatus.yes,
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
    });
  });

  group('TenancyTruthChipMapper — deposit legal deadline', () {
    test('deposit deadline approaching before lease end', () {
      final input = TenancyLeaseInput(
        leaseStartDate: DateTime(2024, 1, 1),
        leaseEndDate: now.add(const Duration(days: 46)),
        registrationStatus: TenancyRegistrationStatus.yes,
      );
      final deadline = LegalDeadlineService.tenancyDepositReturnDeadline(
        leaseEndDate: input.leaseEndDate,
        now: now,
      );
      expect(deadline?.urgency, LegalDeadlineUrgency.approaching);

      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.attention);
      expect(status.statusText, contains('Deposit'));
    });

    test('5 days after lease end → deposit urgent', () {
      final input = TenancyLeaseInput(
        leaseStartDate: DateTime(2024, 1, 1),
        leaseEndDate: now.subtract(const Duration(days: 5)),
        registrationStatus: TenancyRegistrationStatus.yes,
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
      expect(status.statusText, contains('Deposit'));
    });
  });

  group('TenancyTruthChipMapper — stale', () {
    test('checkedAt > 90 days → Refresh', () {
      final input = TenancyLeaseInput(
        leaseEndDate: now.add(const Duration(days: 300)),
        registrationStatus: TenancyRegistrationStatus.yes,
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(
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

    test('unregistered urgent beats stale', () {
      final input = TenancyLeaseInput(
        registrationStatus: TenancyRegistrationStatus.no,
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(
          input: input,
          checkedAt: now.subtract(const Duration(days: 120)),
        ),
        now: now,
      );
      expect(status.state, TruthChipState.urgent);
    });
  });

  group('TenancyTruthChipMapper — privacy', () {
    test('status avoids money, landlord and long digit runs', () {
      final input = TenancyLeaseInput(
        landlordName: 'Hidden Landlord',
        monthlyRent: 12500,
        securityDeposit: 25000,
        leaseStartDate: DateTime(2024, 1, 1),
        leaseEndDate: now.add(const Duration(days: 60)),
        registrationStatus: TenancyRegistrationStatus.yes,
      );
      final status = TenancyTruthChipMapper.map(
        input: input,
        result: savedResult(input: input, checkedAt: now),
        now: now,
      );
      expect(status.statusText.toLowerCase(), isNot(contains('landlord')));
      expect(sensitivePattern.hasMatch(status.statusText), isFalse);
    });
  });
}
