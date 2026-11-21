import 'package:raabta/features/home/domain/home_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/l10n/home_chip_status_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_eosb_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_health_insurance_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_sponsorship_transfer_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_tenancy_strings.dart';

/// Maps existing Home chip micro-lines to [TruthChipStatus] until C1 mappers wire in.
abstract final class HomeTruthChipLegacyAdapter {
  HomeTruthChipLegacyAdapter._();

  static TruthChipStatus? fromHomeChip({
    required String route,
    required String locale,
    required HomeChipStatus legacy,
  }) {
    final engine = TruthChipEngineRoutes.fromHomeRoute(route);
    if (engine == null) return null;

    if (legacy.isLoading) {
      return TruthChipStatus.loading(
        engine: engine,
        titleKey: _titleKey(engine),
        deepLink: engine.homeRoute,
      );
    }

    if (_isInvite(route, locale, legacy.line)) {
      return TruthChipStatus(
        engine: engine,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: _titleKey(engine),
        statusText: _inviteStatusText(engine, locale),
        freshnessText: '',
        deepLink: engine.homeRoute,
      );
    }

    final tone = switch (legacy.tone) {
      HomeChipStatusTone.attention => TruthChipTone.amber,
      HomeChipStatusTone.neutral => TruthChipTone.ok,
    };
    final state = legacy.tone == HomeChipStatusTone.attention
        ? TruthChipState.attention
        : TruthChipState.tracked;

    return TruthChipStatus(
      engine: engine,
      state: state,
      tone: tone,
      titleKey: _titleKey(engine),
      statusText: legacy.line,
      freshnessText: '',
      deepLink: engine.homeRoute,
    );
  }

  static bool _isInvite(String route, String locale, String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return true;
    final empty = switch (route) {
      '/eosb' => HomeChipStatusStrings.t('home_chip_eosb_empty', locale),
      '/sponsorship-transfer' =>
        HomeChipStatusStrings.t('home_chip_st_empty', locale),
      '/tenancy' => HomeChipStatusStrings.t('home_chip_tenancy_empty', locale),
      '/health-insurance' =>
        HomeChipStatusStrings.t('home_chip_hi_empty', locale),
      _ => '',
    };
    return trimmed == empty.trim();
  }

  static String _inviteStatusText(TruthChipEngine engine, String locale) {
    return switch (engine) {
      TruthChipEngine.eosb =>
        TruthChipEosbStrings.t('truth_chip_eosb_invite', locale),
      TruthChipEngine.sponsorshipTransfer => TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_invite',
          locale,
        ),
      TruthChipEngine.tenancy =>
        TruthChipTenancyStrings.t('truth_chip_tenancy_invite', locale),
      TruthChipEngine.healthInsurance =>
        TruthChipHealthInsuranceStrings.t('truth_chip_hi_invite', locale),
    };
  }

  static String _titleKey(TruthChipEngine engine) => switch (engine) {
        TruthChipEngine.eosb => 'home_tool_eosb',
        TruthChipEngine.sponsorshipTransfer => 'home_tool_transfer',
        TruthChipEngine.tenancy => 'home_tool_tenancy',
        TruthChipEngine.healthInsurance => 'home_tool_health',
      };
}
