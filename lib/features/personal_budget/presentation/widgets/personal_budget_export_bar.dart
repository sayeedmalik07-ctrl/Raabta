import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';

typedef PersonalBudgetExportCallback = Future<void> Function();

class PersonalBudgetExportBar extends StatelessWidget {
  const PersonalBudgetExportBar({
    super.key,
    required this.locale,
    required this.onShareCard,
    required this.onSharePdf,
    required this.onSaveVault,
    this.busy = false,
  });

  final String locale;
  final PersonalBudgetExportCallback onShareCard;
  final PersonalBudgetExportCallback onSharePdf;
  final PersonalBudgetExportCallback onSaveVault;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.emeraldGlow,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PersonalBudgetStrings.t('pb_export_heading', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            PersonalBudgetStrings.t('pb_export_sub', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ExportButton(
                  icon: Icons.ios_share_outlined,
                  label: PersonalBudgetStrings.t('pb_share_card', locale),
                  color: AppColors.sharePurple,
                  onTap: busy ? null : onShareCard,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ExportButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: PersonalBudgetStrings.t('pb_share_pdf', locale),
                  color: AppColors.emeraldGlow,
                  onTap: busy ? null : onSharePdf,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: _ExportButton(
              icon: Icons.folder_special_outlined,
              label: PersonalBudgetStrings.t('pb_save_vault', locale),
              color: AppColors.cyanGlow,
              onTap: busy ? null : onSaveVault,
              filled: true,
            ),
          ),
          if (busy) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.emeraldGlow,
              backgroundColor: AppColors.surfaceElevated,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
