import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/core/widgets/truth_engine_disclaimer_banner.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';

class HealthInsuranceSectionHeader extends StatelessWidget {
  const HealthInsuranceSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor = AppColors.chipHealthInsurance,
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

class MophInsurerFreshnessIndicator extends StatelessWidget {
  const MophInsurerFreshnessIndicator({
    super.key,
    required this.locale,
    required this.lastVerified,
  });

  final String locale;
  final DateTime lastVerified;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${lastVerified.year}-${lastVerified.month.toString().padLeft(2, '0')}-${lastVerified.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 16, color: AppColors.cyanGlow),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              HealthInsuranceStrings.t('hi_moph_list_freshness', locale)
                  .replaceAll('{date}', formatted),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplianceResultsPreview extends StatelessWidget {
  const ComplianceResultsPreview({
    super.key,
    required this.locale,
    required this.result,
    this.onViewAll,
  });

  final String locale;
  final ComplianceCheckResult? result;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        glowColor: AppColors.textSecondary,
        glowIntensity: 0.06,
        child: Column(
          children: [
            Icon(Icons.fact_check_outlined, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              HealthInsuranceStrings.t('hi_results_empty_title', locale),
              style: AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              HealthInsuranceStrings.t('hi_results_empty_desc', locale),
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in result!.items.take(3)) ...[
          ComplianceResultCard(item: item, locale: locale),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (onViewAll != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewAll,
              child: Text(
                HealthInsuranceStrings.t('hi_results_title', locale),
                style: AppTypography.link,
              ),
            ),
          ),
      ],
    );
  }
}

class HealthInsuranceDisclaimerBanner extends StatelessWidget {
  const HealthInsuranceDisclaimerBanner({
    super.key,
    required this.locale,
    this.strongPolicyDisclaimer = false,
  });

  final String locale;
  final bool strongPolicyDisclaimer;

  @override
  Widget build(BuildContext context) {
    final text = strongPolicyDisclaimer
        ? HealthInsuranceStrings.t('hi_policy_explainer_disclaimer', locale)
        : HealthInsuranceStrings.t('hi_disclaimer', locale);

    return TruthEngineDisclaimerBanner(
      text: text,
      style: TruthEngineDisclaimerStyle.legalWarning,
    );
  }
}

class ComplianceResultCard extends StatelessWidget {
  const ComplianceResultCard({
    super.key,
    required this.item,
    required this.locale,
  });

  final ComplianceCheckItem item;
  final String locale;

  Color _statusColor() => TruthEngineStatusColors.forHealthCompliance(item.status);

  String _statusLabel() {
    return switch (item.status) {
      HealthComplianceStatus.compliant =>
        HealthInsuranceStrings.t('hi_status_compliant', locale),
      HealthComplianceStatus.violation =>
        HealthInsuranceStrings.t('hi_status_violation', locale),
      HealthComplianceStatus.needsVerification =>
        HealthInsuranceStrings.t('hi_status_needs_verification', locale),
      HealthComplianceStatus.informational =>
        HealthInsuranceStrings.t('hi_status_informational', locale),
      HealthComplianceStatus.notApplicable =>
        HealthInsuranceStrings.t('hi_status_not_applicable', locale),
    };
  }

  IconData _statusIcon() {
    switch (item.status) {
      case HealthComplianceStatus.compliant:
        return Icons.check_circle_outline;
      case HealthComplianceStatus.violation:
        return Icons.error_outline;
      case HealthComplianceStatus.needsVerification:
        return Icons.help_outline;
      case HealthComplianceStatus.informational:
        return Icons.info_outline;
      case HealthComplianceStatus.notApplicable:
        return Icons.remove_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severity = severityForHealthStatus(item.status);
    final glow = severity == EosbWarningSeverity.critical
        ? AppColors.errorBright
        : _statusColor();
    final color = _statusColor();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: glow,
      glowIntensity: item.status == HealthComplianceStatus.violation ? 0.16 : 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_statusIcon(), color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HealthInsuranceStrings.t(item.titleKey, locale),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(),
                        style: AppTypography.chipLabel.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            HealthInsuranceStrings.t(item.explanationKey, locale),
            style: AppTypography.bodySmall,
          ),
          if (item.metadata != null && item.metadata!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.metadata!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.chipHealthInsurance),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            HealthInsuranceStrings.t(item.actionKey, locale),
            style: AppTypography.link,
          ),
        ],
      ),
    );
  }
}
