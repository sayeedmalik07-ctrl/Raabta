import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/screens/community/widgets/community_section_primitives.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  static const List<String> _filters = [
    'All',
    'Visa',
    'Jobs',
    'Traffic',
    'Events',
    'Government',
  ];

  static const List<String> _filterKeys = [
    'community_filter_all',
    'community_cat_visa',
    'community_cat_jobs',
    'community_news_filter_traffic',
    'community_tab_events',
    'community_news_filter_government',
  ];

  String _filterLabel(int index, String locale) =>
      CommunityStrings.t(_filterKeys[index], locale);

  int _selectedFilter = 0;

  Future<void> _openArticle(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CommunityStrings.t(
                'community_news_err_link',
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
    final locale = ref.watch(userLanguageProvider);
    final newsAsync = ref.watch(qatarExpatNewsProvider);
    final body = _buildBody(newsAsync);

    if (widget.embedded) return body;

    return CommunitySectionPrimitives.standaloneScaffold(
      context: context,
      title: CommunityStrings.t('community_news_title', locale),
      subtitle: CommunityStrings.t('community_news_subtitle', locale),
      body: body,
    );
  }

  Widget _buildBody(AsyncValue<QatarNewsResponse> newsAsync) {
    final locale = ref.watch(userLanguageProvider);
    return RefreshIndicator(
      color: CommunitySectionPrimitives.refreshColor,
      onRefresh: () async {
        NewsService.clearClientCache();
        ref.invalidate(qatarExpatNewsProvider);
        await ref.read(qatarExpatNewsProvider.future);
      },
      child: ListView(
        padding: CommunitySectionPrimitives.embeddedListPadding(
          embedded: widget.embedded,
        ),
        children: [
          if (widget.embedded)
            CommunitySectionPrimitives.embeddedSectionHeader(
              title: CommunityStrings.t('community_news_title', locale),
              subtitle: CommunityStrings.t('community_news_subtitle', locale),
              leadingIcon: Icons.newspaper_outlined,
              trailing: newsAsync.maybeWhen(
                data: (response) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommunityLiveDot(
                      active: response.isFresh,
                      locale: locale,
                    ),
                    if (response.sourceLabel.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        response.sourceLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          if (widget.embedded) const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return buildHubFilterChip(
                  label: Text(_filterLabel(index, locale)),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = index),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          newsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: HubLoadingPlaceholder(
                height: 160,
                width: 360,
                silhouette: HubLoadingSilhouette.postCard,
              ),
            ),
            error: (e, _) => GlassEmptyState(
              accent: GlassEmptyStateAccent.teal,
              icon: Icons.newspaper_outlined,
              title: CommunityStrings.t(
                'community_news_unavailable',
                locale,
              ),
              description: e is NewsServiceException
                  ? e.message
                  : CommunityStrings.t('community_news_refresh', locale),
            ),
            data: (response) {
              final filter = _filters[_selectedFilter];
              final news = filter == 'All'
                  ? response.articles
                  : response.articles
                      .where((n) => n.category == filter)
                      .toList();

              if (news.isEmpty) {
                return GlassEmptyState(
                  accent: GlassEmptyStateAccent.teal,
                  icon: Icons.newspaper_outlined,
                  title: CommunityStrings.t(
                    'community_news_empty',
                    locale,
                  ),
                  description: CommunityStrings.t(
                    'community_news_empty_hint',
                    locale,
                  ),
                );
              }

              return Column(
                children: [
                  for (final item in news)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _NewsHubPostCard(
                        item: item,
                        locale: locale,
                        onOpen: () => _openArticle(item.sourceUrl),
                      ),
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

class _NewsHubPostCard extends StatelessWidget {
  const _NewsHubPostCard({
    required this.item,
    required this.locale,
    required this.onOpen,
  });

  final QatarNewsArticle item;
  final String locale;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isOfficial = item.category == 'Government';
    final tier = isOfficial
        ? (
            label: CommunityStrings.t('community_trust_tier_official', locale),
            tier: HubContentTrustTier.official,
          )
        : (
            label: CommunityStrings.t('community_trust_tier_community', locale),
            tier: HubContentTrustTier.community,
          );
    final contextLine =
        '${item.sourceName} · ${communityRelativeTime(item.publishedAt, locale)}';

    return HubPostCard(
      authorName: item.sourceName,
      authorInitial: item.sourceName,
      sectionContextLine: contextLine,
      trustTierBadge: tier,
      body: item.title,
      maxBodyLines: 3,
      aiSummaryLine: item.summary,
      metaLine: CommunityStrings.t('community_news_read_more', locale),
      onTap: onOpen,
    );
  }
}
