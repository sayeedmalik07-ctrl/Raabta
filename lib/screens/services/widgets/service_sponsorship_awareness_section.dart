import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';

/// General sponsorship-awareness copy for Services listings — not per-listing judgment.
class ServiceSponsorshipAwarenessSection extends StatelessWidget {
  const ServiceSponsorshipAwarenessSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.info,
      glowIntensity: 0.08,
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          iconColor: AppColors.info,
          collapsedIconColor: AppColors.textTertiary,
          title: Text(
            ServicesStrings.t('svc_sponsorship_awareness_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.info),
          ),
          subtitle: Text(
            ServicesStrings.t('svc_sponsorship_awareness_teaser', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          children: [
            Text(
              ServicesStrings.t('svc_sponsorship_awareness_body', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ServicesStrings.t('svc_sponsorship_awareness_art15', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ServicesStrings.t('svc_sponsorship_awareness_licensed', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => context.push(
                  KnowQatarScreen.route(sectionKey: 'freelance_visa'),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.info,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  ServicesStrings.t(
                    'svc_sponsorship_awareness_freelance_link',
                    locale,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ServicesStrings.t('svc_sponsorship_awareness_disclaimer', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
