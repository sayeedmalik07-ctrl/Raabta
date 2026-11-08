import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/features/exchange_locator/domain/models/branch_filters.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/branch_card.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/exchange_locator_skeleton.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class BranchFinderTab extends ConsumerStatefulWidget {
  const BranchFinderTab({super.key});

  @override
  ConsumerState<BranchFinderTab> createState() => _BranchFinderTabState();
}

class _BranchFinderTabState extends ConsumerState<BranchFinderTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  static const _horizontalInset = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(branchFinderFiltersProvider.notifier).state =
          ref.read(branchFinderFiltersProvider).copyWith(searchQuery: value);
      ref.read(branchFinderProvider.notifier).search();
    });
  }

  Future<void> _toggleFavorite(ExchangeBranch branch, String locale) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ExchangeLocatorStrings.t('sign_in_favorites', locale),
            ),
          ),
        );
      }
      return;
    }
    final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
    await repo.toggleFavorite(
      userId: user.uid,
      branchId: branch.id,
      branch: branch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final branchesAsync = ref.watch(branchFinderProvider);
    final filters = ref.watch(branchFinderFiltersProvider);
    final nearby = ref.watch(smartNearbyNotifierProvider);
    final favorites = ref.watch(favoriteBranchIdsProvider).value ?? {};

    return Column(
      children: [
        Padding(
          padding: _horizontalInset,
          child: TextField(
            controller: _searchController,
            decoration: hubSearchInputDecoration(
              hintText: ExchangeLocatorStrings.t('search_hint', locale),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: HubLayoutTokens.filterChipHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: _horizontalInset,
            children: [
              buildHubFilterChip(
                label: Text(
                  ExchangeLocatorStrings.t('filter_open_now', locale),
                ),
                selected: filters.openNowOnly,
                onSelected: (selected) {
                  ref.read(branchFinderFiltersProvider.notifier).state =
                      filters.copyWith(openNowOnly: selected);
                  ref.read(branchFinderProvider.notifier).search();
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              buildHubFilterChip(
                label: Text(ExchangeLocatorStrings.t('filter_nearby', locale)),
                selected: filters.nearbyOnly,
                onSelected: (selected) {
                  ref.read(branchFinderFiltersProvider.notifier).state =
                      filters.copyWith(
                    nearbyOnly: selected,
                    sort: BranchSortOption.nearest,
                  );
                  ref.read(branchFinderProvider.notifier).search();
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              buildHubFilterChip(
                label: Text(
                  ExchangeLocatorStrings.t('filter_top_rated', locale),
                ),
                selected: filters.sort == BranchSortOption.highestRated,
                onSelected: (selected) {
                  if (!selected) return;
                  ref.read(branchFinderFiltersProvider.notifier).state =
                      filters.copyWith(sort: BranchSortOption.highestRated);
                  ref.read(branchFinderProvider.notifier).search();
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              buildHubFilterChip(
                label: Text(
                  ExchangeLocatorStrings.t('filter_lowest_wait', locale),
                ),
                selected: filters.sort == BranchSortOption.lowestWait,
                onSelected: (selected) {
                  if (!selected) return;
                  ref.read(branchFinderFiltersProvider.notifier).state =
                      filters.copyWith(sort: BranchSortOption.lowestWait);
                  ref.read(branchFinderProvider.notifier).search();
                },
              ),
            ],
          ),
        ),
        if (nearby.permissionDenied)
          Padding(
            padding: moneyHubScreenPadding.copyWith(
              top: AppSpacing.md,
              bottom: 0,
            ),
            child: Text(
              ExchangeLocatorStrings.t('location_denied_hint', locale),
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        Expanded(
          child: branchesAsync.when(
            loading: () => ListView(
              padding: moneyHubScreenPadding.copyWith(top: AppSpacing.sm),
              children: const [
                ExchangeLocatorSkeletonList(),
              ],
            ),
            error: (e, _) => ListView(
              padding: moneyHubScreenPadding.copyWith(top: AppSpacing.sm),
              children: [
                GlassErrorState(
                  message: e.toString(),
                  onRetry: () => ref.read(branchFinderProvider.notifier).search(),
                ),
              ],
            ),
            data: (branches) {
              final scrollPadding =
                  moneyHubScreenPadding.copyWith(top: AppSpacing.sm);

              if (branches.isEmpty) {
                return ListView(
                  padding: scrollPadding,
                  children: [
                    MoneyHubEmptyState(
                      icon: Icons.search_off,
                      title: ExchangeLocatorStrings.t(
                        'no_branches_found_title',
                        locale,
                      ),
                      description: ExchangeLocatorStrings.t(
                        'no_branches_found_description',
                        locale,
                      ),
                    ),
                  ],
                );
              }

              final lat = nearby.latitude;
              final lng = nearby.longitude;

              return RefreshIndicator(
                color: moneyHubAccent,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  await ref.read(smartNearbyNotifierProvider.notifier).resolve();
                  await ref.read(branchFinderProvider.notifier).search();
                },
                child: ListView.builder(
                  padding: scrollPadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    double? dist;
                    if (lat != null && lng != null) {
                      dist = PrayerLocationService.haversineKm(
                        lat,
                        lng,
                        branch.latitude,
                        branch.longitude,
                      );
                    }
                    return BranchCard(
                      branch: branch,
                      locale: locale,
                      distanceKm: dist,
                      isFavorite: favorites.contains(branch.id),
                      onFavoriteToggle: () => _toggleFavorite(branch, locale),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
