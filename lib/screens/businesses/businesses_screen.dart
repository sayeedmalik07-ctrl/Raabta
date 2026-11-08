import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/constants/strings/business_strings.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/classifieds_host_notice.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/data/categories/business_categories.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/core/widgets/qr_share_sheet.dart';
import 'package:raabta/services/qr/listing_deep_links.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/features/business/domain/business_structured_contact_eligibility.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';
import 'package:raabta/models/admin_report_model.dart';
import 'package:raabta/services/ai/business_recommendation_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/report_service.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/presentation/widgets/save_search_button.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';
import 'package:raabta/screens/businesses/widgets/business_listing_trust_section.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/screens/monetization/business_advertise_screen.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/presentation/widgets/business_structured_owner_panel.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/core/widgets/hub/hub_advanced_filter_toggle.dart';
import 'package:raabta/core/widgets/hub/hub_business_card.dart';
import 'package:raabta/core/widgets/hub/hub_zero_result_recovery_strip.dart';
import 'package:raabta/screens/businesses/widgets/business_hub_picker_sheets.dart';
import 'package:raabta/screens/businesses/widgets/business_listing_detail_sheet_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_quick_action_tile.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/core/widgets/hub/hub_summary_strip_card.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/screens/businesses/business_hub_completeness.dart';

class BusinessesScreen extends ConsumerStatefulWidget {
  const BusinessesScreen({
    super.key,
    this.initialTagFilter,
    this.routeParameters,
    this.initialListingId,
  });

  /// When set (e.g. `ramadan_iftar`), opens with that tag filter active.
  final String? initialTagFilter;

  /// S4 structured search route parameters.
  final SearchRouteParameters? routeParameters;

  /// Deep link: `/businesses?listingId=...` opens this listing's detail sheet.
  final String? initialListingId;

  @override
  ConsumerState<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends ConsumerState<BusinessesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategory = 0;
  String? _areaFilter;
  bool _openNowOnly = false;
  bool _handledInitialListingDeepLink = false;
  String? _areaFilterBeforeRelax;
  bool _showAreaRelaxRecovery = false;

  List<BusinessListing> _filteredBusinesses(List<BusinessListing> catalog) {
    var businesses = _applyFilters(catalog);
    final profile = ref.read(userAIProfileProvider);
    if (profile != null) {
      businesses = List<BusinessListing>.from(businesses)
        ..sort((a, b) => _recommendationScore(b).compareTo(_recommendationScore(a)));
    }
    return businesses;
  }

