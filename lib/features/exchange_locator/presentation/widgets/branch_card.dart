import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/queue_status_badge.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.branch,
    required this.locale,
    this.distanceKm,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final ExchangeBranch branch;
  final String locale;
  final double? distanceKm;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final openLabel = branch.isOpenNow
        ? ExchangeLocatorStrings.t('status_open_a11y', locale)
        : ExchangeLocatorStrings.t('status_closed_a11y', locale);

    return Semantics(
      button: true,
      label: ExchangeLocatorStrings.format(
        'branch_card_a11y',
        locale,
        params: {
          'name': branch.branchName,
          'location': branch.displayLocation,
          'status': openLabel,
        },
      ),
      child: GlassCard(
        onTap: () => context.push('/exchange-locator/branch/${branch.id}'),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (branch.branchPhoto != null && branch.branchPhoto!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusSm),
                ),
                child: CachedNetworkImage(
                  imageUrl: branch.branchPhoto!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    height: 120,
                    color: AppColors.surfaceElevated,
                  ),
                  errorWidget: (_, _, _) => Container(
                    height: 120,
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.store_outlined),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(branch.branchName, style: AppTypography.title),
                            if (branch.companyName != null)
                              Text(
                                branch.companyName!,
                                style: AppTypography.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      if (onFavoriteToggle != null)
                        Semantics(
                          button: true,
                          label: isFavorite
                              ? ExchangeLocatorStrings.t(
                                  'remove_favorite_a11y',
                                  locale,
                                )
                              : ExchangeLocatorStrings.t(
                                  'add_favorite_a11y',
                                  locale,
                                ),
                          child: IconButton(
                            onPressed: onFavoriteToggle,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? AppColors.pinkAccent
                                  : AppColors.textSecondary,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(branch.displayLocation, style: AppTypography.body),
                  if (distanceKm != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ExchangeLocatorStrings.format(
                        'distance_km_away',
                        locale,
                        params: {'km': distanceKm!.toStringAsFixed(1)},
                      ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      StatusBadge(
                        label: branch.isOpenNow
                            ? ExchangeLocatorStrings.t('status_open_now', locale)
                            : ExchangeLocatorStrings.t('status_closed', locale),
                        color: branch.isOpenNow
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      QueueStatusBadge(
                        status: branch.queueStatus,
                        locale: locale,
                        estimatedMinutes: branch.estimatedWaitingMinutes,
                      ),
                      if (branch.rating > 0)
                        StatusBadge(
                          label: ExchangeLocatorStrings.format(
                            'review_rating_stars',
                            locale,
                            params: {
                              'rating': branch.rating.toStringAsFixed(1),
                            },
                          ),
                          color: AppColors.warning,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
