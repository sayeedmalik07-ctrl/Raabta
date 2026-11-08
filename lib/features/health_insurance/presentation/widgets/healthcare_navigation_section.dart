import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';
import 'package:raabta/models/visa_models.dart';

/// Lightweight Qatar-specific healthcare navigation — informational only.
class HealthcareNavigationSection extends StatelessWidget {
  const HealthcareNavigationSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.chipHealthInsurance,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthInsuranceSectionHeader(
            title: HealthInsuranceStrings.t('hi_nav_title', locale),
            subtitle: HealthInsuranceStrings.t('hi_nav_subtitle', locale),
            icon: Icons.local_hospital_outlined,
            accentColor: AppColors.chipHealthInsurance,
          ),
          Text(
            HealthInsuranceStrings.t('hi_nav_disclaimer', locale),
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoBlock(
            title: HealthInsuranceStrings.t('hi_nav_system_title', locale),
            body: HealthInsuranceStrings.t('hi_nav_system_body', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoBlock(
            title: HealthInsuranceStrings.t('hi_nav_healthcard_title', locale),
            body: HealthInsuranceStrings.t('hi_nav_healthcard_body', locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoBlock(
            title: HealthInsuranceStrings.t('hi_nav_emergency_title', locale),
            body: HealthInsuranceStrings.t('hi_nav_emergency_body', locale),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final contact in emergencyContacts.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.phone_in_talk_outlined,
                    size: 18,
                    color: AppColors.chipHealthInsurance.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: AppTypography.title.copyWith(fontSize: 13),
                        ),
                        Text(
                          '${contact.number} — ${contact.description}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title.copyWith(fontSize: 13)),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          body,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