  int _recommendationScore(BusinessListing business) {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null) return 0;
    return ref
        .read(businessRecommendationServiceProvider)
        .scoreBusiness(businessListingToMatchData(business), profile)
        .round();
  }

  void _toggleSave(String businessId) {
    unawaited(ref.read(userAIProfileProvider.notifier).trackSave('business', businessId));
    PostEngine().analytics.trackSave(
      listingId: businessId,
      verticalId: 'business',
    );
    setState(() {});
  }

  bool get _isIftarFilter =>
      kBusinessCategories[_selectedCategory].filter == 'ramadan_iftar';

  bool get _browseFiltersActive =>
      _searchController.text.trim().isNotEmpty ||
      _selectedCategory != 0 ||
      (_areaFilter?.trim().isNotEmpty ?? false) ||
      _openNowOnly;

  @override
  void initState() {
    super.initState();
    if (widget.initialTagFilter == 'ramadan_iftar') {
      final index = kBusinessCategories.indexWhere(
        (c) => c.filter == 'ramadan_iftar',
      );
      if (index >= 0) _selectedCategory = index;
    }

    final params = widget.routeParameters;
    if (params != null && !params.isEmpty) {
      if (params.businessQuery != null &&
          params.businessQuery!.trim().isNotEmpty) {
        _searchController.text = params.businessQuery!.trim();
      }
      if (params.area != null && params.area!.trim().isNotEmpty) {
        _areaFilter = params.area!.trim();
      }
    }
  }

  void _maybeOpenInitialListingDeepLink(List<BusinessListing> catalog) {
    if (_handledInitialListingDeepLink) return;
    final listingId = widget.initialListingId?.trim();
    if (listingId == null || listingId.isEmpty) return;

    BusinessListing? match;
    for (final business in catalog) {
      if (business.id == listingId) {
        match = business;
        break;
      }
    }
    if (match == null) return;

    _handledInitialListingDeepLink = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showBusinessDetail(match!);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusBadgeColor(BusinessListing business) {
    switch (businessListingDisplayStatus(business)) {
      case BusinessListingDisplayStatus.pendingReview:
        return AppColors.warning;
      case BusinessListingDisplayStatus.listingApproved:
        return AppColors.success;
      case BusinessListingDisplayStatus.directoryListing:
        return AppColors.info;
    }
  }

  String _statusBadgeLabel(BusinessListing business, String locale) {
    switch (businessListingDisplayStatus(business)) {
      case BusinessListingDisplayStatus.pendingReview:
        return BusinessesStrings.t('badge_pending_review', locale);
      case BusinessListingDisplayStatus.listingApproved:
        return BusinessesStrings.t('badge_listing_approved', locale);
      case BusinessListingDisplayStatus.directoryListing:
        return BusinessesStrings.t('badge_directory_listing', locale);
    }
  }

  String _statusSubtitle(BusinessListing business, String locale) {
    switch (businessListingDisplayStatus(business)) {
      case BusinessListingDisplayStatus.pendingReview:
        return BusinessesStrings.t('level_subtitle_pending_review', locale);
      case BusinessListingDisplayStatus.listingApproved:
        return BusinessesStrings.t('level_subtitle_listing_approved', locale);
      case BusinessListingDisplayStatus.directoryListing:
        return BusinessesStrings.t('level_subtitle_directory_listing', locale);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<String> _listingReviews(BusinessListing business) {
    if (!business.hasDisplayLatestReview) return const [];
    return [business.latestReview!.trim()];
  }

  List<String> _listingInfoLines(BusinessListing business, String locale) {
    return [
      if (business.languages.isNotEmpty)
        BusinessesStrings.format(
          'info_languages_listed',
          locale,
          params: {'languages': business.languages.join(', ')},
        ),
      if (business.hasWhatsApp)
        BusinessesStrings.t('info_whatsapp_listed', locale),
      if (business.website != null && business.website!.trim().isNotEmpty)
        business.website!.trim(),
      if (business.servicesOffered.isNotEmpty)
        business.servicesOffered.join(' · '),
      if (business.yearsActive >= 2)
        BusinessesStrings.format(
          'info_years_active',
          locale,
          params: {'years': '${business.yearsActive}'},
        ),
      if (business.hasDisplayRating)
        BusinessesStrings.format(
          'info_rating_on_record',
          locale,
          params: {
            'rating': business.rating.toStringAsFixed(1),
            'count': '${business.reviewCount}',
          },
        ),
      BusinessesStrings.t('info_self_reported_notice', locale),
    ];
  }

  List<Widget> _buildFeedItems(
    List<BusinessListing> businesses,
    String locale,
  ) {
    final items = <Widget>[];
    for (var i = 0; i < businesses.length; i++) {
      items.add(_hubBusinessCard(businesses[i], locale));
      if (ComplianceFlagsGate.effectiveBusinessAds && (i + 1) % 5 == 0) {
        items.add(_AdPlaceholderCard(onPromote: _openBusinessAdvertise, locale: locale));
      }
    }
    return items;
  }

  Widget _hubBusinessCard(BusinessListing business, String locale) {
    return HubBusinessCard(
      key: Key('business_hub_card_${business.id}'),
      name: business.name,
      categoryLine: '${business.category} · ${business.location}',
      openNow: business.openNow,
      closingTime: business.closingTime,
      services: business.servicesOffered,
      logoUrl: business.logoUrl,
      logoInitial: business.name,
      onTap: () => _showBusinessDetail(business),
    );
  }

  void _openBusinessMessage(BusinessListing business) {
    if (business.hasWhatsApp) {
      _openUrl(
        'https://wa.me/${business.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}',
      );
      return;
    }
    _openUrl('tel:${business.phone}');
  }

  Future<void> _openBusinessFiltersSheet(String locale) async {
    await showBusinessFiltersSheet(
      context: context,
      locale: locale,
      selectedCategoryIndex: _selectedCategory,
      openNowOnly: _openNowOnly,
      areaFilter: _areaFilter,
      onClearAll: _clearBrowseFilters,
      onCategoryChanged: (index) => setState(() => _selectedCategory = index),
      onOpenNowChanged: (value) => setState(() => _openNowOnly = value),
      onAreaChanged: (area) => setState(() => _areaFilter = area),
    );
  }

  void _maybeAutoRelaxAreaFilter(
    List<BusinessListing> filtered,
    List<BusinessListing> catalog,
  ) {
    if (filtered.isNotEmpty) {
      if (_showAreaRelaxRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _showAreaRelaxRecovery = false;
            _areaFilterBeforeRelax = null;
          });
        });
      }
      return;
    }
    if (_areaFilter == null ||
        _areaFilterBeforeRelax != null ||
        catalog.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _areaFilterBeforeRelax = _areaFilter;
        _areaFilter = null;
        _showAreaRelaxRecovery = true;
      });
    });
  }

  void _undoAreaFilterRelax() {
    setState(() {
      _areaFilter = _areaFilterBeforeRelax;
      _areaFilterBeforeRelax = null;
      _showAreaRelaxRecovery = false;
    });
  }

  void _shareBusinessListing(BusinessListing business, String locale) {
    showQrShareSheet(
      context,
      title: BusinessesStrings.t('listing_qr_title', locale),
      subtitle: business.name,
      caption: BusinessesStrings.t('listing_qr_caption', locale),
      qrData: ListingDeepLinks.businessListing(business.id),
    );
  }

  void _showBusinessDetail(BusinessListing business) {
    final color = _statusBadgeColor(business);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final locale = ref.watch(userLanguageProvider);
                final complianceFlags = ref.watch(complianceFlagsProvider);
                final isSaved =
                    ref.watch(userAIProfileProvider)?.savedBusinessIds.contains(business.id) ??
                        false;
                final viewerUid = ref.watch(currentUserProvider)?.uid;
                final isOwner = viewerUid != null &&
                    business.ownerUserId != null &&
                    business.ownerUserId!.isNotEmpty &&
                    viewerUid == business.ownerUserId;
                final showStructuredCta = business.showsStructuredContactAction &&
                    !isOwner &&
                    businessStructuredContactCtaVisible(
                      contactMode: business.contactMode,
                      flags: complianceFlags,
                    );

                final detailBody = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClassifiedsHostNotice(locale: locale),
                  const SizedBox(height: 12),
                  if (business.coverUrl != null &&
                      business.coverUrl!.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        business.coverUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  if (business.coverUrl != null &&
                      business.coverUrl!.trim().isNotEmpty)
                    const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color.withValues(alpha: 0.15),
                        backgroundImage: business.logoUrl != null &&
                                business.logoUrl!.trim().isNotEmpty
                            ? NetworkImage(business.logoUrl!)
                            : null,
                        child: business.logoUrl != null &&
                                business.logoUrl!.trim().isNotEmpty
                            ? null
                            : Text(
                                business.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(business.name, style: AppTypography.headline2),
                            Text(business.category, style: AppTypography.body),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: _statusBadgeLabel(business, locale),
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (business.description != null)
                    UserGeneratedTextWithLinkSafety(
                      text: business.description!,
                      locale: locale,
                      surface: LinkSafetySurface.businessListing,
                      style: AppTypography.body.copyWith(height: 1.5),
                    ),
                  const SizedBox(height: 16),
                  _ListingInfoBox(
                    title: BusinessesStrings.t('listing_info_title', locale),
                    lines: _listingInfoLines(business, locale),
                    color: color,
                    statusSubtitle: _statusSubtitle(business, locale),
                  ),
                  const SizedBox(height: 20),
                  BusinessListingTrustSection(locale: locale),
                  if (_listingReviews(business).isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      BusinessesStrings.t('stored_review_note', locale),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 10),
                    ..._listingReviews(business).map(
                      (review) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(review, style: AppTypography.body),
                      ),
                    ),
                  ],
                  if (isOwner) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          showQrShareSheet(
                            context,
                            title: BusinessesStrings.t('listing_qr_title', locale),
                            subtitle: business.name,
                            caption: BusinessesStrings.t('listing_qr_caption', locale),
                            qrData: ListingDeepLinks.businessListing(business.id),
                          );
                        },
                        icon: const Icon(Icons.qr_code_2_outlined, size: 18),
                        label: Text(BusinessesStrings.t('get_qr_listing', locale)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentGold,
                          side: BorderSide(
                            color: AppColors.accentGold.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (isOwner) ...[
                    const SizedBox(height: 16),
                    BusinessStructuredOwnerPanel(
                      business: business,
                      locale: locale,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await ReportService().submitReport(
                            type: AdminReportType.business,
                            title: 'Business report: ${business.name}',
                            description:
                                'User reported business "${business.name}" (${business.category})',
                            targetId: business.id,
                            targetType: 'business',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  BusinessesStrings.format(
                                    'report_submitted',
                                    locale,
                                    params: {'name': business.name},
                                  ),
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  BusinessesStrings.t('report_failed', locale),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        BusinessesStrings.t('report_this_business', locale),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              );

                return BusinessListingDetailSheetScaffold(
                  scrollController: scrollController,
                  body: detailBody,
                  actionBar: BusinessListingDetailActionBar(
                    business: business,
                    locale: locale,
                    isSaved: isSaved,
                    isOwner: isOwner,
                    showStructuredCta: showStructuredCta,
                    onSave: () => _toggleSave(business.id),
                    onShare: () => _shareBusinessListing(business, locale),
                    onStructuredPrimary: () => _openStructuredContactAction(
                      context,
                      business,
                      locale,
                    ),
                    onMessage: () => _openBusinessMessage(business),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openStructuredContactAction(
    BuildContext context,
    BusinessListing business,
    String locale,
  ) async {
    if (ref.read(currentUserProvider) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(BusinessesStrings.t('sign_in_required_action', locale))),
      );
      context.push('/login');
      return;
    }

    final flags = ComplianceFlagsGate.current;
    final route = switch (business.contactMode) {
      BusinessContactMode.appointment =>
        flags.businessAppointmentsEnabled
            ? '/businesses/request-appointment/${business.id}?name=${Uri.encodeComponent(business.name)}'
            : null,
      BusinessContactMode.quote =>
        flags.businessQuotesEnabled
            ? '/businesses/request-quote/${business.id}?name=${Uri.encodeComponent(business.name)}'
            : null,
      BusinessContactMode.messageOnly => null,
    };
    if (route == null) return;
    await context.push(route);
  }

  List<BusinessListing> _applyFilters(List<BusinessListing> source) {
    var list = filterBusinesses(
      source: source,
      query: _searchController.text.trim().toLowerCase(),
      categoryFilter: kBusinessCategories[_selectedCategory].filter,
    );
    final area = _areaFilter?.trim();
    if (area != null && area.isNotEmpty) {
      list = list.where((b) => b.isInArea(area)).toList();
    }
    if (_openNowOnly) {
      list = list.where((b) => b.openNow).toList();
    }
    return list;
  }

  void _openBusinessAdvertise() {
    if (!ComplianceFlagsGate.effectiveBusinessAds) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const BusinessAdvertiseScreen(),
      ),
    );
  }

  void _showAddBusinessSheet() {
    context.push('/businesses/post');
  }

  void _clearBrowseFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 0;
      _areaFilter = null;
      _openNowOnly = false;
      _areaFilterBeforeRelax = null;
      _showAreaRelaxRecovery = false;
    });
  }

  void _applyNearMeFilter() {
    final area = ref.read(userAIProfileProvider)?.preferredArea.trim() ?? '';
    setState(() {
      _areaFilter = area.isEmpty ? null : area;
    });
  }

  Future<void> _pickCategory(String locale) async {
    final picked = await showBusinessCategoryPicker(
      context: context,
      locale: locale,
      selectedIndex: _selectedCategory,
    );
    if (picked != null) setState(() => _selectedCategory = picked);
  }

  Future<void> _pickArea(String locale) async {
    final picked = await showBusinessAreaPicker(
      context: context,
      locale: locale,
      selectedArea: _areaFilter,
    );
    if (picked == null) return;
    setState(() {
      _areaFilter = picked.isEmpty ? null : picked;
    });
  }

  Widget _buildHubLoadingBody(String locale) {
    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              ..._hubChromeSlivers(locale),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < 3 ? AppSpacing.md : 0,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return HubLoadingPlaceholder(
                              key: index == 0
                                  ? const Key('business_hub_loading_skeleton')
                                  : null,
                              width: constraints.maxWidth,
                              height: 120,
                              silhouette: HubLoadingSilhouette.businessCard,
                            );
                          },
                        ),
                      );
                    },
                    childCount: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _hubChromeSlivers(String locale) {
    return [
      SliverToBoxAdapter(child: _buildHubHeader(locale)),
      SliverToBoxAdapter(child: _buildHubSearchSection(locale)),
      SliverToBoxAdapter(child: _buildHubSummaryStrip(locale)),
      SliverToBoxAdapter(child: _buildHubQuickActionRow(locale)),
      SliverToBoxAdapter(child: _buildHubFilterChipRow(locale)),
    ];
  }

  Widget _buildHubHeader(String locale) {
    return HubLandingHeader(
      key: const Key('business_hub_landing_header'),
      title: BusinessesStrings.t('hub_title', locale),
      subtitle: BusinessesStrings.t('hub_subtitle', locale),
      onBack: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildHubSearchSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: HubLayoutTokens.searchMinHeight,
                  ),
                  child: TextField(
                    key: const Key('business_hub_search'),
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: AppTypography.subtitle,
                    textInputAction: TextInputAction.search,
                    decoration: hubSearchInputDecoration(
                      hintText: BusinessesStrings.t('search_hint', locale),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              HubAdvancedFilterToggle(
                key: const Key('business_hub_filter_toggle'),
                expanded: false,
                onToggle: () => unawaited(_openBusinessFiltersSheet(locale)),
                semanticsLabel:
                    BusinessesStrings.t('hub_filters_semantics', locale),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SaveSearchButton(
              vertical: SavedSearchVertical.business,
              accent: SaveSearchButtonAccent.hubBrand,
              criteria: SavedSearchCriteria.fromBusinessBrowse(
                query: _searchController.text,
                selectedCategoryIndex: _selectedCategory,
                areaFilter: _areaFilter,
                routeFilters: widget.routeParameters,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHubSummaryStrip(String locale) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final cards = <Widget>[];

    if (uid.isNotEmpty) {
      final owned = ref.watch(userOwnedBusinessesProvider).valueOrNull;
      if (owned != null && owned.isNotEmpty) {
        final primary = owned.first;
        final percent = businessListingCompletenessPercent(primary);
        cards.add(
          Expanded(
            child: HubSummaryStripCard(
              value: BusinessesStrings.format(
                'strip_profile_complete',
                locale,
                params: {'percent': '$percent'},
              ),
              label: BusinessesStrings.t('strip_my_business', locale),
              icon: Icons.storefront_outlined,
              onTap: () => _showBusinessDetail(primary),
            ),
          ),
        );
      }
    }

    final savedAsync =
        ref.watch(userSavedSearchesForVerticalProvider(SavedSearchVertical.business));
    final savedCount = savedAsync.maybeWhen(
      data: (searches) => searches.where((s) => s.active).length,
      orElse: () => null,
    );
    if (savedCount != null && savedCount > 0) {
      if (cards.isNotEmpty) cards.add(const SizedBox(width: AppSpacing.sm));
      cards.add(
        Expanded(
          child: HubSummaryStripCard(
            value: ProfileDisplayHelper.formatCount(savedCount),
            label: SavedSearchStrings.t('saved_searches_title', locale),
            icon: Icons.search,
            onTap: () => context.push('/profile/saved-searches'),
          ),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return HubSummaryStripPadding(child: Row(children: cards));
  }

  Widget _buildHubQuickActionRow(String locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.add,
              label: BusinessesStrings.t('add_business', locale),
              onTap: _showAddBusinessSheet,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.bookmark_border,
              label: BusinessesStrings.t('quick_saved', locale),
              onTap: () => context.push('/profile/saved-searches'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.schedule,
              label: BusinessesStrings.t('quick_open_now', locale),
              onTap: () => setState(() => _openNowOnly = !_openNowOnly),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.near_me_outlined,
              label: BusinessesStrings.t('quick_near_me', locale),
              onTap: _applyNearMeFilter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubFilterChipRow(String locale) {
    final categoryLabel = kBusinessCategories[_selectedCategory].label;
    final areaLabel = _areaFilter?.trim().isNotEmpty == true
        ? _areaFilter!
        : BusinessesStrings.t('filter_area', locale);
    final categoryChipLabel = _selectedCategory == 0
        ? BusinessesStrings.t('filter_category', locale)
        : categoryLabel;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SizedBox(
        height: HubLayoutTokens.filterChipHeight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          children: [
            buildHubFilterChip(
              label: Text(categoryChipLabel),
              selected: _selectedCategory != 0,
              onSelected: (_) => unawaited(_pickCategory(locale)),
            ),
            const SizedBox(width: AppSpacing.sm),
            KeyedSubtree(
              key: const Key('business_hub_filter_open_now'),
              child: buildHubFilterChip(
                label: Text(BusinessesStrings.t('filter_open_now', locale)),
                selected: _openNowOnly,
                onSelected: (value) => setState(() => _openNowOnly = value),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            buildHubFilterChip(
              label: Text(areaLabel),
              selected: _areaFilter?.trim().isNotEmpty == true,
              onSelected: (_) => unawaited(_pickArea(locale)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final catalogAsync = ref.watch(businessCatalogProvider);

    return catalogAsync.when(
      loading: () => _buildHubLoadingBody(locale),
      error: (e, _) => AnimatedAuroraBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: GlassEmptyState(
                  key: const Key('business_hub_error_state'),
                  icon: Icons.error_outline,
                  title: BusinessesStrings.t('hub_load_error_title', locale),
                  description: BusinessesStrings.format(
                    'load_error',
                    locale,
                    params: {'error': '$e'},
                  ),
                  actionLabel: CommonActionStrings.t('action_retry', locale),
                  onAction: () => ref.invalidate(businessCatalogProvider),
                ),
              ),
            ),
          ),
        ),
      ),
      data: (allBusinesses) =>
          _buildBusinessesContent(context, locale, allBusinesses),
    );
  }

  Widget _buildBusinessesContent(
    BuildContext context,
    String locale,
    List<BusinessListing> allBusinesses,
  ) {
    _maybeOpenInitialListingDeepLink(allBusinesses);
    var businesses = _filteredBusinesses(allBusinesses);
    _maybeAutoRelaxAreaFilter(businesses, allBusinesses);
    businesses = _filteredBusinesses(allBusinesses);
    final feedItems = _buildFeedItems(businesses, locale);
    final catalogEmpty = allBusinesses.isEmpty;
    final zeroFromFilters =
        businesses.isEmpty && (!catalogEmpty || _browseFiltersActive);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.brandFamilyMain,
            onRefresh: () async {
              ref.invalidate(businessCatalogProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                ..._hubChromeSlivers(locale),
                if (ComplianceFlagsGate.effectiveBusinessAds)
                  SliverToBoxAdapter(child: _buildAdsBanner()),
                if (_showAreaRelaxRecovery)
                  SliverToBoxAdapter(
                    child: HubZeroResultRecoveryStrip(
                      message: BusinessesStrings.t(
                        'hub_zero_result_recovery',
                        locale,
                      ),
                      undoLabel: BusinessesStrings.t(
                        'hub_zero_result_undo',
                        locale,
                      ),
                      onUndo: _undoAreaFilterRelax,
                    ),
                  ),
                if (businesses.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: GlassEmptyState(
                        key: Key(
                          zeroFromFilters
                              ? 'business_hub_zero_result_state'
                              : 'business_hub_empty_state',
                        ),
                        accent: GlassEmptyStateAccent.brand,
                        icon: Icons.storefront_outlined,
                        title: zeroFromFilters
                            ? BusinessesStrings.t(
                                'hub_empty_filtered_title',
                                locale,
                              )
                            : BusinessesStrings.t(
                                'hub_empty_catalog_title',
                                locale,
                              ),
                        description: zeroFromFilters
                            ? BusinessesStrings.t(
                                'hub_empty_filtered_description',
                                locale,
                              )
                            : BusinessesStrings.t(
                                'hub_empty_catalog_description',
                                locale,
                              ),
                        actionLabel: zeroFromFilters
                            ? CommonStrings.clearFilters
                            : BusinessesStrings.t('add_business', locale),
                        onAction: zeroFromFilters
                            ? _clearBrowseFilters
                            : _showAddBusinessSheet,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: index < feedItems.length - 1
                                ? AppSpacing.md
                                : 0,
                          ),
                          child: feedItems[index],
                        ),
                        childCount: feedItems.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: HubFeedFooterNotice(locale: locale)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdsBanner() {
    final isIftar = _isIftarFilter;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        glowColor: AppColors.warning,
        glowIntensity: 0.12,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIftar
                        ? BusinessStrings.iftarPromoteTitle
                        : BusinessStrings.advertiseTitle,
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isIftar
                        ? BusinessStrings.iftarPromoteSubtitle
                        : BusinessStrings.advertiseSubtitle,
                    style: AppTypography.body.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            GlassPrimaryButton(
              label: BusinessStrings.getFeatured,
              accentColor: AppColors.warning,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const BusinessAdvertiseScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class _AdPlaceholderCard extends StatelessWidget {
  const _AdPlaceholderCard({
    required this.onPromote,
    required this.locale,
  });

  final VoidCallback onPromote;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusSm,
      glowColor: AppColors.warning,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Text(
              BusinessesStrings.t('ad_placeholder', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            BusinessesStrings.t('ad_placeholder_body', locale),
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            BusinessesStrings.t('ad_placeholder_note', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onPromote,
              child: Text(BusinessesStrings.t('promote_business_link', locale)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingInfoBox extends StatelessWidget {
  const _ListingInfoBox({
    required this.title,
    required this.lines,
    required this.color,
    required this.statusSubtitle,
    this.compact = false,
  });

  final String title;
  final List<String> lines;
  final Color color;
  final String statusSubtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(statusSubtitle, style: TextStyle(color: color, fontSize: 11)),
          if (!compact) ...[
            const SizedBox(height: 8),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  line,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}