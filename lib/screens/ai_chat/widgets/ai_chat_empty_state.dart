import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/domain/home_ai_assistant_action.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/core/router/ai_chat_living_entrance_page.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_feed_teaser.dart';

class AiChatEmptyState extends StatelessWidget {
  const AiChatEmptyState({
    super.key,
    required this.locale,
    required this.greeting,
    required this.onChipTap,
    required this.onBrowseTopics,
    this.personaStarters = const [],
    this.personalizedPrompts = const [],
    this.contextualActions = const [],
    this.feedTeasers = const [],
    this.onContextualActionTap,
    this.onFeedTeaserTap,
    this.showServiceSuggestions = true,
    this.entranceProgress,
    this.orbState = RaabtaOrbState.idle,
  });

  final String locale;
  final String greeting;
  final ValueChanged<String> onChipTap;
  final VoidCallback onBrowseTopics;
  final List<String> personaStarters;
  final List<String> personalizedPrompts;
  final List<HomeAiAssistantAction> contextualActions;
  final List<AiChatFeedTeaser> feedTeasers;
  final ValueChanged<HomeAiAssistantAction>? onContextualActionTap;
  final ValueChanged<AiChatFeedTeaser>? onFeedTeaserTap;
  final bool showServiceSuggestions;
  final Animation<double>? entranceProgress;
  final RaabtaOrbState orbState;

  Widget _stagger(int index, Widget child) {
    final progress = entranceProgress;
    if (progress == null) return child;
    return AiChatLivingEntranceStagger(
      index: index,
      progress: progress,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stagger(
              0,
              RaabtaOrb(
                state: orbState,
                size: RaabtaOrbKitSizes.heroEmpty,
                showDepthRings: orbState == RaabtaOrbState.idle,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _stagger(
              1,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: AppTypography.headline2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AiChatStrings.t('ai_hero_subtitle', locale),
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (showServiceSuggestions && personaStarters.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                label: AiChatStrings.t('ai_persona_starters_header', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              _KitSuggestionGrid(
                children: [
                  for (var i = 0; i < personaStarters.length; i++)
                    _KitSuggestionCard(
                      label: personaStarters[i],
                      icon: Icons.auto_awesome_rounded,
                      tint: _KitSuggestionTints.forIndex(i),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChipTap(personaStarters[i]);
                      },
                    ),
                ],
              ),
            ],
            if (showServiceSuggestions &&
                contextualActions.isNotEmpty &&
                onContextualActionTap != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                label: AiChatStrings.t('ai_contextual_actions_header', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              _KitSuggestionGrid(
                children: [
                  for (var i = 0; i < contextualActions.length; i++)
                    _KitSuggestionCard(
                      label: contextualActions[i].label,
                      icon: contextualActions[i].icon,
                      tint: _KitSuggestionTints.forIndex(i),
                      showExternalLink: true,
                      subtitle: contextualActions[i].summary,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onContextualActionTap!(contextualActions[i]);
                      },
                    ),
                ],
              ),
            ],
            if (showServiceSuggestions &&
                feedTeasers.isNotEmpty &&
                onFeedTeaserTap != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                label: AiChatStrings.t('ai_feed_teasers_header', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              _KitSuggestionGrid(
                children: [
                  for (var i = 0; i < feedTeasers.length; i++)
                    _KitSuggestionCard(
                      label: feedTeasers[i].title,
                      icon: Icons.feed_outlined,
                      tint: _KitSuggestionTints.forIndex(i),
                      showExternalLink: true,
                      subtitle: feedTeasers[i].subtitle,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onFeedTeaserTap!(feedTeasers[i]);
                      },
                    ),
                ],
              ),
            ],
            if (showServiceSuggestions && personalizedPrompts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                label: AiChatStrings.t('ai_personalized_header', locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              _KitSuggestionGrid(
                children: [
                  for (var i = 0; i < personalizedPrompts.length; i++)
                    _KitSuggestionCard(
                      label: personalizedPrompts[i],
                      icon: Icons.auto_awesome_outlined,
                      tint: _KitSuggestionTints.forIndex(i),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChipTap(personalizedPrompts[i]);
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: onBrowseTopics,
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(AiChatStrings.t('ai_browse_topics', locale)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textOnGlassMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

abstract final class _KitSuggestionTints {
  static Color forIndex(int index) {
    return switch (index % 3) {
      0 => AppColors.accentGold,
      1 => AppColors.brandFamilyMain,
      _ => AppColors.tealGlow,
    };
  }
}

class _KitSuggestionGrid extends StatelessWidget {
  const _KitSuggestionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    const gap = 9.0;
    for (var i = 0; i < children.length; i += 2) {
      if (i + 1 < children.length) {
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: gap),
                Expanded(child: children[i + 1]),
              ],
            ),
          ),
        );
        rows.add(const SizedBox(height: gap));
      } else {
        rows.add(children[i]);
      }
    }
    if (rows.isNotEmpty && rows.last is SizedBox) {
      rows.removeLast();
    }
    return Column(children: rows);
  }
}

class _KitSuggestionCard extends StatelessWidget {
  const _KitSuggestionCard({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
    this.subtitle,
    this.showExternalLink = false,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
  final String? subtitle;
  final bool showExternalLink;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GlassContainer(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMd,
        glowIntensity: 0,
        padding: const EdgeInsets.all(AppSpacing.sm + 1),
        child: Row(
          children: [
            Container(
              width: AppSpacing.iconXl,
              height: AppSpacing.iconXl,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                color: tint.withValues(alpha: AppColors.isLight ? 0.12 : 0.18),
              ),
              child: Icon(icon, size: AppSpacing.iconMd, color: tint),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (showExternalLink)
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: AppColors.textOnGlassMuted,
              ),
          ],
        ),
      ),
    );
  }
}
