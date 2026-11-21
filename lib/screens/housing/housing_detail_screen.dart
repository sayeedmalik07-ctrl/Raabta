import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/classifieds_host_notice.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/area_map_preview.dart';
import 'package:raabta/screens/housing/housing_screen.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/widgets/ai/housing_match_widget.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_schema_listing_display.dart';
import 'package:raabta/features/housing/domain/housing_in_app_message_eligibility.dart';
import 'package:raabta/features/housing/domain/housing_viewing_request.dart';
import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/features/housing/presentation/widgets/housing_listing_viewings_section.dart';
import 'package:raabta/features/housing/providers/housing_viewing_providers.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';
import 'package:raabta/screens/housing/widgets/housing_listing_trust_card.dart';
import 'package:raabta/services/qr/listing_ownership.dart';
import 'package:raabta/widgets/housing/scam_safety_badge.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const double _kDetailActionBarPillHeight = 46;
const double _kDetailActionBarVerticalPadding = 10;
const double _kDetailActionBarControlSize = 46;
const double _kDetailActionBarPillRadius = 23;

enum HousingDetailStickyPrimary { requestViewing, message }

/// Mirrors [HousingListingViewingsSection] request-button eligibility.
bool housingDetailStickyRequestViewingEligible({
  required bool viewingsEnabled,
  required bool isOwner,
  required HousingListing listing,
  required String? viewerUid,
  required List<HousingViewingRequest> viewingRequests,
}) {
  if (!viewingsEnabled || isOwner) return false;
  final ownerId = listing.ownerUserId;
  if (ownerId == null || ownerId.isEmpty) return false;

  final uid = viewerUid;
  if (uid == null) return true;

  final mine =
      viewingRequests.where((request) => request.viewerId == uid).toList();
  if (mine.isEmpty) return true;

  final active = mine.firstWhere(
    (request) => request.status.isOpen,
    orElse: () => mine.first,
  );
  return !active.status.isOpen;
}

HousingDetailStickyPrimary? resolveHousingDetailStickyPrimary({
  required bool viewingsEnabled,
  required bool isOwner,
  required HousingListing listing,
  required String? viewerUid,
  required List<HousingViewingRequest> viewingRequests,
}) {
  if (housingDetailStickyRequestViewingEligible(
    viewingsEnabled: viewingsEnabled,
    isOwner: isOwner,
    listing: listing,
    viewerUid: viewerUid,
    viewingRequests: viewingRequests,
  )) {
    return HousingDetailStickyPrimary.requestViewing;
  }
  if (housingInAppMessageEnabled(
    viewingsEnabled: viewingsEnabled,
    isOwner: isOwner,
    viewerUid: viewerUid,
    viewingRequests: viewingRequests,
  )) {
    return HousingDetailStickyPrimary.message;
  }
  return null;
}

/// When the sticky bar shows Request viewing, hide scroll duplicate only.
bool housingDetailShowViewingsSectionInScroll({
  required bool viewingsEnabled,
  required bool isOwner,
  required String? viewerUid,
  required List<HousingViewingRequest> viewingRequests,
  required bool stickyShowsRequestViewing,
}) {
  if (isOwner) return true;
  if (!viewingsEnabled) return viewingRequests.isNotEmpty;

  final uid = viewerUid;
  if (uid != null) {
    final mine =
        viewingRequests.where((request) => request.viewerId == uid).toList();
    if (mine.isNotEmpty) {
      final active = mine.firstWhere(
        (request) => request.status.isOpen,
        orElse: () => mine.first,
      );
      if (active.status.isOpen) return true;
    }
  }

  if (stickyShowsRequestViewing) return false;
  return true;
}

double housingDetailActionBarScrollClearance(BuildContext context) {
  return _kDetailActionBarVerticalPadding * 2 +
      _kDetailActionBarPillHeight +
      MediaQuery.paddingOf(context).bottom +
      AppSpacing.md;
}

class HousingDetailScreen extends ConsumerWidget {
  const HousingDetailScreen({
    super.key,
    required this.listingId,
    this.initialListing,
  });

  final String listingId;
  final HousingListing? initialListing;

