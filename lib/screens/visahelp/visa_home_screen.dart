import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/icons/service_screen_icons.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_guide_card.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_quick_action_tile.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/legal_sources/providers/legal_sources_providers.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/deadline_tracker.dart';
import 'package:raabta/screens/visahelp/l10n/visa_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class VisaHomeScreen extends ConsumerStatefulWidget {
  const VisaHomeScreen({super.key, this.highlightDeadlineId});

  final String? highlightDeadlineId;

  @override
  ConsumerState<VisaHomeScreen> createState() => _VisaHomeScreenState();
}

class _VisaHomeScreenState extends ConsumerState<VisaHomeScreen> {
  final _trackerKey = GlobalKey();
  final _guideSearchController = TextEditingController();
  String _guideQuery = '';

  @override
  void initState() {
    super.initState();
    _guideSearchController.addListener(() {
      setState(() => _guideQuery = _guideSearchController.text);
    });
  }

  @override
  void dispose() {
    _guideSearchController.dispose();
    super.dispose();
  }

  Future<void> _showEmergencyHelp(BuildContext context, String locale) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSm),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    VisaStrings.t('visa_emergency_help', locale),
                    style: AppTypography.headline2,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                VisaStrings.t('visa_emergency_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ...emergencyContacts.map((contact) {
                return GlassSettingsTile(
                  title: contact.name,
                  subtitle: contact.description,
                  trailing: FilledButton(
                    onPressed: () async {
                      final uri = Uri.parse('tel:${contact.number}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(contact.number),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddDeadlineDialog(String locale) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => DeadlineAddDialog(locale: locale),
    );
    if (saved == true && mounted) {
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      _scrollToTracker();
    }
  }

  void _scrollToTracker() {
    final ctx = _trackerKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  String _deadlineDocumentLabel(DocumentDeadline d, String locale) {
    if (d.isVisitVisaEntry) {
      return d.displayTitle(
        VisaStrings.t('visa_deadline_visit_visa_label', locale),
      );
    }
    return d.documentType;
  }

  String _deadlineWhenPhrase(DocumentDeadline d, String locale) {
    final days = d.daysRemaining;
    if (days < 0) {
      return VisaStrings.format(
        'visa_deadline_expired_days_ago',
        locale,
        params: {'days': '${days.abs()}'},
      );
    }
    if (days == 0) {
      return VisaStrings.t('visa_deadline_expires_today', locale);
    }
    if (days == 1) {
      return VisaStrings.t('visa_deadline_expires_one_day', locale);
    }
    return VisaStrings.format(
      'visa_deadline_expires_days',
      locale,
      params: {'days': '$days'},
    );
  }

  List<VisaCategory> _filteredGuideCategories(String locale) {
    final q = _guideQuery.trim().toLowerCase();
    if (q.isEmpty) return visaCategories.toList();
    return visaCategories.where((c) {
      final title = VisaStrings.categoryTitle(c.id, locale).toLowerCase();
      return title.contains(q);
    }).toList();
  }

  void _onStartRenewal(DocumentDeadline next) {
    final id = next.guideCategoryId.trim();
    if (id.isEmpty) {
      _scrollToTracker();
      return;
    }
    context.push('/visa/guide/$id');
  }

  Widget _deadlineHero(String locale) {
    final deadlinesAsync = ref.watch(documentDeadlinesProvider);

    return deadlinesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: HubLoadingPlaceholder(
            width: 320,
            height: 100,
            silhouette: HubLoadingSilhouette.formTool,
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: GlassErrorState(
          message: VisaStrings.t('visa_load_deadlines_error', locale),
          onRetry: () => ref.invalidate(documentDeadlinesProvider),
        ),
      ),
      data: (deadlines) {
        if (deadlines.isEmpty) {
          return GlassCard(
            onTap: null,
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppSpacing.radiusLg,
            glowColor: AppColors.goldFamilyMain,
            glowIntensity: 0.14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: AppColors.goldFamilyMain,
                      size: AppSpacing.iconMd,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        VisaStrings.t('visa_next_deadline_heading', locale),
                        style: AppTypography.headline2.copyWith(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  VisaStrings.t('visa_no_deadlines_title', locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  VisaStrings.t('visa_no_deadlines_body', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassPrimaryButton(
                  label: VisaStrings.t('visa_deadline_hero_add_first', locale),
                  icon: Icons.add_circle_outline,
                  onPressed: () => _showAddDeadlineDialog(locale),
                  accentColor: AppColors.goldFamilyMain,
                  expand: true,
                ),
              ],
            ),
          );
        }

        final sorted = List<DocumentDeadline>.from(deadlines)
          ..sort(
            (a, b) => a.expiryDate.compareTo(b.expiryDate),
          );
        final next = sorted.first;
        final docLabel = _deadlineDocumentLabel(next, locale);
        final whenPhrase = _deadlineWhenPhrase(next, locale);
        final headline = VisaStrings.format(
          'visa_next_deadline_line',
          locale,
          params: {
            'document': docLabel,
            'when': whenPhrase,
          },
        );

        return GlassCard(
          onTap: null,
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppSpacing.radiusLg,
          glowColor: AppColors.goldFamilyMain,
          glowIntensity: 0.14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                VisaStrings.t('visa_next_deadline_heading', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textOnGlassMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                headline,
                style: AppTypography.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (next.vaultDocumentId != null &&
                  next.vaultDocumentId!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  VisaStrings.t('visa_from_document_vault', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: VisaStrings.t('visa_start_renewal', locale),
                icon: Icons.arrow_forward,
                onPressed: () => _onStartRenewal(next),
                accentColor: AppColors.goldFamilyMain,
                expand: true,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(userLanguageProvider);
    final lawUpdatedAsync = ref.watch(lastLegalUpdateProvider);
    final lawChipLabel = lawUpdatedAsync.when(
      loading: () =>
          VisaStrings.t('visa_law_updated_line', language).replaceAll(
            '{date}',
            '…',
          ),
      error: (_, _) => VisaStrings.format(
        'visa_law_updated_line',
        language,
        params: {'date': LegalSourcesSeedCatalog.seedLatestVerifiedDisplay},
      ),
      data: (date) => VisaStrings.format(
        'visa_law_updated_line',
        language,
        params: {'date': DateFormat.yMMMd().format(date)},
      ),
    );
    final filteredGuides = _filteredGuideCategories(language);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: HubLandingHeader(
                  title: VisaStrings.t('visa_hub_title', language),
                  subtitle: VisaStrings.t('visa_hub_subtitle', language),
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
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
                            controller: _guideSearchController,
                            style: AppTypography.subtitle,
                            textInputAction: TextInputAction.search,
                            decoration: hubSearchInputDecoration(
                              hintText:
                                  VisaStrings.t('visa_search_hint', language),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      PopupMenuButton<String>(
                        tooltip: VisaStrings.t('visa_hub_menu', language),
                        icon: Container(
                          width: HubLayoutTokens.filterControlSize,
                          height: HubLayoutTokens.filterControlSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(
                              alpha: AppColors.isLight ? 0.9 : 0.5,
                            ),
                            borderRadius: BorderRadius.circular(
                              HubLayoutTokens.searchPillRadius,
                            ),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'emergency') {
                            _showEmergencyHelp(context, language);
                          } else if (value == 'add_deadline') {
                            _showAddDeadlineDialog(language);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem<String>(
                            value: 'emergency',
                            child: ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.emergency_outlined,
                                color: AppColors.error,
                              ),
                              title: Text(
                                VisaStrings.t('visa_emergency_help', language),
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'add_deadline',
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.brandFamilyMain,
                              ),
                              title: Text(
                                VisaStrings.t(
                                  'visa_add_document_deadline',
                                  language,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
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
                          icon: Icons.document_scanner_outlined,
                          label: VisaStrings.t(
                            'visa_scan_document',
                            language,
                          ),
                          onTap: () =>
                              context.push('/scanner/capture?source=visa'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: HubQuickActionTile(
                          icon: Icons.folder_special_outlined,
                          label: VisaStrings.t(
                            'visa_vault_entry_title',
                            language,
                          ),
                          onTap: () => context.push('/document-vault'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: HubQuickActionTile(
                          icon: Icons.event_note_outlined,
                          label: VisaStrings.t(
                            'visa_quick_action_deadlines',
                            language,
                          ),
                          onTap: _scrollToTracker,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: HubQuickActionTile(
                          icon: Icons.gavel_outlined,
                          label: VisaStrings.t(
                            'visa_quick_action_rights',
                            language,
                          ),
                          onTap: () => context.push('/know-qatar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: _deadlineHero(language),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: HomeSectionHeader(
                    title: VisaStrings.t('visa_section_guides', language),
                    leadingIcon: Icons.menu_book_outlined,
                    compact: true,
                  ),
                ),
              ),
              if (filteredGuides.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Text(
                      VisaStrings.t(
                        'visa_guides_search_empty',
                        language,
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  sliver: SliverList.separated(
                    itemCount: filteredGuides.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final category = filteredGuides[index];
                      final icon =
                          ServiceScreenIcons.visaCategory(category.id);
                      final stepsLabel = VisaStrings.format(
                        'visa_steps_count',
                        language,
                        params: {'count': '${category.steps}'},
                      );
                      final meta = VisaStrings.format(
                        'visa_guide_meta',
                        language,
                        params: {
                          'steps': stepsLabel,
                          'eta': category.estimatedTime,
                        },
                      );
                      return HubGuideCard(
                        icon: icon,
                        title: VisaStrings.categoryTitle(
                          category.id,
                          language,
                        ),
                        lawUpdatedLabel: lawChipLabel,
                        metaLine: meta,
                        accentColor: AppColors.brandFamilyMain,
                        onTap: () =>
                            context.push('/visa/guide/${category.id}'),
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _trackerKey,
                  child: DeadlineTrackerWidget(
                    highlightDeadlineId: widget.highlightDeadlineId,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HubFeedFooterNotice(locale: language),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
