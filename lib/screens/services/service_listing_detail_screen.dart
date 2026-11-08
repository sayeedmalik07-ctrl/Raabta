import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_schema_listing_display.dart';
import 'package:raabta/models/admin_report_model.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/report_service.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/screens/services/utils/service_listing_display_helpers.dart';
import 'package:raabta/screens/services/presentation/widgets/service_request_quotes_section.dart';
import 'package:raabta/screens/services/widgets/service_hub_detail_section.dart';
import 'package:raabta/screens/services/widgets/service_hub_listing_card.dart';
import 'package:raabta/screens/services/widgets/service_hub_subscreen_scaffold.dart';
import 'package:raabta/screens/services/widgets/service_listing_detail_action_bar.dart';
import 'package:raabta/screens/services/widgets/service_provider_profile_section.dart';
import 'package:raabta/screens/services/widgets/service_sponsorship_awareness_section.dart';
import 'package:share_plus/share_plus.dart';

class ServiceListingDetailScreen extends ConsumerStatefulWidget {
  const ServiceListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<ServiceListingDetailScreen> createState() =>
      _ServiceListingDetailScreenState();
}

class _ServiceListingDetailScreenState
    extends ConsumerState<ServiceListingDetailScreen> {
  bool _isSaved = false;

  void _toggleSave(String listingId) {
    unawaited(
      ref.read(userAIProfileProvider.notifier).trackSave('services', listingId),
    );
    PostEngine().analytics.trackSave(
      listingId: listingId,
      verticalId: 'services',
    );
    setState(() => _isSaved = !_isSaved);
  }

  void _shareListing(String locale, ServiceListing listing) {
    Share.share(
      ServicesStrings.format(
        'detail_share_message',
        locale,
        params: {'title': listing.displayTitle},
      ),
    );
  }

  Future<void> _reportListing(
    BuildContext context,
    String locale, {
    required String listingId,
    required String title,
  }) async {
    await ReportService().submitReport(
      type: AdminReportType.listing,
      title: 'Service report: $title',
      description: 'User reported service listing "$title" ($listingId)',
      targetId: listingId,
      targetType: 'service_listing',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ServicesStrings.t('report_submitted', locale)),
        ),
      );
    }
  }

  String _headerSubtitle(String locale, ServiceListing? listing) {
    if (listing == null) {
      return ServicesStrings.t('subtitle', locale);
    }
    return serviceHubServiceTypeLine(listing);
  }

  Widget? _buildActionBar(String locale, ServiceListing? listing) {
    if (listing == null) return null;
    final uid = ref.watch(currentUserProvider)?.uid;
    final isCustomerOwner =
        listing.isRequest && uid != null && uid == listing.userId;
    final isProviderViewer =
        listing.isRequest && uid != null && uid != listing.userId;
    return ServiceListingDetailActionBar(
      listing: listing,
      locale: locale,
      isSaved: _isSaved,
      isCustomerOwner: isCustomerOwner,
      isProviderViewer: isProviderViewer,
      onSave: () => _toggleSave(listing.id),
      onShare: () => _shareListing(locale, listing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final listingAsync = ref.watch(serviceListingDetailProvider(widget.listingId));
    final bottomInset = serviceDetailActionBarScrollInset(context);
    final listing = listingAsync.valueOrNull;

    return ServiceHubSubscreenScaffold(
      title: ServicesStrings.t('listing_detail', locale),
      subtitle: _headerSubtitle(locale, listing),
      onBack: () => Navigator.of(context).pop(),
      bottomNavigationBar: _buildActionBar(locale, listing),
      body: listingAsync.when(
        loading: () => Center(
          child: HubLoadingPlaceholder(
            width: MediaQuery.sizeOf(context).width - AppSpacing.xl * 2,
            height: 280,
            silhouette: HubLoadingSilhouette.formTool,
          ),
        ),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.error_outline,
              title: ServicesStrings.t('hub_load_error_title', locale),
              description: ServicesStrings.t('submit_error', locale),
              actionLabel: CommonActionStrings.t('action_retry', locale),
              onAction: () =>
                  ref.invalidate(serviceListingDetailProvider(widget.listingId)),
            ),
          ),
        ),
        data: (listing) {
          if (listing == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: GlassEmptyState(
                  accent: GlassEmptyStateAccent.brand,
                  icon: Icons.search_off_rounded,
                  title: ServicesStrings.t('no_results', locale),
                  description: ServicesStrings.t('listings_empty_body', locale),
                ),
              ),
            );
          }

          final uid = ref.watch(currentUserProvider)?.uid;
          final isCustomerOwner =
              listing.isRequest && uid != null && uid == listing.userId;
          final isProviderViewer = listing.isRequest &&
              uid != null &&
              uid != listing.userId;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              bottomInset + AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HubNoticeBanner.hostNotice(locale: locale),
                const SizedBox(height: AppSpacing.md),
                if (listing.imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: listing.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                AbsorbPointer(
                  child: ServiceHubListingCard(
                    listing: listing,
                    locale: locale,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ServiceDetailMetaStrip(
                  listing: listing,
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.lg),
                ServiceHubDetailSection(
                  title: ServicesStrings.t('field_description', locale),
                  child: UserGeneratedTextWithLinkSafety(
                    text: listing.description,
                    locale: locale,
                    surface: LinkSafetySurface.servicesListing,
                    onReportPost: () => _reportListing(
                      context,
                      locale,
                      listingId: listing.id,
                      title: listing.displayTitle,
                    ),
                  ),
                ),
                if (listing.hasSchemaAttributes) ...[
                  const SizedBox(height: AppSpacing.lg),
                  ServiceHubDetailSection(
                    title: PostEngineStrings.t(
                      'section_service_details',
                      locale,
                    ),
                    padding: EdgeInsets.zero,
                    child: ServiceListingAttributesSection(
                      schemaFields: listing.schemaFields,
                      locale: locale,
                      sectionTitle: null,
                    ),
                  ),
                ],
                ServiceProviderProfileSection(
                  listing: listing,
                  locale: locale,
                ),
                if (!listing.isRequest) ...[
                  const SizedBox(height: AppSpacing.lg),
                  ServiceSponsorshipAwarenessSection(locale: locale),
                ],
                if (listing.isRequest && (isCustomerOwner || isProviderViewer))
                  ServiceRequestQuotesSection(
                    listing: listing,
                    locale: locale,
                    isCustomerOwner: isCustomerOwner,
                    isProviderViewer: isProviderViewer,
                  ),
                const SizedBox(height: AppSpacing.lg),
                HubFeedFooterNotice(locale: locale),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => _reportListing(
                    context,
                    locale,
                    listingId: listing.id,
                    title: listing.displayTitle,
                  ),
                  child: Text(
                    ServicesStrings.t('report_listing', locale),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ServiceDetailMetaStrip extends StatelessWidget {
  const _ServiceDetailMetaStrip({
    required this.listing,
    required this.locale,
  });

  final ServiceListing listing;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (!listing.isRequest) {
      items.add(
        _MetaChip(
          icon: Icons.schedule_outlined,
          label: serviceHubPostedLine(listing.createdAt, locale),
        ),
      );
      final offer = serviceHubProviderOfferLine(listing);
      if (offer != null) {
        items.add(
          _MetaChip(
            icon: Icons.work_outline,
            label: offer,
          ),
        );
      }
    }

    if (!listing.isRequest && listing.area.trim().isNotEmpty) {
      items.add(
        _MetaChip(
          icon: Icons.location_on_outlined,
          label: listing.area.trim(),
        ),
      );
    }

    if (listing.isRequest) {
      items.add(
        _MetaChip(
          icon: Icons.person_outline,
          label:
              '${ServicesStrings.t('posted_by_customer', locale)} ${listing.providerName}',
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: items,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
