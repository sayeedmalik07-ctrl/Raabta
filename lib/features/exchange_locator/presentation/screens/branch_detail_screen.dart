import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raabta/config/app_config.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_review.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/crowd_report_panel.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/live_rates_link_button.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/queue_status_badge.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BranchDetailScreen extends ConsumerStatefulWidget {
  const BranchDetailScreen({super.key, required this.branchId});

  final String branchId;

  @override
  ConsumerState<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends ConsumerState<BranchDetailScreen> {
  bool _refreshing = false;

  Future<void> _onPullRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    ref.invalidate(branchDetailProvider(widget.branchId));
    ref.invalidate(branchReviewsProvider(widget.branchId));
    try {
      await ref.read(branchDetailProvider(widget.branchId).future);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final branchAsync = ref.watch(branchDetailProvider(widget.branchId));
    final reviewsAsync = ref.watch(branchReviewsProvider(widget.branchId));
    final favorites = ref.watch(favoriteBranchIdsProvider).value ?? {};
    final nearbyAsync = ref.watch(nearbyBranchesProvider);

    Widget? shareTrailing;
    branchAsync.maybeWhen(
      data: (branch) {
        if (branch != null) {
          shareTrailing = IconButton(
            tooltip: ExchangeLocatorStrings.t('tooltip_share_branch', locale),
            icon: Icon(Icons.share_outlined, color: AppColors.goldFamilyMain),
            onPressed: () => _shareBranch(branch),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          );
        }
      },
      orElse: () {},
    );

    return branchAsync.when(
        loading: () => MoneyToolScreenScaffold(
          title: ExchangeLocatorStrings.t('branch_details_title', locale),
          subtitle:
              ExchangeLocatorStrings.t('branch_details_subtitle', locale),
          onBack: () => context.pop(),
          onRefresh: _onPullRefresh,
          isRefreshing: _refreshing,
          headerTrailing: shareTrailing,
          children: const [
            MoneyHubScreenLoading(cardCount: 4, cardHeight: 110),
          ],
        ),
        error: (e, _) => MoneyToolScreenScaffold(
          title: ExchangeLocatorStrings.t('branch_details_title', locale),
          subtitle:
              ExchangeLocatorStrings.t('branch_details_subtitle', locale),
          onBack: () => context.pop(),
          onRefresh: _onPullRefresh,
          isRefreshing: _refreshing,
          headerTrailing: shareTrailing,
          children: [
            GlassErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(branchDetailProvider(widget.branchId)),
            ),
          ],
        ),
        data: (branch) {
          if (branch == null) {
            return MoneyToolScreenScaffold(
              title: ExchangeLocatorStrings.t('branch_details_title', locale),
              subtitle:
                  ExchangeLocatorStrings.t('branch_details_subtitle', locale),
              onBack: () => context.pop(),
              onRefresh: _onPullRefresh,
              isRefreshing: _refreshing,
              children: [
                GlassEmptyState(
                  icon: Icons.store_outlined,
                  title: ExchangeLocatorStrings.t('branch_not_found_title', locale),
                  description: ExchangeLocatorStrings.t(
                    'branch_not_found_description',
                    locale,
                  ),
                ),
              ],
            );
          }

          final isFavorite = favorites.contains(branch.id);

          return MoneyToolScreenScaffold(
            title: ExchangeLocatorStrings.t('branch_details_title', locale),
            subtitle:
                ExchangeLocatorStrings.t('branch_details_subtitle', locale),
            onBack: () => context.pop(),
            onRefresh: _onPullRefresh,
            isRefreshing: _refreshing,
            headerTrailing: shareTrailing,
            children: [
              if (branch.branchPhoto != null && branch.branchPhoto!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: CachedNetworkImage(
                    imageUrl: branch.branchPhoto!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(branch.branchName, style: AppTypography.headline2),
                  ),
                  Semantics(
                    button: true,
                    label: isFavorite
                        ? ExchangeLocatorStrings.t('remove_favorite_a11y', locale)
                        : ExchangeLocatorStrings.t('add_favorite_a11y', locale),
                    child: IconButton(
                      onPressed: () => _toggleFavorite(branch),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? AppColors.pinkAccent
                            : AppColors.textSecondary,
                      ),
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                  ),
                ],
              ),
              if (branch.companyName != null)
                Text(branch.companyName!, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusBadge(
                    label: branch.isOpenNow
                        ? ExchangeLocatorStrings.t('status_open_now', locale)
                        : ExchangeLocatorStrings.t('status_closed', locale),
                    color: branch.isOpenNow ? AppColors.success : AppColors.error,
                  ),
                  QueueStatusBadge(
                    status: branch.queueStatus,
                    estimatedMinutes: branch.estimatedWaitingMinutes,
                    locale: locale,
                  ),
                  if (branch.rating > 0)
                    StatusBadge(
                      label: ExchangeLocatorStrings.format(
                        'rating_with_reviews',
                        locale,
                        params: {
                          'rating': branch.rating.toStringAsFixed(1),
                          'count': '${branch.reviewCount}',
                        },
                      ),
                      color: AppColors.warning,
                    ),
                  if (branch.detailsVerified)
                    StatusBadge(
                      label: ExchangeLocatorStrings.t('status_verified', locale),
                      color: AppColors.cyanGlow,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (branch.queueLastUpdated != null)
                MoneyLiveChip(
                  label: ExchangeLocatorStrings.t('queue_status_label', locale),
                  updatedAt: branch.queueLastUpdated,
                  isLive: true,
                  accentColor: AppColors.cyanGlow,
                )
              else
                Text(
                  ExchangeLocatorStrings.formatRecency(
                    branch.queueLastUpdated,
                    locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (branch.estimatedWaitingMinutes > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                MoneyAnimatedFigure(
                  value: branch.estimatedWaitingMinutes.toDouble(),
                  suffix: ' ${ExchangeLocatorStrings.t('est_wait_suffix', locale)}',
                  decimals: 0,
                  style: AppTypography.headline2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cyanGlow,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              CrowdReportPanel(branch: branch),
              const SizedBox(height: AppSpacing.md),
              Text(
                ExchangeLocatorStrings.format(
                  'today_hours',
                  locale,
                  params: {'hours': branch.todayHours},
                ),
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              const LiveRatesLinkButton(),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(branch.latitude, branch.longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(branch.id),
                        position: LatLng(branch.latitude, branch.longitude),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(icon: Icons.location_on_outlined, text: branch.address),
              if (branch.nearestLandmark != null)
                _InfoRow(icon: Icons.place_outlined, text: branch.nearestLandmark!),
              if (branch.nearbyMetro != null)
                _InfoRow(
                  icon: Icons.train_outlined,
                  text:
                      '${branch.nearbyMetro}${branch.metroDistance != null ? ' · ${branch.metroDistance}' : ''}',
                ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _ActionButton(
                    icon: Icons.map_outlined,
                    label: ExchangeLocatorStrings.t('action_open_maps', locale),
                    onPressed: () => _openMaps(branch),
                  ),
                  _ActionButton(
                    icon: Icons.copy,
                    label: ExchangeLocatorStrings.t('action_copy_address', locale),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: branch.address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ExchangeLocatorStrings.t('address_copied', locale),
                          ),
                        ),
                      );
                    },
                  ),
                  if (branch.phone != null)
                    _ActionButton(
                      icon: Icons.phone,
                      label: ExchangeLocatorStrings.t('action_call', locale),
                      onPressed: () => launchUrl(Uri.parse('tel:${branch.phone}')),
                    ),
                  if (branch.whatsapp != null)
                    _ActionButton(
                      icon: Icons.chat,
                      label: ExchangeLocatorStrings.t('action_whatsapp', locale),
                      onPressed: () => launchUrl(
                        Uri.parse('https://wa.me/${branch.whatsapp}'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                ],
              ),
              if (branch.parkingAvailable || branch.wheelchairAccessible) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  children: [
                    if (branch.parkingAvailable)
                      _FeatureIcon(
                        icon: Icons.local_parking,
                        label: ExchangeLocatorStrings.t('feature_parking', locale),
                      ),
                    if (branch.wheelchairAccessible)
                      _FeatureIcon(
                        icon: Icons.accessible,
                        label: ExchangeLocatorStrings.t('feature_accessible', locale),
                      ),
                  ],
                ),
              ],
              if (branch.services.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  ExchangeLocatorStrings.t('services_heading', locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final s in branch.services)
                      Chip(
                        label: Text(ExchangeLocatorStrings.serviceName(s, locale)),
                      ),
                  ],
                ),
              ],
              nearbyAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (nearby) {
                  final match = nearby.where((b) => b.id == branch.id).firstOrNull;
                  if (match == null) return const SizedBox.shrink();
                  final loc = ref.read(smartNearbyNotifierProvider);
                  if (!loc.hasLocation) return const SizedBox.shrink();
                  final km = PrayerLocationService.haversineKm(
                    loc.latitude!,
                    loc.longitude!,
                    branch.latitude,
                    branch.longitude,
                  );
                  final drive = PrayerLocationService.estimateDriveMinutes(km);
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        ExchangeLocatorStrings.format(
                          'distance_and_drive',
                          locale,
                          params: {
                            'km': km.toStringAsFixed(1),
                            'minutes': '$drive',
                          },
                        ),
                        style: AppTypography.body,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Text(
                    ExchangeLocatorStrings.t('reviews_heading', locale),
                    style: AppTypography.subtitle,
                  ),
                  const Spacer(),
                  PopupMenuButton<ExchangeReviewSort>(
                    onSelected: (sort) {
                      ref.read(reviewSortProvider.notifier).state = sort;
                      ref.invalidate(branchReviewsProvider(widget.branchId));
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: ExchangeReviewSort.recent,
                        child: Text(
                          ExchangeLocatorStrings.t('sort_most_recent', locale),
                        ),
                      ),
                      PopupMenuItem(
                        value: ExchangeReviewSort.highestRating,
                        child: Text(
                          ExchangeLocatorStrings.t('sort_highest_rating', locale),
                        ),
                      ),
                    ],
                    child: const Icon(Icons.sort),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              reviewsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
                data: (page) {
                  if (page.items.isEmpty) {
                    return GlassEmptyState(
                      icon: Icons.rate_review_outlined,
                      title: ExchangeLocatorStrings.t('no_reviews_title', locale),
                      description: ExchangeLocatorStrings.t(
                        'no_reviews_description',
                        locale,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final review in page.items)
                        _ReviewTile(review: review, locale: locale),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => _showReviewSheet(branch),
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(
                  ExchangeLocatorStrings.t('write_review_button', locale),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cyanGlow,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              HubFeedFooterNotice(locale: locale),
            ],
          );
        },
    );
  }

  Future<void> _toggleFavorite(ExchangeBranch branch) async {
    final locale = ref.read(userLanguageProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ExchangeLocatorStrings.t('sign_in_favorites', locale)),
        ),
      );
      return;
    }
    final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
    await repo.toggleFavorite(
      userId: user.uid,
      branchId: branch.id,
      branch: branch,
    );
  }

  Future<void> _openMaps(ExchangeBranch branch) async {
    final url = branch.googleMapsLink ??
        'https://www.google.com/maps/dir/?api=1&destination=${branch.latitude},${branch.longitude}';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _shareBranch(ExchangeBranch branch) async {
    final locale = ref.read(userLanguageProvider);
    final deepLink =
        '${AppConfig.publicWebsiteUrl}/exchange-locator/branch/${branch.id}';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.paddingOf(ctx).bottom + AppSpacing.lg,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ExchangeLocatorStrings.t('share_branch_title', locale),
                style: AppTypography.headline2,
              ),
              const SizedBox(height: AppSpacing.md),
              QrImageView(
                data: deepLink,
                size: 120,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(branch.branchName, style: AppTypography.title),
              Text(branch.displayLocation, style: AppTypography.bodySmall),
              if (branch.phone != null)
                Text(branch.phone!, style: AppTypography.bodySmall),
              Text(
                ExchangeLocatorStrings.format(
                  'hours_label',
                  locale,
                  params: {'hours': branch.todayHours},
                ),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openMaps(branch),
                      child: Text(
                        ExchangeLocatorStrings.t('action_open_maps', locale),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Share.share(
                          '${branch.branchName}\n${branch.address}\n${branch.phone ?? ''}\n$deepLink',
                        );
                        Navigator.pop(ctx);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cyanGlow,
                        foregroundColor: AppColors.background,
                      ),
                      child: Text(
                        ExchangeLocatorStrings.t('action_share', locale),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showReviewSheet(ExchangeBranch branch) async {
    final locale = ref.read(userLanguageProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ExchangeLocatorStrings.t('sign_in_write_review', locale),
          ),
        ),
      );
      return;
    }

    final cache = await ref.read(exchangeLocatorCacheProvider.future);
    final lastReview = cache.lastReviewSubmittedAt(user.uid);
    if (lastReview != null &&
        DateTime.now().difference(lastReview) < const Duration(minutes: 2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ExchangeLocatorStrings.t('review_cooldown', locale)),
        ),
      );
      return;
    }

    final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
    if (await repo.hasUserReviewedBranch(branchId: branch.id, userId: user.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ExchangeLocatorStrings.t('already_reviewed', locale)),
        ),
      );
      return;
    }

    var rating = 5;
    final controller = TextEditingController();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ExchangeLocatorStrings.format(
                      'rate_branch',
                      locale,
                      params: {'branchName': branch.branchName},
                    ),
                    style: AppTypography.title,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () => setLocal(() => rating = i + 1),
                        icon: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: AppColors.warning,
                        ),
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      );
                    }),
                  ),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: ExchangeLocatorStrings.t('review_hint', locale),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () async {
                      try {
                        await repo.submitReview(
                          branchId: branch.id,
                          userId: user.uid,
                          rating: rating,
                          review: controller.text,
                          userDisplayName: user.displayName,
                        );
                        await cache.markReviewSubmitted(user.uid);
                        if (ctx.mounted) Navigator.pop(ctx);
                        ref.invalidate(branchReviewsProvider(widget.branchId));
                        ref.invalidate(branchDetailProvider(widget.branchId));
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.cyanGlow,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      ExchangeLocatorStrings.t('submit_review', locale),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    controller.dispose();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
        ),
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.cyanGlow),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review, required this.locale});

  final ExchangeReview review;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  review.userDisplayName ??
                      ExchangeLocatorStrings.t('review_user_fallback', locale),
                  style: AppTypography.title,
                ),
                const Spacer(),
                Text(
                  ExchangeLocatorStrings.format(
                    'review_rating_stars',
                    locale,
                    params: {'rating': '${review.rating}'},
                  ),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            if (review.review.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(review.review, style: AppTypography.body),
            ],
          ],
        ),
      ),
    );
  }
}
