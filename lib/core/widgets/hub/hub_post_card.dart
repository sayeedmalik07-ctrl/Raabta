import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Kit PostCard — community feed / Ask Qatar / group posts (presentation only).
class HubPostCard extends StatelessWidget {
  const HubPostCard({
    super.key,
    required this.authorName,
    this.body = '',
    this.bodyChild,
    this.authorInitial,
    this.sectionContextLine,
    this.trustTierBadge,
    this.metaLine,
    this.helperTemperatureLabel,
    this.aiSummaryLine,
    this.whySeeingLabel,
    this.onWhySeeingTap,
    this.maxBodyLines = 4,
    this.overflow,
    this.footer,
    this.onTap,
    this.pinnedLabel,
  });

  final String authorName;
  final String? authorInitial;
  final String? sectionContextLine;
  final ({String label, HubContentTrustTier tier})? trustTierBadge;
  final String body;
  final Widget? bodyChild;
  final int maxBodyLines;
  final String? metaLine;
  final String? helperTemperatureLabel;
  final String? aiSummaryLine;
  final String? whySeeingLabel;
  final VoidCallback? onWhySeeingTap;
  final Widget? overflow;
  final Widget? footer;
  final VoidCallback? onTap;
  final String? pinnedLabel;

  @override
  Widget build(BuildContext context) {
    final showWhy = whySeeingLabel != null &&
        whySeeingLabel!.trim().isNotEmpty &&
        onWhySeeingTap != null;
    final showMeta = metaLine != null && metaLine!.trim().isNotEmpty;
    final showHelper = helperTemperatureLabel != null &&
        helperTemperatureLabel!.trim().isNotEmpty;
    final showAi = aiSummaryLine != null && aiSummaryLine!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pinnedLabel != null && pinnedLabel!.trim().isNotEmpty) ...[
                _PinnedChip(label: pinnedLabel!),
                const SizedBox(height: AppSpacing.sm),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AuthorAvatar(initial: authorInitial ?? authorName),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                authorName,
                                style: AppTextStyles.h3.copyWith(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (trustTierBadge != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              HubContentTrustTierBadge(
                                label: trustTierBadge!.label,
                                tier: trustTierBadge!.tier,
                              ),
                            ],
                          ],
                        ),
                        if (sectionContextLine != null &&
                            sectionContextLine!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            sectionContextLine!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (overflow != null) overflow!,
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (bodyChild != null)
                bodyChild!
              else
                Text(
                  body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                  maxLines: maxBodyLines,
                  overflow: TextOverflow.ellipsis,
                ),
              if (showAi) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  aiSummaryLine!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (showMeta || showHelper) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (showMeta)
                      Text(
                        metaLine!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    if (showHelper)
                      _HelperTemperatureChip(label: helperTemperatureLabel!),
                  ],
                ),
              ],
              if (showWhy) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.brandFamilyText,
                    ),
                    onPressed: onWhySeeingTap,
                    child: Text(
                      whySeeingLabel!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.brandFamilyText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.md),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.initial});

  final String initial;

  static bool _isAsciiLetterOrDigit(String char) {
    if (char.isEmpty) return false;
    final c = char.codeUnitAt(0);
    return (c >= 0x30 && c <= 0x39) ||
        (c >= 0x41 && c <= 0x5A) ||
        (c >= 0x61 && c <= 0x7A);
  }

  /// Flags and group icons are full graphemes — not initials.
  static bool _shouldRenderEmojiAvatar(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return false;
    final graphemes = trimmed.characters;
    if (graphemes.length == 1 && !_isAsciiLetterOrDigit(graphemes.first)) {
      return true;
    }
    if (graphemes.length <= 3 && RegExp(r'^[A-Za-z0-9]+$').hasMatch(trimmed)) {
      return false;
    }
    return graphemes.length == 1;
  }

  @override
  Widget build(BuildContext context) {
    final raw = initial.trim();
    final size = HubLayoutTokens.jobCardLeadingSize;
    final decoration = BoxDecoration(
      color: communityHubAccent.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(size / 2),
    );

    if (raw.isEmpty) {
      return _avatarShell(
        size: size,
        decoration: decoration,
        child: Text(
          '?',
          style: AppTextStyles.h3.copyWith(
            fontSize: 16,
            color: communityHubAccentText,
          ),
        ),
      );
    }

    if (_shouldRenderEmojiAvatar(raw)) {
      return _avatarShell(
        size: size,
        decoration: decoration,
        child: Text(
          raw.characters.first,
          style: const TextStyle(fontSize: 22, height: 1.1),
        ),
      );
    }

    final letter = raw.characters.first.toUpperCase();
    return _avatarShell(
      size: size,
      decoration: decoration,
      child: Text(
        letter,
        style: AppTextStyles.h3.copyWith(
          fontSize: 16,
          color: communityHubAccentText,
        ),
      ),
    );
  }

  static Widget _avatarShell({
    required double size,
    required BoxDecoration decoration,
    required Widget child,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: decoration,
        child: Center(child: child),
      ),
    );
  }
}

class _PinnedChip extends StatelessWidget {
  const _PinnedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(HubLayoutTokens.trustBadgeRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.warning,
          fontSize: HubLayoutTokens.trustBadgeFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HelperTemperatureChip extends StatelessWidget {
  const _HelperTemperatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HubLayoutTokens.trustBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: communityHubAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(HubLayoutTokens.trustBadgeRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: communityHubAccentText,
          fontSize: HubLayoutTokens.trustBadgeFontSize,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
