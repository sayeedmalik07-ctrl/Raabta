import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_engine_disclaimer_banner.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';

class SponsorshipTransferDisclaimerBanner extends StatelessWidget {
  const SponsorshipTransferDisclaimerBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return TruthEngineDisclaimerBanner(
      text: SponsorshipTransferStrings.t('st_disclaimer', locale),
      style: TruthEngineDisclaimerStyle.engineContext,
      accentColor: TruthEngineStatusColors.engineAccent(
        TruthEngineFamily.sponsorshipTransfer,
      ),
      disambiguationText: SponsorshipTransferStrings.t('st_law_disambiguation', locale),
    );
  }
}

class SponsorshipTransferCriticalBanner extends StatelessWidget {
  const SponsorshipTransferCriticalBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.errorBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.errorBright),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  SponsorshipTransferStrings.t('st_critical_banner_title', locale),
                  style: AppTypography.title.copyWith(
                    color: AppColors.errorBright,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            SponsorshipTransferStrings.t('st_critical_banner_body', locale),
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class SponsorshipTransferWarningBanner extends StatelessWidget {
  const SponsorshipTransferWarningBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: AppColors.accentGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  SponsorshipTransferStrings.t('st_warning_banner_title', locale),
                  style: AppTypography.title.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            SponsorshipTransferStrings.t('st_warning_banner_body', locale),
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class TransferReadinessResultCard extends StatelessWidget {
  const TransferReadinessResultCard({
    super.key,
    required this.item,
    required this.locale,
  });

  final TransferReadinessItem item;
  final String locale;

  Color _statusColor(TransferReadinessStatus status) =>
      TruthEngineStatusColors.forTransferReadiness(status);

  String _statusLabel(TransferReadinessStatus status) {
    switch (status) {
      case TransferReadinessStatus.compliant:
        return SponsorshipTransferStrings.t('st_status_compliant', locale);
      case TransferReadinessStatus.warning:
        return SponsorshipTransferStrings.t('st_status_warning', locale);
      case TransferReadinessStatus.critical:
        return SponsorshipTransferStrings.t('st_status_critical', locale);
      case TransferReadinessStatus.needsVerification:
        return SponsorshipTransferStrings.t('st_status_needs_verification', locale);
      case TransferReadinessStatus.informational:
        return SponsorshipTransferStrings.t('st_status_informational', locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: color.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  SponsorshipTransferStrings.t(item.titleKey, locale),
                  style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _statusLabel(item.status),
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            SponsorshipTransferStrings.t(item.explanationKey, locale),
            style: AppTypography.bodySmall,
          ),
          if (item.citationKey != null)
            LegalReferenceDisclosure(
              locale: locale,
              sourceKind: TruthEngineSourceKind.sponsorshipTransfer,
              citationPreview:
                  SponsorshipTransferStrings.t(item.citationKey!, locale),
              children: [
                Text(
                  SponsorshipTransferStrings.t(item.citationKey!, locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.cyanGlow,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            SponsorshipTransferStrings.t(item.actionKey, locale),
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class SponsorshipTransferSectionHeader extends StatelessWidget {
  const SponsorshipTransferSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CalculatorSectionHeader(
      title: title,
      subtitle: subtitle,
      icon: icon,
      accentColor: AppColors.chipSponsorshipTransfer,
    );
  }
}
