import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_source_tier_badge.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Presentation-only JobCard (hub kit §4). Batch B will wire Jobs feed to this.
class HubJobCard extends StatelessWidget {
  const HubJobCard({
    super.key,
    required this.title,
    required this.employerLine,
    required this.freshnessLine,
    this.leadingInitial,
    this.leadingIcon,
    this.salaryLine,
    this.sourceTierBadge,
    this.trailing,
    this.footer,
    this.onTap,
  });

  final String title;
  final String employerLine;
  final String freshnessLine;
  final String? leadingInitial;
  final IconData? leadingIcon;
  final String? salaryLine;
  final ({String label, HubJobSourceTier tier})? sourceTierBadge;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showSalary = salaryLine != null && salaryLine!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LeadingTile(
                    initial: leadingInitial,
                    icon: leadingIcon,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.h3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          employerLine,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sourceTierBadge != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          HubSourceTierBadge(
                            label: sourceTierBadge!.label,
                            tier: sourceTierBadge!.tier,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (showSalary) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  salaryLine!,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.goldFamilyMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                freshnessLine,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.md),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingTile extends StatelessWidget {
  const _LeadingTile({this.initial, this.icon});

  final String? initial;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return HomeIconBadge(
        icon: icon!,
        accentColor: AppColors.brandFamilyMain,
        size: HubLayoutTokens.jobCardLeadingSize,
        iconSize: 22,
        variant: HomeIconBadgeVariant.exploreBrand,
        chipBorderRadius: AppRadius.md,
      );
    }

    final raw = (initial ?? '?').trim();
    final letter =
        raw.isEmpty ? '?' : raw.substring(0, 1).toUpperCase();
    return SizedBox(
      width: HubLayoutTokens.jobCardLeadingSize,
      height: HubLayoutTokens.jobCardLeadingSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTextStyles.h3.copyWith(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
