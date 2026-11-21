import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/icons/raabta_icons.dart';
import 'package:raabta/core/widgets/horizontal_scroll_fade.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/features/home/utils/home_ai_feed_utils.dart';
import 'package:raabta/features/home/utils/home_for_you_because_mapper.dart';
import 'package:raabta/features/home/utils/home_for_you_pick_family.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_for_you_inline_copy.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Personalized picks from [aiFeedProvider] — kit horizontal pick rail.
class HomeForYouZone extends ConsumerWidget {
  const HomeForYouZone({
    super.key,
    required this.onAiTap,
    required this.onBuildProfileTap,
  });

  final VoidCallback onAiTap;
  final VoidCallback onBuildProfileTap;

  static const _homeVisibleCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final profile = ref.watch(userAIProfileProvider);
    final feedAsync = ref.watch(aiFeedProvider);
    final sectionTitle = AppShellStrings.t('home_for_you', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          overline: AppShellStrings.t('home_for_you_overline', locale),
          title: sectionTitle,
          actionText: AppShellStrings.t('home_ask_ai', locale),
          onActionTap: onAiTap,
          actionLinkColor: AppColors.brandFamilyMain,
          compact: true,
        ),
        feedAsync.when(
          loading: () => const GlassLoadingCard(height: 56),
          error: (_, _) => _FeedNeutralEmptyCard(
            locale: locale,
            signedIn: profile != null,
          ),
          data: (result) {
            if (profile != null &&
                ExpatScoreProfileHelper.isProfileIncomplete(profile)) {
              return _ForYouSetupCard(
                locale: locale,
                profile: profile,
                onBuildProfileTap: onBuildProfileTap,
              );
            }

            if (result.personalizationDisabled) {
              return _ForYouPrivacyCard(locale: locale);
            }

            final sorted = HomeAiFeedUtils.visibleCards(result);
            if (sorted.isEmpty) {
              return _FeedNeutralEmptyCard(
                locale: locale,
                signedIn: profile != null,
              );
            }
            final cards = sorted.take(_homeVisibleCount).toList();

            return Semantics(
              container: true,
              label: sectionTitle,
              child: HorizontalScrollFade(
                height: HomeCardTier.forYouPickHeight,
                playScrollHintOnce: false,
                builder: (controller) {
                  return ListView.separated(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSpacing.lg,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cards.length,
                    separatorBuilder: (_, _) => const SizedBox(
                      width: HomeCardTier.forYouRailGap,
                    ),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final item = _ForYouItem.fromFeedCard(
                        card,
                        profile: profile,
                        locale: locale,
                      );
                      return _ForYouPickCard(
                        item: item,
                        onTap: () {
                          if (item.route == '/ai-chat') {
                            onAiTap();
                            return;
                          }
                          context.push(item.route);
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ForYouSetupCard extends StatelessWidget {
  const _ForYouSetupCard({
    required this.locale,
    required this.profile,
    required this.onBuildProfileTap,
  });

  final String locale;
  final UserAIProfile profile;
  final VoidCallback onBuildProfileTap;

  @override
  Widget build(BuildContext context) {
    final prompt = ExpatScoreProfileHelper.buildProfilePrompt(profile, locale);

    return Semantics(
      button: true,
      label: prompt,
      child: HomeForYouInlineCopy(
        title: AppShellStrings.t('home_for_you_setup_title', locale),
        body: prompt,
        onBodyTap: onBuildProfileTap,
      ),
    );
  }
}

class _ForYouPrivacyCard extends StatelessWidget {
  const _ForYouPrivacyCard({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return HomeForYouInlineCopy(
      title: AppShellStrings.t('home_for_you_privacy_title', locale),
      body: AppShellStrings.t('home_for_you_privacy_desc', locale),
    );
  }
}

class _FeedNeutralEmptyCard extends StatelessWidget {
  const _FeedNeutralEmptyCard({
    required this.locale,
    required this.signedIn,
  });

  final String locale;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final bodyKey = signedIn
        ? 'home_feed_empty_desc_signed_in'
        : 'home_feed_empty_desc_signed_out';
    return Semantics(
      container: true,
      label: AppShellStrings.t('home_feed_empty_title', locale),
      child: HomeForYouInlineCopy(
        key: const Key('home_for_you_inline_empty'),
        title: AppShellStrings.t('home_feed_empty_title', locale),
        body: AppShellStrings.t(bodyKey, locale),
      ),
    );
  }
}

class _ForYouItem {
  const _ForYouItem({
    required this.icon,
    required this.title,
    required this.becauseLine,
    required this.family,
    required this.route,
    required this.cardType,
  });

  final IconData icon;
  final String title;
  final String? becauseLine;
  final HomeForYouPickFamily family;
  final String route;
  final FeedCardType cardType;

  factory _ForYouItem.fromFeedCard(
    AIFeedCard card, {
    required UserAIProfile? profile,
    required String locale,
  }) {
    final route = card.ctaRoute.isEmpty ? '/ai-chat' : card.ctaRoute;
    final family = homeForYouPickFamily(card);
    return _ForYouItem(
      icon: RaabtaIcons.forRoute(route),
      title: card.title,
      becauseLine: homeForYouPresentationBecauseLine(
        card: card,
        profile: profile,
        locale: locale,
      ),
      family: family,
      route: route,
      cardType: card.type,
    );
  }
}

class _ForYouPickCard extends StatelessWidget {
  const _ForYouPickCard({required this.item, required this.onTap});

  final _ForYouItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final familyMain = homeForYouFamilyMain(item.family);
    final familyText = homeForYouFamilyText(item.family);
    final semanticsLabel = item.becauseLine == null
        ? item.title
        : '${item.title}, ${item.becauseLine}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: SizedBox(
        width: HomeCardTier.forYouPickWidth,
        height: HomeCardTier.forYouPickHeight,
        child: GlassCard(
          onTap: onTap,
          padding: const EdgeInsets.all(12),
          borderRadius: HomeCardTier.homeCardRadius,
          glowColor: familyMain,
          glowIntensity: HomeCardTier.homeCardGlowIntensity,
          backgroundColor: familyMain.withValues(
            alpha: HomeCardTier.forYouPickFamilyTintAlpha,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeIconBadge(
                icon: item.icon,
                accentColor: familyMain,
                size: HomeCardTier.compactIconBadgeSize,
                iconSize: 18,
                variant: homeForYouBadgeVariant(item.family),
                chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: AppTypography.title.copyWith(
                          fontSize: 14.5,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.becauseLine != null) ...[
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          item.becauseLine!,
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            color: familyText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
