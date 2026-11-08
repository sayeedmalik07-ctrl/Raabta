import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';

class ServicesHubAllServicesRow extends StatelessWidget {
  const ServicesHubAllServicesRow({super.key, required this.locale});

  final String locale;

  static const rowKey = Key('services_hub_all_services_row');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: KeyedSubtree(
        key: rowKey,
        child: GlassCard(
          onTap: () => context.push('/services/all'),
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: AppSpacing.radiusLg,
          glowColor: AppColors.brandFamilyMain,
          glowIntensity: 0.06,
          child: Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: AppColors.brandFamilyMain,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ServicesStrings.t('hub_all_services_title', locale),
                      style: AppTypography.subtitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ServicesStrings.t('hub_all_services_subtitle', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
