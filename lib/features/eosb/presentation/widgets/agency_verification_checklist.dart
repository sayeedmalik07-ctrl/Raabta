import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Universal recruitment-agency red-flag guidance — not employer-specific.
class AgencyVerificationChecklist extends StatelessWidget {
  const AgencyVerificationChecklist({super.key, required this.locale});

  final String locale;

  static const _itemKeys = [
    'agency_verify_check_payment_before_contract',
    'agency_verify_check_recruitment_costs',
    'agency_verify_check_tourist_visa',
    'agency_verify_check_receipts',
    'agency_verify_check_messaging_only',
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.warning,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t('agency_verify_checklist_title', locale),
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
                    Icons.flag_outlined,
                    size: 18,
                    color: AppColors.warning.withValues(alpha: 0.85),
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
