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
          subtitle: AppShellStrings.t('home_for_you_sub', locale),
          actionText: AppShellStrings.t('home_ask_ai', locale),
          onActionTap: onAiTap,
          actionLinkColor: AppColors.brandFamilyMain,
          compact: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        feedAsync.when(
          loading: () => const Column(
            children: [
              GlassLoadingCard(height: HomeCardTier.forYouPickHeight),
              SizedBox(height: AppSpacing.md),
              GlassLoadingCard(height: HomeCardTier.forYouPickHeight),
            ],
          ),
          error: (_, _) => _FeedNeutralEmptyCard(
            locale: locale,
            onAiTap: onAiTap,
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
                onAiTap: onAiTap,
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

    final card = GlassCard(
      onTap: onBuildProfileTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: HomeCardTier.homeCardGlowIntensity,
      backgroundColor: AppColors.brandFamilyMain.withValues(
        alpha: HomeCardTier.forYouPickFamilyTintAlpha,
      ),
      child: Row(
        children: [
          HomeIconBadge(
            icon: Icons.auto_awesome_outlined,
            accentColor: AppColors.brandFamilyMain,
            size: HomeCardTier.compactIconBadgeSize,
            iconSize: 20,
            variant: HomeIconBadgeVariant.exploreBrand,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppShellStrings.t('home_for_you_setup_title', locale),
                  style: AppTypography.subtitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  prompt,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return _SlowBrandSheen(
      borderRadius: HomeCardTier.homeCardRadius,
      child: card,
    );
  }
}

class _ForYouPrivacyCard extends StatelessWidget {
  const _ForYouPrivacyCard({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: HomeCardTier.homeCardGlowIntensity * 0.6,
      backgroundColor: AppColors.glassSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeIconBadge(
            icon: Icons.visibility_off_outlined,
            accentColor: AppColors.textOnGlassMuted,
            size: HomeCardTier.compactIconBadgeSize,
            iconSize: 20,
            variant: HomeIconBadgeVariant.exploreBrand,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppShellStrings.t('home_for_you_privacy_title', locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppShellStrings.t('home_for_you_privacy_desc', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedNeutralEmptyCard extends StatelessWidget {
  const _FeedNeutralEmptyCard({
    required this.locale,
    required this.onAiTap,
  });

  final String locale;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onAiTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: HomeCardTier.homeCardGlowIntensity,
      backgroundColor: AppColors.brandFamilyMain.withValues(
        alpha: HomeCardTier.forYouPickFamilyTintAlpha,
      ),
      child: Row(
        children: [
          HomeIconBadge(
            icon: Icons.auto_awesome_outlined,
            accentColor: AppColors.brandFamilyMain,
            size: HomeCardTier.compactIconBadgeSize,
            iconSize: 20,
            variant: HomeIconBadgeVariant.exploreBrand,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppShellStrings.t('home_feed_empty_title', locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppShellStrings.t('home_feed_empty_desc', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One slow brand sheen sweep (4.5s); disabled when reduce-motion is on.
class _SlowBrandSheen extends StatefulWidget {
  const _SlowBrandSheen({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  State<_SlowBrandSheen> createState() => _SlowBrandSheenState();
}

class _SlowBrandSheenState extends State<_SlowBrandSheen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    if (_controller != null) return;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) || _controller == null) {
      return widget.child;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller!,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _BrandSheenPainter(
                      progress: _controller!.value,
                      color: AppColors.brandFamilyMain,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandSheenPainter extends CustomPainter {
  _BrandSheenPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bandWidth = size.width * 0.35;
    final left = -bandWidth + (size.width + bandWidth * 2) * progress;
    final rect = Rect.fromLTWH(left, 0, bandWidth, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _BrandSheenPainter oldDelegate) {
    return oldDelegate.progress != progress;
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
