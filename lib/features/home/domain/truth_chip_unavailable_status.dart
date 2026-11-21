import 'package:raabta/features/home/domain/eosb_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/health_insurance_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/sponsorship_transfer_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/tenancy_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/l10n/home_truth_chip_ui_strings.dart';

/// Provider-failure status — not invite (no saved data yet).
abstract final class TruthChipUnavailableStatus {
  TruthChipUnavailableStatus._();

  static TruthChipStatus forEngine(TruthChipEngine engine, String locale) {
    final statusText =
        HomeTruthChipUiStrings.t('truth_chip_status_unavailable', locale);
    return TruthChipStatus.unavailable(
      engine: engine,
      titleKey: _titleKeyForEngine(engine),
      statusText: statusText,
      deepLink: engine.homeRoute,
    );
  }

  static String _titleKeyForEngine(TruthChipEngine engine) => switch (engine) {
        TruthChipEngine.eosb => EosbTruthChipMapper.titleKey,
        TruthChipEngine.sponsorshipTransfer =>
          SponsorshipTransferTruthChipMapper.titleKey,
        TruthChipEngine.tenancy => TenancyTruthChipMapper.titleKey,
        TruthChipEngine.healthInsurance =>
          HealthInsuranceTruthChipMapper.titleKey,
      };
}
