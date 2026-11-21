import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_scenario.dart';
import 'package:raabta/features/sponsorship_transfer/domain/services/transfer_readiness_checker.dart';

/// Compares transfer readiness across hypothetical inputs — deterministic only.
class TransferScenarioService {
  const TransferScenarioService();

  TransferReadinessResult calculateBase(TransferReadinessInput base) {
    return TransferReadinessChecker(referenceDate: DateTime.now()).check(base);
  }

  List<TransferScenario> simulate(TransferReadinessInput base) {
    if (base.residencePermitExpiry == null && base.employmentStartDate == null) {
      return [];
    }

    final now = DateTime.now();
    final baseResult = TransferReadinessChecker(referenceDate: now).check(base);
    final baseSeverity = _severityScore(baseResult);
    final scenarios = <TransferScenario>[];

    void add({
      required String id,
      required String titleKey,
      required String descriptionKey,
      required TransferReadinessInput input,
      DateTime? referenceDate,
    }) {
      final result = TransferReadinessChecker(referenceDate: referenceDate ?? now)
          .check(input);
      scenarios.add(
        TransferScenario(
          id: id,
          titleKey: titleKey,
          descriptionKey: descriptionKey,
          input: input,
          result: result,
          differenceFromBase: _severityScore(result) - baseSeverity,
          differenceSummaryKey: _differenceSummaryKey(baseResult, result),
        ),
      );
    }

    add(
      id: 'permit_still_valid',
      titleKey: 'st_scenario_permit_valid_title',
      descriptionKey: 'st_scenario_permit_valid_desc',
      input: base.copyWith(
        residencePermitExpiry: now.add(const Duration(days: 60)),
      ),
    );

    add(
      id: 'permit_grace_window',
      titleKey: 'st_scenario_permit_grace_title',
      descriptionKey: 'st_scenario_permit_grace_desc',
      input: base.copyWith(
        residencePermitExpiry: now.subtract(const Duration(days: 45)),
      ),
    );

    add(
      id: 'permit_outside_grace',
      titleKey: 'st_scenario_permit_outside_title',
      descriptionKey: 'st_scenario_permit_outside_desc',
      input: base.copyWith(
        residencePermitExpiry: now.subtract(const Duration(days: 100)),
      ),
    );

    add(
      id: 'formal_notice_no',
      titleKey: 'st_scenario_formal_notice_no_title',
      descriptionKey: 'st_scenario_formal_notice_no_desc',
      input: base.copyWith(formalNoticeStatus: FormalNoticeStatus.no),
    );

    if (base.residencePermitExpiry != null) {
      add(
        id: 'start_in_30_days',
        titleKey: 'st_scenario_start_30_title',
        descriptionKey: 'st_scenario_start_30_desc',
        input: base,
        referenceDate: now.add(const Duration(days: 30)),
      );
      add(
        id: 'start_in_60_days',
        titleKey: 'st_scenario_start_60_title',
        descriptionKey: 'st_scenario_start_60_desc',
        input: base,
        referenceDate: now.add(const Duration(days: 60)),
      );
    }

    return scenarios;
  }

  static int _severityScore(TransferReadinessResult result) {
    if (result.hasCriticalIssue) return 4;
    if (result.hasWarning) return 3;
    if (result.items.any(
      (item) => item.status == TransferReadinessStatus.needsVerification,
    )) {
      return 2;
    }
    return 1;
  }

  static String _differenceSummaryKey(
    TransferReadinessResult base,
    TransferReadinessResult scenario,
  ) {
    if (base.permitWindowStatus != scenario.permitWindowStatus) {
      return 'st_scenario_diff_permit_${scenario.permitWindowStatus.name}';
    }
    if (base.hasCriticalIssue != scenario.hasCriticalIssue) {
      return scenario.hasCriticalIssue
          ? 'st_scenario_diff_critical_added'
          : 'st_scenario_diff_critical_removed';
    }
    if (base.hasWarning != scenario.hasWarning) {
      return scenario.hasWarning
          ? 'st_scenario_diff_warning_added'
          : 'st_scenario_diff_warning_removed';
    }
    return 'st_scenario_diff_status_changed';
  }
}
