import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/branch_card.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/exchange_locator_skeleton.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final favoritesAsync = ref.watch(favoriteBranchesProvider);
    final recentAsync = ref.watch(recentVisitsProvider);
    final favoriteIds = ref.watch(favoriteBranchIdsProvider).value ?? {};
    final signedIn = ref.watch(currentUserProvider) != null;
    final contentPadding = moneyHubScreenPadding.copyWith(top: AppSpacing.sm);

    return RefreshIndicator(
      color: AppColors.goldFamilyMain,
      onRefresh: () async {
        ref.invalidate(favoriteBranchesProvider);
        ref.invalidate(recentVisitsProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: contentPadding,
        children: [
          MoneyHubSectionHeader(
            title: MoneyHubStrings.t('branches_favorites_title', locale),
            subtitle: MoneyHubStrings.t('branches_favorites_subtitle', locale),
            compact: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          favoritesAsync.when(
            loading: () => const ExchangeLocatorSkeletonList(count: 2),
            error: (e, _) => GlassErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(favoriteBranchesProvider),
            ),
            data: (favorites) {
              if (!signedIn) {
                return MoneyHubEmptyState(
                  icon: Icons.login,
                  title: ExchangeLocatorStrings.t(
                    'sign_in_for_favorites_title',
                    locale,
                  ),
                  description: ExchangeLocatorStrings.t(
                    'sign_in_for_favorites_description',
                    locale,
                  ),
                );
              }
              if (favorites.isEmpty) {
                return MoneyHubEmptyState(
                  icon: Icons.favorite_border,
                  title: ExchangeLocatorStrings.t('no_favorites_title', locale),
                  description: ExchangeLocatorStrings.t(
                    'no_favorites_description',
                    locale,
                  ),
                );
              }
              return Column(
                children: [
                  for (final branch in favorites)
                    BranchCard(
                      branch: branch,
                      locale: locale,
                      isFavorite: true,
                      onFavoriteToggle: () => _toggle(ref, branch),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          MoneyHubSectionHeader(
            title: ExchangeLocatorStrings.t('recent_visits_heading', locale),
            compact: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          recentAsync.when(
            loading: () => const ExchangeLocatorSkeletonList(count: 2),
            error: (e, _) => GlassErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(recentVisitsProvider),
            ),
            data: (recent) {
              if (recent.isEmpty) {
                return MoneyHubEmptyState(
                  icon: Icons.history,
                  title: ExchangeLocatorStrings.t(
                    'no_recent_visits_title',
                    locale,
                  ),
                  description: ExchangeLocatorStrings.t(
                    'no_recent_visits_description',
                    locale,
                  ),
                );
              }
              return Column(
                children: [
                  for (final branch in recent)
                    BranchCard(
                      branch: branch,
                      locale: locale,
                      isFavorite: favoriteIds.contains(branch.id),
                      onFavoriteToggle: () => _toggle(ref, branch),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref, ExchangeBranch branch) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
    await repo.toggleFavorite(
      userId: user.uid,
      branchId: branch.id,
      branch: branch,
    );
  }
}
