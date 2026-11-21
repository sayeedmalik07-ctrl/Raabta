import 'package:raabta/features/home/domain/eosb_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/health_insurance_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/sponsorship_transfer_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/tenancy_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/l10n/truth_chip_eosb_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_health_insurance_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_sponsorship_transfer_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_tenancy_strings.dart';

/// Safe invite-shaped status when chip data is unavailable (errors / guest).
abstract final class TruthChipInviteFallback {
  TruthChipInviteFallback._();

  static TruthChipStatus forEngine(TruthChipEngine engine, String locale) {
    return switch (engine) {
      TruthChipEngine.eosb => TruthChipStatus(
          engine: engine,
          state: TruthChipState.invite,
          tone: TruthChipTone.neutral,
          titleKey: EosbTruthChipMapper.titleKey,
          statusText: TruthChipEosbStrings.t('truth_chip_eosb_invite', locale),
          freshnessText: '',
          deepLink: engine.homeRoute,
        ),
      TruthChipEngine.sponsorshipTransfer => TruthChipStatus(
          engine: engine,
          state: TruthChipState.invite,
          tone: TruthChipTone.neutral,
          titleKey: SponsorshipTransferTruthChipMapper.titleKey,
          statusText: TruthChipSponsorshipTransferStrings.t(
            'truth_chip_st_invite',
            locale,
          ),
          freshnessText: '',
          deepLink: engine.homeRoute,
        ),
      TruthChipEngine.tenancy => TruthChipStatus(
          engine: engine,
          state: TruthChipState.invite,
          tone: TruthChipTone.neutral,
          titleKey: TenancyTruthChipMapper.titleKey,
          statusText:
              TruthChipTenancyStrings.t('truth_chip_tenancy_invite', locale),
          freshnessText: '',
          deepLink: engine.homeRoute,
        ),
      TruthChipEngine.healthInsurance => TruthChipStatus(
          engine: engine,
          state: TruthChipState.invite,
          tone: TruthChipTone.neutral,
          titleKey: HealthInsuranceTruthChipMapper.titleKey,
          statusText:
              TruthChipHealthInsuranceStrings.t('truth_chip_hi_invite', locale),
          freshnessText: '',
          deepLink: engine.homeRoute,
        ),
    };
  }
}
