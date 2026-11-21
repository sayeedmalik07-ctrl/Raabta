import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/models/community_pulse_snapshot.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/widgets/community_pulse_strip.dart';
import 'package:raabta/providers/visa_providers.dart';

GroupPost sampleCommunityFeedPost({String id = 'golden-post'}) {
  return GroupPost(
    id: id,
    groupId: '0',
    text: 'Anyone know a good pharmacy open late in West Bay?',
    createdBy: 'user-$id',
    authorDisplayName: 'Sara M.',
    authorInitials: 'SM',
    createdAt: DateTime(2026, 3, 1, 14, 30),
    likes: 4,
    commentCount: 2,
    relevantGroupIds: const ['0'],
  );
}

/// Landing chrome fixture (no Firestore) — matches kit anatomy for goldens.
class CommunityHubChromeFixture extends ConsumerWidget {
  const CommunityHubChromeFixture({
    super.key,
    required this.locale,
    required this.feedPosts,
  });

  final String locale;
  final List<GroupPost> feedPosts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedLabel = CommunityStrings.t('community_tab_feed', locale);
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HubLandingHeader(
              title: CommunityStrings.t('community_hub_title', locale),
              subtitle: CommunityStrings.t('community_hub_subtitle', locale),
              showBack: false,
              onBack: () {},
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                0,
              ),
              child: TextField(
                readOnly: true,
                decoration: hubSearchInputDecoration(
                  hintText: CommunityStrings.t(
                    'community_search_hub_hint',
                    locale,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                0,
              ),
              child: CommunityPulseStrip(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: buildHubFilterChip(
                  label: Text(feedLabel),
                  selected: true,
                  onSelected: (_) {},
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                children: [
                  if (feedPosts.isEmpty)
                    GlassEmptyState(
                      accent: GlassEmptyStateAccent.teal,
                      icon: Icons.forum_outlined,
                      title: CommunityStrings.t(
                        'community_feed_empty_title',
                        locale,
                      ),
                      description: CommunityStrings.t(
                        'community_trending_empty_hint',
                        locale,
                      ),
                    )
                  else
                    for (final post in feedPosts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: HubPostCard(
                          authorName: post.authorDisplayName,
                          authorInitial: post.authorInitials,
                          sectionContextLine: 'Indians in Qatar · 2h ago',
                          trustTierBadge: (
                            label: trustLabel,
                            tier: HubContentTrustTier.community,
                          ),
                          body: post.text,
                          metaLine: '2 comments · 4 likes',
                        ),
                      ),
                  HubFeedFooterNotice(locale: locale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget pumpCommunityHub({
  required WidgetTester tester,
  List<GroupPost> feedPosts = const [],
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.dark,
  double width = 390,
  double textScale = 1.0,
  String locale = 'English',
}) {
  tester.view.physicalSize = Size(width * 3, 2000 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => AppColors.applyBrightness(brightness == Brightness.light));

  AppColors.applyBrightness(brightness == Brightness.light);

  final now = DateTime(2026, 3, 1, 12);

  return ProviderScope(
    overrides: [
      userLanguageProvider.overrideWith((ref) => locale),
      communityPulseProvider.overrideWith(
        (ref) async => CommunityPulseSnapshot(
          trendingDiscussions: 24,
          eventsToday: 3,
          openQuestions: 11,
          fetchedAt: now,
        ),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: CommunityHubChromeFixture(
          locale: locale,
          feedPosts: feedPosts,
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}
