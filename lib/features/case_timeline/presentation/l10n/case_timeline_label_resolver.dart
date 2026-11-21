import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';

/// Resolves checklist title keys from each engine's l10n catalog.
abstract final class CaseTimelineLabelResolver {
  static String checklistTitle(
    CaseTimelineEngineType engine,
    String titleKey,
    String locale,
  ) {
    return switch (engine) {
      CaseTimelineEngineType.eosb => EosbStrings.t(titleKey, locale),
      CaseTimelineEngineType.healthInsurance =>
        HealthInsuranceStrings.t(titleKey, locale),
      CaseTimelineEngineType.tenancy => TenancyStrings.t(titleKey, locale),
      CaseTimelineEngineType.sponsorshipTransfer =>
        SponsorshipTransferStrings.t(titleKey, locale),
    };
  }

  static String checklistSubtitle(
    CaseTimelineEngineType engine,
    String? subtitleKey,
    String locale,
  ) {
    if (subtitleKey == null || subtitleKey.isEmpty) return '';
    if (subtitleKey.startsWith('ct_')) {
      return CaseTimelineStrings.t(subtitleKey, locale);
    }
    return switch (engine) {
      CaseTimelineEngineType.eosb => EosbStrings.t(subtitleKey, locale),
      CaseTimelineEngineType.healthInsurance =>
        HealthInsuranceStrings.t(subtitleKey, locale),
      CaseTimelineEngineType.tenancy => TenancyStrings.t(subtitleKey, locale),
      CaseTimelineEngineType.sponsorshipTransfer =>
        SponsorshipTransferStrings.t(subtitleKey, locale),
    };
  }
}
