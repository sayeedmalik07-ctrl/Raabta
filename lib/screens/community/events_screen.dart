import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/screens/community/widgets/community_section_primitives.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raabta/services/qatar_events_service.dart';
import 'package:raabta/services/qatar_live_event.dart';
import 'package:raabta/services/smart_notification_engine.dart';
import 'package:raabta/features/community/widgets/community_group_tag_selector.dart';
import 'package:raabta/features/community/utils/community_group_tagging.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/features/community/widgets/community_cross_post_prompt.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/community/widgets/community_why_seeing_affordance.dart';
import 'package:raabta/features/community/utils/community_visibility_reasons.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

enum RsvpStatus { none, going, interested, notGoing }

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  static const List<String> _filters = [
    'Upcoming',
    'This Week',
    'Free',
    'Sports',
    'Cultural',
  ];

  static const List<String> _filterKeys = [
    'community_filter_upcoming',
    'community_filter_this_week',
    'community_filter_free',
    'community_filter_sports',
    'community_filter_cultural',
  ];

  String _filterLabel(int index, String locale) =>
      CommunityStrings.t(_filterKeys[index], locale);

  int _selectedFilter = 0;
  final Map<String, RsvpStatus> _rsvpStatus = {};
  bool _posting = false;

  Future<void> _showPostEventSheet() async {
    final joinedGroupIds =
        ref.read(communityMembershipProvider).value ?? const {};
    final suggestedLabels =
        ref.read(suggestedCommunityContentLabelIdsProvider);

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    var eventDate = DateTime.now().add(const Duration(days: 3));
    var selectedGroupTags = <String>{};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return CommunityReactiveLocale(
          builder: (context, locale) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return DraftAwareSheet(
              formId: DraftBoxKeys.eventComposer('community'),
              controllers: [
                titleController,
                descController,
                locationController,
              ],
              serialize: () => {
                'title': titleController.text,
                'description': descController.text,
                'location': locationController.text,
                'eventDate': eventDate.toIso8601String(),
              },
              applyDraft: (data) {
                setSheetState(() {
                  titleController.text = data['title']?.toString() ?? '';
                  descController.text = data['description']?.toString() ?? '';
                  locationController.text = data['location']?.toString() ?? '';
                  final raw = data['eventDate']?.toString();
                  if (raw != null) {
                    eventDate = DateTime.tryParse(raw) ?? eventDate;
                  }
                });
              },
              builder: (context, draft) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.lg,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          CommunityStrings.t('community_events_post', locale),
                          style: AppTypography.headline2,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: CommunityStrings.t(
                              'community_events_label_title',
                              locale,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: descController,
                          decoration: InputDecoration(
                            labelText: CommunityStrings.t(
                              'community_events_label_description',
                              locale,
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: CommunityStrings.t(
                              'community_events_label_location',
                              locale,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            CommunityStrings.t(
                              'community_events_date_time',
                              locale,
                            ),
                          ),
                          subtitle:
                              Text(DateFormat.yMMMd().add_jm().format(eventDate)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: eventDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date == null) return;
                            if (!context.mounted) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(eventDate),
                            );
                            if (time == null) return;
                            setSheetState(() {
                              eventDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                            draft.notifyChanged();
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (joinedGroupIds.isNotEmpty ||
                            suggestedLabels.isNotEmpty)
                          CommunityGroupTagSelector(
                            joinedGroupIds: joinedGroupIds,
                            selectedIds: selectedGroupTags,
                            locale: locale,
                            suggestedContentLabelIds: suggestedLabels,
                            onChanged: _posting
                                ? (_) {}
                                : (tags) {
                                    setSheetState(
                                      () => selectedGroupTags = tags,
                                    );
                                    draft.notifyChanged();
                                  },
                            enabled: !_posting,
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _posting
                              ? null
                              : () async {
                                  final title = titleController.text.trim();
                                  final description = descController.text.trim();
                                  final location = locationController.text.trim();
                                  if (title.length < 5 || location.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          CommunityStrings.t(
                                            'community_events_err_title_location',
                                            locale,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _posting = true);
                                  try {
                                    final joinedGroupIds = ref.read(
                                      communityMembershipProvider,
                                    ).value ?? const {};
                                    final finalTags =
                                        await CommunityCrossPostPrompt.resolveTags(
                                      context: context,
                                      selectedTags: selectedGroupTags,
                                      joinedGroupIds: joinedGroupIds,
                                      locale: locale,
                                    );
                                    if (!context.mounted) return;

                                    final primaryGroup =
                                        CommunityGroupTagging.primaryGroupId(
                                      finalTags,
                                    );
                                    final orchestrator = ref.read(
                                      communityModerationOrchestratorProvider,
                                    );
                                    final submit = await orchestrator.submitEvent(
                                      relevantGroupIds: finalTags,
                                      title: title,
                                      description: description,
                                      location: location,
                                      dateTime: eventDate,
                                    );

                                    if (!submit.ok) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(submit.message)),
                                        );
                                      }
                                      return;
                                    }

                                    await draft.clearDraft();

                                    final outcome = submit.outcome!;
                                    if (!mounted) return;
                                    if (context.mounted) Navigator.pop(ctx);

                                    if (!outcome.reason
                                        .contains('being reviewed')) {
                                      final repo =
                                          ref.read(communityRepositoryProvider);
                                      final creatorId = await repo.currentUserId();
                                      await SmartNotificationEngine.instance
                                          .notifyEventVerificationResult(
                                        eventId: outcome.eventId,
                                        groupId: primaryGroup,
                                        title: title,
                                        approved: outcome.approved,
                                        reason: outcome.reason,
                                        creatorUserId: creatorId,
                                      );
                                    }

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          outcome.skippedClaude &&
                                                  !outcome.approved &&
                                                  outcome.reason.contains(
                                                    'being reviewed',
                                                  )
                                              ? outcome.reason
                                              : outcome.approved
                                                  ? CommunityStrings.t(
                                                      'community_events_approved',
                                                      locale,
                                                    )
                                                  : CommunityStrings.format(
                                                      'community_events_rejected',
                                                      locale,
                                                      params: {
                                                        'reason': outcome.reason,
                                                      },
                                                    ),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          CommunityStrings.t(
                                            'community_events_err_post',
                                            locale,
                                          ),
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _posting = false);
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandFamilyMain,
                            foregroundColor: AppColors.background,
                          ),
                          child: _posting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  CommunityStrings.t(
                                    'community_events_submit_review',
                                    locale,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
            );
          },
        );
      },
    );

    titleController.dispose();
    descController.dispose();
    locationController.dispose();
  }

  List<CommunityEvent> _filterCommunityEvents(List<CommunityEvent> events) {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final filter = _filters[_selectedFilter];

    return events.where((event) {
      final dt = event.dateTime;
      if (filter == 'Upcoming') return dt == null || !dt.isBefore(now);
      if (filter == 'This Week') {
        return dt != null && !dt.isBefore(now) && dt.isBefore(weekEnd);
      }
      final text = '${event.title} ${event.description}'.toLowerCase();
      if (filter == 'Free') return text.contains('free');
      if (filter == 'Sports') {
        return text.contains('sport') || text.contains('cricket');
      }
      if (filter == 'Cultural') {
        return text.contains('cultural') || text.contains('night');
      }
      return true;
    }).toList();
  }

  List<QatarLiveEvent> _filterLiveEvents(List<QatarLiveEvent> events) {
    final filter = _filters[_selectedFilter];
    if (filter == 'Upcoming') return events;
    return events.where((e) => e.tags.contains(filter)).toList();
  }

  Future<void> _openEventUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CommunityStrings.t(
                'community_events_err_link',
                ref.read(userLanguageProvider),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvedAsync = ref.watch(approvedEventsProvider);
    final pendingAsync = ref.watch(creatorPendingEventsProvider);
    final liveAsync = ref.watch(qatarLiveEventsProvider);
    final body = _buildBody(approvedAsync, pendingAsync, liveAsync);

    if (widget.embedded) return body;

    final locale = ref.watch(userLanguageProvider);
    return CommunitySectionPrimitives.standaloneScaffold(
      context: context,
      title: CommunityStrings.t('community_events_title', locale),
      subtitle: CommunityStrings.t('community_events_subtitle', locale),
      body: body,
    );
  }

  Widget _buildBody(
    AsyncValue<List<CommunityEvent>> approvedAsync,
    AsyncValue<List<CommunityEvent>> pendingAsync,
    AsyncValue<QatarLiveEventsResponse> liveAsync,
  ) {
    final locale = ref.watch(userLanguageProvider);
    return RefreshIndicator(
      color: CommunitySectionPrimitives.refreshColor,
      onRefresh: () async {
        ref.invalidate(approvedEventsProvider);
        ref.invalidate(creatorPendingEventsProvider);
        ref.invalidate(qatarLiveEventsProvider);
        await ref.read(qatarLiveEventsProvider.future);
      },
      child: ListView(
        padding: CommunitySectionPrimitives.embeddedListPadding(
          embedded: widget.embedded,
        ),
        children: [
          if (widget.embedded)
            CommunitySectionPrimitives.embeddedSectionHeader(
              title: CommunityStrings.t('community_events_title', locale),
              subtitle: CommunityStrings.t(
                'community_events_subtitle',
                locale,
              ),
              leadingIcon: Icons.event_outlined,
            ),
          if (widget.embedded) const SizedBox(height: AppSpacing.md),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _posting ? null : _showPostEventSheet,
              icon: CommunityHubIcons.actionGlyph(
                Icons.add,
                color: AppColors.background,
              ),
              label: Text(CommunityStrings.t('community_events_post', locale)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandFamilyMain,
                foregroundColor: AppColors.background,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: HubLayoutTokens.filterChipHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return buildHubFilterChip(
                  label: Text(_filterLabel(index, locale)),
                  selected: _selectedFilter == index,
                  onSelected: (_) => setState(() => _selectedFilter = index),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          liveAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: HubLoadingPlaceholder(
                height: 140,
                width: 360,
                silhouette: HubLoadingSilhouette.postCard,
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: GlassEmptyState(
                accent: GlassEmptyStateAccent.teal,
                icon: Icons.cloud_off_outlined,
                title: CommunityStrings.t(
                  'community_events_live_unavailable',
                  locale,
                ),
                description: e is QatarEventsException
                    ? e.message
                    : CommunityStrings.t(
                        'community_events_live_unavailable',
                        locale,
                      ),
              ),
            ),
            data: (liveResponse) {
              final liveEvents = _filterLiveEvents(liveResponse.events);
              if (liveEvents.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        CommunityStrings.t(
                          'community_events_happening',
                          locale,
                        ),
                        style: AppTypography.subtitle,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      CommunityLiveDot(
                        active: liveResponse.isFresh,
                        locale: locale,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        liveResponse.sourceLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final event in liveEvents)
                    _LiveEventHubCard(
                      event: event,
                      locale: locale,
                      onTap: () => _openEventUrl(event.sourceUrl),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            },
          ),
          pendingAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (pending) {
              if (pending.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CommunityStrings.t('community_events_your_submissions', locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final event in pending)
                    _PendingEventHubCard(event: event, locale: locale),
                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            },
          ),
          approvedAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (events) {
              final filtered = _filterCommunityEvents(events);
              if (filtered.isEmpty) {
                if (liveAsync.isLoading) return const SizedBox.shrink();
                return liveAsync.maybeWhen(
                  data: (live) {
                    if (_filterLiveEvents(live.events).isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (live.events.isNotEmpty || events.isNotEmpty) {
                    return GlassEmptyState(
                      accent: GlassEmptyStateAccent.teal,
                      icon: Icons.event_busy_outlined,
                      title: CommunityStrings.t(
                        'community_events_no_match',
                        locale,
                      ),
                      description: CommunityStrings.t(
                        'community_events_no_match_hint',
                        locale,
                      ),
                    );
                    }
                    return GlassEmptyState(
                      accent: GlassEmptyStateAccent.teal,
                      icon: Icons.event_busy_outlined,
                      title: CommunityStrings.t(
                        'community_events_empty',
                        locale,
                      ),
                      description: CommunityStrings.t(
                        'community_events_empty_hint',
                        locale,
                      ),
                    );
                  },
                  orElse: () => GlassEmptyState(
                    accent: GlassEmptyStateAccent.teal,
                    icon: Icons.event_busy_outlined,
                    title: CommunityStrings.t(
                      'community_events_empty',
                      locale,
                    ),
                    description: CommunityStrings.t(
                      'community_events_empty_hint',
                      locale,
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CommunityStrings.t('community_events_community_meetups', locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final event in filtered)
                    _EventHubCard(
                      event: event,
                      locale: locale,
                      rsvp: _rsvpStatus[event.id] ?? RsvpStatus.none,
                      onRsvp: (status) {
                        setState(() => _rsvpStatus[event.id] = status);
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PendingEventHubCard extends StatelessWidget {
  const _PendingEventHubCard({required this.event, required this.locale});

  final CommunityEvent event;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = event.isPending
        ? CommunityStrings.t('community_events_under_review', locale)
        : event.isRejected
            ? CommunityStrings.t('community_events_rejected_status', locale)
            : event.status;
    final color = event.isPending
        ? AppColors.warning
        : event.isRejected
            ? AppColors.error
            : AppColors.textSecondary;
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: HubPostCard(
        authorName:
            CommunityStrings.t('community_events_your_submissions', locale),
        authorInitial: '!',
        sectionContextLine: CommunityStrings.t('community_tab_events', locale),
        trustTierBadge: (
          label: trustLabel,
          tier: HubContentTrustTier.community,
        ),
        body: event.title,
        bodyChild: event.aiVerificationNote.isNotEmpty
            ? Text(event.aiVerificationNote, style: AppTypography.bodySmall)
            : null,
        footer: StatusBadge(label: label, color: color),
      ),
    );
  }
}

class _EventHubCard extends ConsumerWidget {
  const _EventHubCard({
    required this.event,
    required this.locale,
    required this.rsvp,
    required this.onRsvp,
  });

  final CommunityEvent event;
  final String locale;
  final RsvpStatus rsvp;
  final ValueChanged<RsvpStatus> onRsvp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = CommunityGroupRegistry.byId(event.groupId);
    final dateLabel = event.dateTime != null
        ? DateFormat('EEE d MMM · h:mm a').format(event.dateTime!)
        : CommunityStrings.t('community_events_date_tbc', locale);
    final section = CommunityStrings.t('community_tab_events', locale);
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);
    final visibility = CommunityVisibilityInput(
      relevantGroupIds: event.relevantGroupIds,
      contentLocation: event.location,
    );
    final whyLabel = CommunityStrings.t('community_why_seeing_link', locale);
    final goingLabel = rsvp == RsvpStatus.going
        ? CommunityStrings.t('community_events_going_check', locale)
        : CommunityStrings.t('community_events_going', locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: HubPostCard(
        authorName: group?.name ??
            CommunityStrings.t('community_events_community_meetups', locale),
        authorInitial: group?.emoji ?? '📅',
        sectionContextLine: '$section · $dateLabel · ${event.location}',
        trustTierBadge: (
          label: trustLabel,
          tier: HubContentTrustTier.community,
        ),
        body: event.title,
        bodyChild: event.description.isNotEmpty
            ? UserGeneratedTextWithLinkSafety(
                text: event.description,
                locale: locale,
                surface: LinkSafetySurface.events,
                style: AppTypography.body,
              )
            : null,
        whySeeingLabel: whyLabel,
        onWhySeeingTap: () => CommunityWhySeeingAffordance.showForInput(
          context,
          ref,
          visibility,
        ),
        footer: Row(
          children: [
            Expanded(
              child: buildHubChoiceChip(
                label: Text(goingLabel),
                selected: rsvp == RsvpStatus.going,
                onSelected: (_) => onRsvp(
                  rsvp == RsvpStatus.going
                      ? RsvpStatus.none
                      : RsvpStatus.going,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: buildHubChoiceChip(
                label: Text(
                  CommunityStrings.t('community_events_interested', locale),
                ),
                selected: rsvp == RsvpStatus.interested,
                onSelected: (_) => onRsvp(
                  rsvp == RsvpStatus.interested
                      ? RsvpStatus.none
                      : RsvpStatus.interested,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveEventHubCard extends StatelessWidget {
  const _LiveEventHubCard({
    required this.event,
    required this.locale,
    required this.onTap,
  });

  final QatarLiveEvent event;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = event.dateTime != null
        ? DateFormat('EEE d MMM · h:mm a').format(event.dateTime!)
        : CommunityStrings.t('community_events_schedule_online', locale);
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);
    final statusLabel = event.isFree
        ? CommunityStrings.t('community_filter_free', locale)
        : event.category;
    final statusColor =
        event.isFree ? AppColors.success : AppColors.brandFamilyMain;
    final metaLine =
        '${event.sourceName} · ${CommunityStrings.t('community_events_view_details', locale)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: HubPostCard(
        authorName: event.sourceName,
        authorInitial: event.emoji,
        sectionContextLine:
            '${CommunityStrings.t('community_events_happening', locale)} · $dateLabel · ${event.location}',
        trustTierBadge: (
          label: trustLabel,
          tier: HubContentTrustTier.community,
        ),
        body: event.title,
        bodyChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.summary.isNotEmpty)
              Text(
                event.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body,
              ),
            const SizedBox(height: AppSpacing.sm),
            StatusBadge(label: statusLabel, color: statusColor),
          ],
        ),
        metaLine: metaLine,
        onTap: onTap,
      ),
    );
  }
}
