import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_company.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_data_status.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

class CompanyCard extends StatelessWidget {
  const CompanyCard({
    super.key,
    required this.company,
    required this.locale,
  });

  final ExchangeCompany company;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: ExchangeLocatorStrings.format(
        'company_card_a11y',
        locale,
        params: {
          'name': company.name,
          'branchLabel': company.branchListingLabel,
          'rating': company.rating.toStringAsFixed(1),
        },
      ),
      child: GlassCard(
        onTap: () => context.push('/exchange-locator/company/${company.id}'),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _Logo(logoUrl: company.logo, name: company.name),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(company.name, style: AppTypography.title),
                      ),
                      if (company.isVerified)
                        StatusBadge(
                          label: ExchangeLocatorStrings.t(
                            'status_verified',
                            locale,
                          ),
                          color: AppColors.cyanGlow,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ExchangeLocatorStrings.format(
                      'company_card_rating_line',
                      locale,
                      params: {
                        'branchLabel': company.branchListingLabel,
                        'rating': company.rating.toStringAsFixed(1),
                        'count': '${company.totalReviews}',
                      },
                    ),
                    style: AppTypography.bodySmall,
                  ),
                  if (company.dataStatus == ExchangeDataStatus.partial &&
                      company.coverageNote != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      company.coverageNote!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (company.dataStatus ==
                      ExchangeDataStatus.pendingVerification) ...[
                    const SizedBox(height: AppSpacing.xs),
                    StatusBadge(
                      label: ExchangeLocatorStrings.t(
                        'details_being_confirmed',
                        locale,
                      ),
                      color: AppColors.warning,
                    ),
                  ],
                  if (company.isFeatured) ...[
                    const SizedBox(height: AppSpacing.xs),
                    StatusBadge(
                      label: ExchangeLocatorStrings.t(
                        'status_featured',
                        locale,
                      ),
                      color: AppColors.purpleGlow,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.logoUrl, required this.name});

  final String? logoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        width: 52,
        height: 52,
        color: AppColors.surfaceElevated,
        child: logoUrl != null && logoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _initial(),
                errorWidget: (_, _, _) => _initial(),
              )
            : _initial(),
      ),
    );
  }

  Widget _initial() => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTypography.headline2,
        ),
      );
}
