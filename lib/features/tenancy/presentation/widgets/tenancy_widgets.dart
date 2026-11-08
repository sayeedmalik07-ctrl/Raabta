import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_engine_disclaimer_banner.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';

class TenancySectionHeader extends StatelessWidget {
  const TenancySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor = AppColors.chipLease,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CalculatorSectionHeader(
      title: title,
      subtitle: subtitle,
      icon: icon,
      accentColor: accentColor,
    );
  }
}

class TenancyDisclaimerBanner extends StatelessWidget {
  const TenancyDisclaimerBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return TruthEngineDisclaimerBanner(
      text: TenancyStrings.t('tenancy_disclaimer', locale),
      style: TruthEngineDisclaimerStyle.engineContext,
      accentColor: TruthEngineStatusColors.engineAccent(TruthEngineFamily.tenancy),
      disambiguationText: TenancyStrings.t('tenancy_law_disambiguation', locale),
    );
  }
}

class TenancyCriticalBanner extends StatelessWidget {
  const TenancyCriticalBanner({super.key, required this.locale});

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
                  TenancyStrings.t('tenancy_critical_banner_title', locale),
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
            TenancyStrings.t('tenancy_critical_banner_body', locale),
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            TenancyStrings.t('tenancy_critical_banner_settlement', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.accentGold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            TenancyStrings.t('tenancy_critical_banner_action', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class TenancyComplianceResultCard extends StatelessWidget {
  const TenancyComplianceResultCard({
    super.key,
    required this.item,
    required this.locale,
  });

  final TenancyComplianceItem item;
  final String locale;

  Color _statusColor(TenancyComplianceStatus status) =>
      TruthEngineStatusColors.forTenancyCompliance(status);

  String _statusLabel(TenancyComplianceStatus status) {
    switch (status) {
      case TenancyComplianceStatus.compliant:
        return TenancyStrings.t('tenancy_status_compliant', locale);
      case TenancyComplianceStatus.violation:
        return TenancyStrings.t('tenancy_status_violation', locale);
      case TenancyComplianceStatus.critical:
        return TenancyStrings.t('tenancy_status_critical', locale);
      case TenancyComplianceStatus.needsVerification:
        return TenancyStrings.t('tenancy_status_needs_verification', locale);
      case TenancyComplianceStatus.informational:
        return TenancyStrings.t('tenancy_status_informational', locale);
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
                  TenancyStrings.t(item.titleKey, locale),
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
            TenancyStrings.t(item.explanationKey, locale),
            style: AppTypography.bodySmall,
          ),
          if (item.citationKey != null)
            LegalReferenceDisclosure(
              locale: locale,
              sourceKind: TruthEngineSourceKind.tenancy,
              citationPreview: TenancyStrings.t(item.citationKey!, locale),
              children: [
                Text(
                  TenancyStrings.t(item.citationKey!, locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.cyanGlow,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            TenancyStrings.t(item.actionKey, locale),
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
