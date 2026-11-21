import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_truth_engine_bridge_nav.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_truth_engine_bridges.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

class ScamTruthEngineGoDeeperSection extends StatelessWidget {
  const ScamTruthEngineGoDeeperSection({
    super.key,
    required this.bridges,
    required this.locale,
  });

  final List<ScamTruthEngineBridgeAction> bridges;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (bridges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ScamShieldStrings.t('ss_bridge_section_heading', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...bridges.map(
            (b) => _BridgeRow(
              action: b,
              locale: locale,
              onTap: () => ScamTruthEngineBridgeNav.go(context, b),
            ),
          ),
        ],
      ),
    );
  }
}

class _BridgeRow extends StatelessWidget {
  const _BridgeRow({
    required this.action,
    required this.locale,
    required this.onTap,
  });

  final ScamTruthEngineBridgeAction action;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _iconFor(action.target),
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScamShieldStrings.t(action.labelKey, locale),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ScamShieldStrings.t(action.reasonKey, locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  static IconData _iconFor(ScamTruthEngineBridgeTarget target) {
    return switch (target) {
      ScamTruthEngineBridgeTarget.beforeYouSign => Icons.fact_check_outlined,
      ScamTruthEngineBridgeTarget.jobOfferCalculator =>
        Icons.calculate_outlined,
      ScamTruthEngineBridgeTarget.employerTrackRecord =>
        Icons.business_outlined,
      ScamTruthEngineBridgeTarget.tenancyTruthEngine => Icons.home_outlined,
      ScamTruthEngineBridgeTarget.sponsorshipTransfer =>
        Icons.swap_horiz_outlined,
      ScamTruthEngineBridgeTarget.visaDocuments => Icons.badge_outlined,
      ScamTruthEngineBridgeTarget.eosbTruthEngine => Icons.account_balance_outlined,
      ScamTruthEngineBridgeTarget.eosbOvertime => Icons.schedule_outlined,
      ScamTruthEngineBridgeTarget.healthInsurance => Icons.health_and_safety_outlined,
      ScamTruthEngineBridgeTarget.familyVerificationKit =>
        Icons.family_restroom_outlined,
      ScamTruthEngineBridgeTarget.remittanceCorridor =>
        Icons.currency_exchange_outlined,
      ScamTruthEngineBridgeTarget.officialDirectory =>
        Icons.verified_user_outlined,
      ScamTruthEngineBridgeTarget.incidentResponse =>
        Icons.emergency_outlined,
      ScamTruthEngineBridgeTarget.authorityDirectory => Icons.report_outlined,
      ScamTruthEngineBridgeTarget.investmentCheck => Icons.trending_up_outlined,
      ScamTruthEngineBridgeTarget.reportReadyPack => Icons.folder_outlined,
    };
  }
}
