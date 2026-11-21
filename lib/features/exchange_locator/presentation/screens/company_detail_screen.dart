import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_data_status.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/branch_card.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/exchange_data_status_banner.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/exchange_locator_skeleton.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/live_rates_link_button.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailScreen extends ConsumerStatefulWidget {
  const CompanyDetailScreen({super.key, required this.companyId});

  final String companyId;

  @override
  ConsumerState<CompanyDetailScreen> createState() =>
      _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends ConsumerState<CompanyDetailScreen> {
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    ref.invalidate(companyDetailProvider(widget.companyId));
    ref.invalidate(companyBranchesProvider(widget.companyId));
    try {
      await ref.read(companyDetailProvider(widget.companyId).future);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final companyAsync = ref.watch(companyDetailProvider(widget.companyId));
    final branchesAsync = ref.watch(companyBranchesProvider(widget.companyId));

    return companyAsync.when(
      loading: () => MoneyToolScreenScaffold(
        title: ExchangeLocatorStrings.t('company_title', locale),
        subtitle:
            ExchangeLocatorStrings.t('company_detail_subtitle', locale),
        onBack: () => context.pop(),
        onRefresh: _onRefresh,
        isRefreshing: _refreshing,
        children: const [
          ExchangeLocatorSkeletonList(),
        ],
      ),
      error: (e, _) => MoneyToolScreenScaffold(
        title: ExchangeLocatorStrings.t('company_title', locale),
        subtitle:
            ExchangeLocatorStrings.t('company_detail_subtitle', locale),
        onBack: () => context.pop(),
        onRefresh: _onRefresh,
        isRefreshing: _refreshing,
        children: [
          GlassErrorState(
            message: e.toString(),
            onRetry: () =>
                ref.invalidate(companyDetailProvider(widget.companyId)),
          ),
        ],
      ),
      data: (company) {
        if (company == null) {
          return MoneyToolScreenScaffold(
            title: ExchangeLocatorStrings.t('company_title', locale),
            subtitle:
                ExchangeLocatorStrings.t('company_detail_subtitle', locale),
            onBack: () => context.pop(),
            onRefresh: _onRefresh,
            isRefreshing: _refreshing,
            children: [
              GlassEmptyState(
                icon: Icons.business_outlined,
                title:
                    ExchangeLocatorStrings.t('company_not_found_title', locale),
                description: ExchangeLocatorStrings.t(
                  'company_not_found_description',
                  locale,
                ),
              ),
            ],
          );
        }

        return MoneyToolScreenScaffold(
          title: ExchangeLocatorStrings.t('company_title', locale),
          subtitle:
              ExchangeLocatorStrings.t('company_detail_subtitle', locale),
          onBack: () => context.pop(),
          onRefresh: _onRefresh,
          isRefreshing: _refreshing,
          children: [
            const LiveRatesLinkButton(compact: false),
            const SizedBox(height: AppSpacing.lg),
            ExchangeDataStatusBanner(
              dataStatus: company.dataStatus,
              locale: locale,
              coverageNote: company.coverageNote,
            ),
            Row(
              children: [
                if (company.logo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: CachedNetworkImage(
                      imageUrl: company.logo!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company.name, style: AppTypography.headline2),
                      Text(
                        ExchangeLocatorStrings.format(
                          'company_rating_line',
                          locale,
                          params: {
                            'rating': company.rating.toStringAsFixed(1),
                            'count': '${company.totalReviews}',
                          },
                        ),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (company.isVerified || company.isFeatured) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  if (company.isVerified)
                    StatusBadge(
                      label: ExchangeLocatorStrings.t(
                        'status_verified',
                        locale,
                      ),
                      color: AppColors.cyanGlow,
                    ),
                  if (company.isFeatured)
                    StatusBadge(
                      label: ExchangeLocatorStrings.t(
                        'status_featured',
                        locale,
                      ),
                      color: AppColors.purpleGlow,
                    ),
                ],
              ),
            ],
            if (company.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(company.description, style: AppTypography.body),
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (company.supportPhone != null)
                  _ActionChip(
                    icon: Icons.phone,
                    label: ExchangeLocatorStrings.t('action_call', locale),
                    onTap: () =>
                        launchUrl(Uri.parse('tel:${company.supportPhone}')),
                  ),
                if (company.supportWhatsapp != null)
                  _ActionChip(
                    icon: Icons.chat,
                    label:
                        ExchangeLocatorStrings.t('action_whatsapp', locale),
                    onTap: () => launchUrl(
                      Uri.parse('https://wa.me/${company.supportWhatsapp}'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                if (company.website != null)
                  _ActionChip(
                    icon: Icons.language,
                    label:
                        ExchangeLocatorStrings.t('action_website', locale),
                    onTap: () => launchUrl(
                      Uri.parse(company.website!),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              company.totalBranches > 0
                  ? ExchangeLocatorStrings.format(
                      'branches_listed',
                      locale,
                      params: {'count': '${company.totalBranches}'},
                    )
                  : ExchangeLocatorStrings.t('branches_heading', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            branchesAsync.when(
              loading: () => const ExchangeLocatorSkeletonList(count: 3),
              error: (e, _) =>
                  Text(e.toString(), style: AppTypography.bodySmall),
              data: (branches) {
                if (branches.isEmpty) {
                  return GlassEmptyState(
                    icon: Icons.store_outlined,
                    title: company.dataStatus ==
                            ExchangeDataStatus.pendingVerification
                        ? ExchangeLocatorStrings.t(
                            'branches_being_confirmed_title',
                            locale,
                          )
                        : ExchangeLocatorStrings.t(
                            'no_branches_listed_title',
                            locale,
                          ),
                    description: company.coverageNote ??
                        ExchangeLocatorStrings.t(
                          'branches_pending_description',
                          locale,
                        ),
                  );
                }
                return Column(
                  children: [
                    for (final branch in branches)
                      BranchCard(branch: branch, locale: locale),
                  ],
                );
              },
            ),
            HubFeedFooterNotice(locale: locale),
          ],
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}