  Future<void> _openWhatsApp(HousingListing listing) async {
    PostEngine().analytics.trackEnquiry(
      listingId: listing.id,
      verticalId: 'housing',
    );
    final message = Uri.encodeComponent(
      'Hi ${listing.contactName}, I saw your listing "${listing.title}" on Raabta. Is it still available?',
    );
    final uri = Uri.parse('https://wa.me/${listing.whatsapp}?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call(HousingListing listing) async {
    PostEngine().analytics.trackEnquiry(
      listingId: listing.id,
      verticalId: 'housing',
    );
    final uri = Uri.parse('tel:${listing.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _share(HousingListing listing) async {
    await Share.share(
      'Check out this listing on Raabta: ${listing.title} in ${listing.area} — ${listing.priceLabel}\n${listing.shareLink}',
    );
  }

  Future<void> _showReportForm(
    BuildContext context,
    WidgetRef ref, {
    required String listingId,
    String? listingTitle,
  }) async {
    final locale = ref.read(userLanguageProvider);
    final reasonController = TextEditingController();
    final detailsController = TextEditingController();
    final contactController = TextEditingController();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HousingStrings.t('report_listing', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.md),
                _reportField(
                  reasonController,
                  HousingStrings.t('report_reason_hint', locale),
                ),
                const SizedBox(height: AppSpacing.md),
                _reportField(
                  detailsController,
                  HousingStrings.t('report_details_hint', locale),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                _reportField(
                  contactController,
                  HousingStrings.t('report_contact_hint', locale),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  onTap: () => Navigator.pop(ctx, true),
                  glowColor: AppColors.error,
                  glowIntensity: 0.25,
                  backgroundColor: AppColors.error,
                  borderRadius: AppSpacing.radiusSm,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    HousingStrings.t('submit_report', locale),
                    style: AppTypography.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (submitted != true || !context.mounted) return;

    try {
      await ref.read(housingRepositoryProvider).reportListing(
            listingId,
            ListingReport(
              reason: reasonController.text.trim().isEmpty
                  ? 'Suspicious listing'
                  : reasonController.text.trim(),
              details: detailsController.text.trim(),
              reporterContact: contactController.text.trim(),
            ),
            listingTitle: listingTitle,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(HousingStrings.t('report_submitted', locale)),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(HousingStrings.t('report_saved_offline', locale)),
        ),
      );
    }
  }

  static Widget _reportField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusSm,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedShell(
    BuildContext context,
    WidgetRef ref,
    HousingListing listing,
  ) {
    return GlassScreenScaffold(
      safeArea: false,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: HousingDetailActionBar(
        listing: listing,
        onShare: () => _share(listing),
      ),
      body: _DetailBody(
        listing: listing,
        onWhatsApp: () => _openWhatsApp(listing),
        onCall: () => _call(listing),
        onShare: () => _share(listing),
        onReport: () => _showReportForm(
          context,
          ref,
          listingId: listing.id,
          listingTitle: listing.title,
        ),
        ref: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    if (initialListing != null) {
      return _buildLoadedShell(context, ref, initialListing!);
    }

    final listingAsync = ref.watch(housingListingDetailProvider(listingId));

    return listingAsync.when(
      loading: () => GlassScreenScaffold(
        safeArea: false,
        extendBodyBehindAppBar: true,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.cyanGlow),
        ),
      ),
      error: (error, _) => GlassScreenScaffold(
        safeArea: false,
        extendBodyBehindAppBar: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: GlassErrorState(
              message: error.toString(),
              onRetry: () =>
                  ref.invalidate(housingListingDetailProvider(listingId)),
            ),
          ),
        ),
      ),
      data: (listing) {
        if (listing == null) {
          return GlassScreenScaffold(
            safeArea: false,
            extendBodyBehindAppBar: true,
            body: Center(
              child: GlassEmptyState(
                icon: Icons.home_work_outlined,
                title: HousingStrings.t('listing_not_found', locale),
                description: HousingStrings.t('listing_not_found_body', locale),
              ),
            ),
          );
        }

        return _buildLoadedShell(context, ref, listing);
      },
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({
    required this.listing,
    required this.onWhatsApp,
    required this.onCall,
    required this.onShare,
    required this.onReport,
    required this.ref,
  });

  final HousingListing listing;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback onShare;
  final VoidCallback onReport;
  final WidgetRef ref;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  bool _scamModalShown = false;

  static const Color _whatsappGreen = Color(0xFF25D366);

  ScamVerdict get _effectiveVerdict {
    if (widget.listing.scamVerdict != null) return widget.listing.scamVerdict!;
    if (widget.listing.scamFlagged) return ScamVerdict.likelyScam;
    return ScamVerdict.safe;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        widget.ref.read(userAIProfileProvider.notifier).trackHousingView(
              widget.listing.id,
              housingListingToMatchData(widget.listing),
            ),
      );
      PostEngine().analytics.trackView(
        listingId: widget.listing.id,
        verticalId: 'housing',
      );
    });
    if (_effectiveVerdict == ScamVerdict.likelyScam) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _scamModalShown) return;
        _scamModalShown = true;
        ScamWarningModal.show(context, widget.listing);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.ref.watch(userLanguageProvider);
    final listing = widget.listing;
    final ref = widget.ref;
    final user = ref.watch(currentUserProvider);
    final isOwner =
        user != null && isListingOwnedByCurrentUser(listing.ownerUserId);
    final viewingsEnabled = ref.watch(complianceFlagsProvider).viewingsEnabled;
    final viewingRequests = ref
            .watch(housingListingViewingsProvider(listing.id))
            .valueOrNull ??
        const [];
    final stickyPrimary = resolveHousingDetailStickyPrimary(
      viewingsEnabled: viewingsEnabled,
      isOwner: isOwner,
      listing: listing,
      viewerUid: user?.uid,
      viewingRequests: viewingRequests,
    );
    final stickyShowsRequestViewing =
        stickyPrimary == HousingDetailStickyPrimary.requestViewing;
    final showViewingsInScroll = housingDetailShowViewingsSectionInScroll(
      viewingsEnabled: viewingsEnabled,
      isOwner: isOwner,
      viewerUid: user?.uid,
      viewingRequests: viewingRequests,
      stickyShowsRequestViewing: stickyShowsRequestViewing,
    );
    final scrollBottomClearance = housingDetailActionBarScrollClearance(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: GlassIconButton(
              icon: Icons.arrow_back_ios_rounded,
              tooltip: CommonActionStrings.t('action_back', locale),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: listing.photoUrls.isEmpty
                ? GlassContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: 0,
                    child: const SizedBox.expand(),
                  )
                : PageView.builder(
                    itemCount: listing.photoUrls.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: listing.photoUrls[index],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            GlassContainer(
                              padding: EdgeInsets.zero,
                              borderRadius: 0,
                              child: const SizedBox.expand(),
                            ),
                      );
                    },
                  ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ClassifiedsHostNotice(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (listing.verified)
                    _StatusBadge(
                      label: HousingStrings.t('status_verified', locale),
                      color: AppColors.success,
                      icon: '✓',
                    ),
                  ScamSafetyBadge(
                    listing: listing,
                    locale: locale,
                    showFlags: listing.scamVerdict == ScamVerdict.suspicious ||
                        listing.scamVerdict == ScamVerdict.likelyScam,
                  ),
                  if (listing.status == ListingStatus.pending)
                    _StatusBadge(
                      label: HousingStrings.t('status_pending', locale),
                      color: AppColors.warning,
                      icon: '⏳',
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(listing.title, style: AppTypography.headline2.copyWith(fontSize: 22)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '📍 ${listing.area} · ${HousingStrings.postedLabel(listing.daysAgo, locale)} · ${listing.posterNationalityFlag}',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                listing.priceLabel,
                style: AppTypography.title.copyWith(
                  color: AppColors.cyanGlow,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              HousingMatchWidget(
                listingData: housingListingToMatchData(listing),
                compact: false,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _Tag(
                    label: HousingStrings.furnishedLabel(listing.furnished, locale),
                  ),
                  _Tag(
                    label: HousingStrings.format(
                      'tag_bed',
                      locale,
                      params: {'count': '${listing.bedrooms}'},
                    ),
                  ),
                  _Tag(
                    label: HousingStrings.format(
                      'tag_bath',
                      locale,
                      params: {'count': '${listing.bathrooms}'},
                    ),
                  ),
                  _Tag(
                    label: HousingStrings.listingTypeLabel(listing.type, locale),
                  ),
                  _Tag(
                    label: HousingStrings.genderLabel(
                      listing.genderPreference,
                      locale,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                HousingStrings.t('label_description', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              UserGeneratedTextWithLinkSafety(
                text: listing.description,
                locale: locale,
                surface: LinkSafetySurface.housingListing,
                style: AppTypography.body.copyWith(height: 1.5),
                onReportPost: widget.onReport,
              ),
              if (listing.hasExtendedAttributes) ...[
                const SizedBox(height: AppSpacing.lg),
                HousingListingAttributesSection(
                  schemaFields: listing.schemaFields,
                  locale: locale,
                  zone: listing.zone,
                  streetNumber: listing.streetNumber,
                  buildingNumber: listing.buildingNumber,
                  sectionTitle: PostEngineStrings.t(
                    'section_housing_extended_details',
                    locale,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                HousingStrings.t('label_amenities', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: listing.amenities
                    .map(
                      (a) => GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        borderRadius: AppSpacing.radiusFull,
                        child: Text(a, style: AppTypography.caption),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                HousingStrings.t('label_area_map', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                padding: EdgeInsets.zero,
                child: AreaMapPreview(
                  area: listing.area,
                  latitude: listing.latitude,
                  longitude: listing.longitude,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              HousingListingTrustCard(
                listing: listing,
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (stickyShowsRequestViewing) ...[
                ForewarningSlot(
                  momentId: ForewarningMomentId.housingDepositViewing,
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (showViewingsInScroll)
                HousingListingViewingsSection(
                  listing: listing,
                  locale: locale,
                  isOwner: isOwner,
                ),
              GlassCard(
                onTap: widget.onWhatsApp,
                glowColor: _whatsappGreen,
                glowIntensity: 0.2,
                backgroundColor: _whatsappGreen,
                borderRadius: AppSpacing.radiusSm,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat, color: Colors.white, size: AppSpacing.iconMd),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      CommonActionStrings.t('action_whatsapp', locale),
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                onTap: widget.onCall,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                borderRadius: AppSpacing.radiusSm,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: AppColors.textPrimary, size: AppSpacing.iconMd),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      CommonActionStrings.t('action_call', locale),
                      style: AppTypography.button,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                onTap: widget.onReport,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                borderRadius: AppSpacing.radiusSm,
                glowColor: AppColors.error,
                glowIntensity: 0.12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flag_outlined, color: AppColors.error, size: AppSpacing.iconMd),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      HousingStrings.t('report_listing', locale),
                      style: AppTypography.link.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scrollBottomClearance),
            ]),
          ),
        ),
      ],
    );
  }
}

class HousingDetailActionBar extends ConsumerWidget {
  const HousingDetailActionBar({
    required this.listing,
    required this.onShare,
  });

  final HousingListing listing;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final isOwner =
        user != null && isListingOwnedByCurrentUser(listing.ownerUserId);
    final savedIds = ref.watch(savedListingIdsProvider);
    final isSaved = savedIds.contains(listing.id);
    final viewingsEnabled = ref.watch(complianceFlagsProvider).viewingsEnabled;
    final viewingRequests = ref
            .watch(housingListingViewingsProvider(listing.id))
            .valueOrNull ??
        const [];

    final primary = resolveHousingDetailStickyPrimary(
      viewingsEnabled: viewingsEnabled,
      isOwner: isOwner,
      listing: listing,
      viewerUid: user?.uid,
      viewingRequests: viewingRequests,
    );

    final saveLabel = isSaved
        ? CommonActionStrings.t('action_unsave', locale)
        : CommonActionStrings.t('action_save', locale);
    final shareLabel = HousingStrings.t('action_share_tooltip', locale);

    return SafeArea(
      key: const Key('housing_detail_action_bar'),
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          _kDetailActionBarVerticalPadding,
          AppSpacing.lg,
          _kDetailActionBarVerticalPadding,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.sm),
          borderRadius: AppSpacing.radiusMd,
          child: Row(
            children: [
              if (primary == null) const Spacer(),
              if (primary != null)
                Expanded(
                  child: _DetailPrimaryPill(
                    key: Key('housing_detail_action_bar_primary_${primary.name}'),
                    label: primary == HousingDetailStickyPrimary.requestViewing
                        ? HousingViewingStrings.t('hv_request_viewing', locale)
                        : HousingStrings.t('action_message', locale),
                    onTap: () {
                      if (primary == HousingDetailStickyPrimary.requestViewing) {
                        context.push(
                          '/housing/listing/${listing.id}/viewing',
                          extra: {
                            'ownerId': listing.ownerUserId!,
                            'title': listing.title,
                          },
                        );
                        return;
                      }
                      context.push(
                        '/housing/chat/${listing.id}',
                        extra: {'title': listing.title},
                      );
                    },
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              _DetailCircleAction(
                key: const Key('housing_detail_action_bar_save'),
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                tooltip: saveLabel,
                semanticsLabel: saveLabel,
                onTap: () =>
                    ref.read(savedListingIdsProvider.notifier).toggle(listing.id),
              ),
              const SizedBox(width: AppSpacing.sm),
              _DetailCircleAction(
                key: const Key('housing_detail_action_bar_share'),
                icon: Icons.share_outlined,
                tooltip: shareLabel,
                semanticsLabel: shareLabel,
                onTap: onShare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailPrimaryPill extends StatelessWidget {
  const _DetailPrimaryPill({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_kDetailActionBarPillRadius),
          child: Ink(
            height: _kDetailActionBarPillHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_kDetailActionBarPillRadius),
              gradient: LinearGradient(
                colors: [
                  AppColors.brandFamilyMain,
                  AppColors.brandFamilyLightDeep,
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCircleAction extends StatelessWidget {
  const _DetailCircleAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: _kDetailActionBarControlSize,
          height: _kDetailActionBarControlSize,
          child: Material(
            color: AppColors.isLight
                ? AppColors.surface
                : AppColors.glassSurface,
            shape: CircleBorder(
              side: BorderSide(color: AppColors.glassBorder),
            ),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Icon(
                icon,
                size: AppSpacing.iconMd,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppSpacing.radiusSm,
      glowColor: color,
      glowIntensity: 0.12,
      child: Text(
        '$icon $label',
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppSpacing.radiusXs,
      child: Text(label, style: AppTypography.caption),
    );
  }
}
