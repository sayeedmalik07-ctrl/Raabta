import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/classifieds_host_notice.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/features/marketplace/presentation/widgets/marketplace_listing_offers_section.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_schema_listing_display.dart';
import 'package:raabta/models/admin_report_model.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/marketplace/widgets/marketplace_listing_detail_action_bar.dart';
import 'package:raabta/screens/marketplace/widgets/marketplace_seller_payment_protection_card.dart';
import 'package:raabta/screens/marketplace/widgets/marketplace_vehicle_listing_trust_card.dart';
import 'package:raabta/services/qr/listing_deep_links.dart';
import 'package:raabta/services/qr/listing_ownership.dart';
import 'package:raabta/services/report_service.dart';
import 'package:share_plus/share_plus.dart';

class MarketplaceListingDetailScreen extends ConsumerStatefulWidget {
  const MarketplaceListingDetailScreen({
    super.key,
    required this.listingId,
    this.initialListing,
  });

  final String listingId;
  final MarketplaceListing? initialListing;

  @override
  ConsumerState<MarketplaceListingDetailScreen> createState() =>
      _MarketplaceListingDetailScreenState();
}

class _MarketplaceListingDetailScreenState
    extends ConsumerState<MarketplaceListingDetailScreen> {
  final Set<String> _savedListingIds = {};

  String _headerSubtitle(MarketplaceListing? listing, String locale) {
    if (listing == null) {
      return MarketplaceStrings.t('mp_hub_subtitle', locale);
    }
    return '${listing.area} · ${listing.posted}';
  }

  void _toggleSave(String listingId) {
    setState(() {
      if (_savedListingIds.contains(listingId)) {
        _savedListingIds.remove(listingId);
      } else {
        _savedListingIds.add(listingId);
        PostEngine().analytics.trackSave(
          listingId: listingId,
          verticalId: 'marketplace',
        );
      }
    });
  }

  void _shareListing(MarketplaceListing listing) {
    Share.share(
      '${listing.title}\n${ListingDeepLinks.marketplaceListing(listing.id)}',
    );
  }

  Widget? _buildActionBar(
    BuildContext context,
    String locale,
    MarketplaceListing? listing, {
    required bool offersEnabled,
  }) {
    if (listing == null) return null;
    return MarketplaceListingDetailActionBar(
      listing: listing,
      locale: locale,
      isOwner: isListingOwnedByCurrentUser(listing.ownerUserId),
      isSaved: _savedListingIds.contains(listing.id),
      offersEnabled: offersEnabled,
      onSave: () => _toggleSave(listing.id),
      onShare: () => _shareListing(listing),
      onContact: () {
        context.push('/marketplace/chat/${listing.id}', extra: listing.title);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final offersEnabled = ref.watch(complianceFlagsProvider).offersEnabled;

    if (widget.initialListing != null) {
      final listing = widget.initialListing!;
      final user = ref.watch(currentUserProvider);
      final isOwner =
          user != null && isListingOwnedByCurrentUser(listing.ownerUserId);
      final bottomInset = marketplaceDetailActionBarScrollInset(context);

      return HubSubscreenScaffold(
        title: listing.title,
        subtitle: _headerSubtitle(listing, locale),
        onBack: () => Navigator.of(context).pop(),
        headerTrailing: !isOwner
            ? TextButton(
                onPressed: () async {
                  await ReportService().submitReport(
                    type: AdminReportType.listing,
                    title: 'Marketplace report: ${listing.title}',
                    description:
                        'User reported marketplace listing "${listing.title}" (${listing.id})',
                    targetId: listing.id,
                    targetType: 'marketplace_listing',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          MarketplaceStrings.t('mp_report_submitted', locale),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  MarketplaceStrings.t('mp_report_listing', locale),
                  style: AppTypography.caption.copyWith(color: AppColors.error),
                ),
              )
            : null,
        bottomNavigationBar: _buildActionBar(
          context,
          locale,
          listing,
          offersEnabled: offersEnabled,
        ),
        body: _DetailBody(
          listing: listing,
          locale: locale,
          isOwner: isOwner,
          bottomInset: bottomInset,
          offersEnabled: offersEnabled,
        ),
      );
    }

    final listingAsync = ref.watch(
      marketplaceListingDetailProvider(widget.listingId),
    );

    return listingAsync.when(
      loading: () => HubSubscreenScaffold(
        title: MarketplaceStrings.t('mp_listing_detail_title', locale),
        subtitle: MarketplaceStrings.t('mp_hub_subtitle', locale),
        onBack: () => Navigator.of(context).pop(),
        body: Center(
          child: HubLoadingPlaceholder(
            width: MediaQuery.sizeOf(context).width - AppSpacing.xl * 2,
            height: 280,
            silhouette: HubLoadingSilhouette.listing,
          ),
        ),
      ),
      error: (error, _) => HubSubscreenScaffold(
        title: MarketplaceStrings.t('mp_listing_detail_title', locale),
        subtitle: MarketplaceStrings.t('mp_hub_subtitle', locale),
        onBack: () => Navigator.of(context).pop(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassErrorState(
              message: error.toString(),
              retryLabel: CommonActionStrings.t('action_retry', locale),
              onRetry: () => ref.invalidate(
                marketplaceListingDetailProvider(widget.listingId),
              ),
            ),
          ),
        ),
      ),
      data: (listing) {
        if (listing == null) {
          return HubSubscreenScaffold(
            title: MarketplaceStrings.t('mp_listing_detail_title', locale),
            subtitle: MarketplaceStrings.t('mp_hub_subtitle', locale),
            onBack: () => Navigator.of(context).pop(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: GlassEmptyState(
                  accent: GlassEmptyStateAccent.brand,
                  icon: Icons.shopping_bag_outlined,
                  title: MarketplaceStrings.t('mp_listing_not_found', locale),
                  description: '',
                ),
              ),
            ),
          );
        }

        final user = ref.watch(currentUserProvider);
        final isOwner =
            user != null && isListingOwnedByCurrentUser(listing.ownerUserId);
        final bottomInset = marketplaceDetailActionBarScrollInset(context);

        return HubSubscreenScaffold(
          title: listing.title,
          subtitle: _headerSubtitle(listing, locale),
          onBack: () => Navigator.of(context).pop(),
          headerTrailing: !isOwner
              ? TextButton(
                  onPressed: () async {
                    await ReportService().submitReport(
                      type: AdminReportType.listing,
                      title: 'Marketplace report: ${listing.title}',
                      description:
                          'User reported marketplace listing "${listing.title}" (${listing.id})',
                      targetId: listing.id,
                      targetType: 'marketplace_listing',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            MarketplaceStrings.t('mp_report_submitted', locale),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    MarketplaceStrings.t('mp_report_listing', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                )
              : null,
          bottomNavigationBar: _buildActionBar(
            context,
            locale,
            listing,
            offersEnabled: offersEnabled,
          ),
          body: _DetailBody(
            listing: listing,
            locale: locale,
            isOwner: isOwner,
            bottomInset: bottomInset,
            offersEnabled: offersEnabled,
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({
    required this.listing,
    required this.locale,
    required this.isOwner,
    required this.bottomInset,
    required this.offersEnabled,
  });

  final MarketplaceListing listing;
  final String locale;
  final bool isOwner;
  final double bottomInset;
  final bool offersEnabled;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PostEngine().analytics.trackView(
        listingId: widget.listing.id,
        verticalId: 'marketplace',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final locale = widget.locale;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        widget.bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClassifiedsHostNotice(locale: locale),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: HubNoticeBanner(
              text: MarketplaceStrings.t('mp_detail_trust_banner', locale),
            ),
          ),
          if (listing.photoUrls.isNotEmpty)
            GlassCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: listing.photoUrls.first,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Center(
                      child: Text(
                        listing.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            GlassCard(
              child: Center(
                child: Text(
                  listing.emoji,
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            listing.price,
            style: AppTypography.title.copyWith(
              color: AppColors.brandFamilyMain,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            listing.title,
            style: AppTypography.headline2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            MarketplaceStrings.format(
              'mp_detail_area_line',
              locale,
              params: {'area': listing.area},
            ),
            style: AppTypography.body,
          ),
          Text(listing.posted, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${PostEngineStrings.t('field_condition', locale)}: '
            '${MarketplaceStrings.conditionLabel(listing.condition, locale)}',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusBadge(
                label: MarketplaceStrings.t('mp_trust_price_check', locale),
                color: AppColors.info,
              ),
              StatusBadge(
                label: MarketplaceStrings.t('mp_trust_meet_public', locale),
                color: AppColors.tealGlow,
              ),
            ],
          ),
          if (listing.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              PostEngineStrings.t('field_description', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            UserGeneratedTextWithLinkSafety(
              text: listing.description,
              locale: locale,
              surface: LinkSafetySurface.marketplaceListing,
              style: AppTypography.body.copyWith(height: 1.5),
              onReportPost: widget.isOwner
                  ? null
                  : () async {
                      await ReportService().submitReport(
                        type: AdminReportType.listing,
                        title: 'Marketplace report: ${listing.title}',
                        description:
                            'User reported marketplace listing "${listing.title}" (${listing.id})',
                        targetId: listing.id,
                        targetType: 'marketplace_listing',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              MarketplaceStrings.t(
                                'mp_report_submitted',
                                locale,
                              ),
                            ),
                          ),
                        );
                      }
                    },
            ),
          ],
          if (listing.hasSchemaAttributes) ...[
            const SizedBox(height: AppSpacing.lg),
            VehicleListingAttributesSection(
              schemaFields: listing.schemaFields,
              locale: locale,
              sectionTitle: PostEngineStrings.t(
                'section_vehicle_specifications',
                locale,
              ),
            ),
          ],
          if (MarketplaceVehicleListingTrustCard.isVehicleListing(listing)) ...[
            const SizedBox(height: AppSpacing.lg),
            MarketplaceVehicleListingTrustCard(
              listing: listing,
              locale: locale,
            ),
          ],
          if (widget.isOwner) ...[
            const SizedBox(height: AppSpacing.lg),
            MarketplaceSellerPaymentProtectionCard(locale: locale),
          ],
          MarketplaceListingOffersSection(
            listing: listing,
            locale: locale,
            isOwner: widget.isOwner,
            offersEnabled: widget.offersEnabled,
          ),
        ],
      ),
    );
  }
}
