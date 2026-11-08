import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Static, non-AI general job-offer safety guidance (Part F — not employer-specific).
class EmployerPreOfferSafetyChecklist extends StatelessWidget {
  const EmployerPreOfferSafetyChecklist({super.key, required this.locale});

  final String locale;

  static const _itemKeys = [
    'employer_pre_offer_check_recruitment_costs',
    'employer_pre_offer_check_official_email',
    'employer_pre_offer_check_written_offer',
    'employer_pre_offer_check_take_time',
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.accentGold,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t('employer_pre_offer_checklist_title', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._itemKeys.map(
            (key) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      EosbStrings.t(key, locale),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
