import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Trust badge tone for [HubServiceCard] (kit §4 TrustBadge).
enum HubServiceTrustBadgeTone {
  verified,
  brand,
  neutral,
}

enum HubServiceCardKind { provider, request }

/// Label + tone for a ServiceCard trust row (max [HubLayoutTokens.serviceCardMaxTrustBadges]).
class HubServiceTrustBadge {
  const HubServiceTrustBadge({
    required this.label,
    required this.tone,
  });

  final String label;
  final HubServiceTrustBadgeTone tone;
}

/// Presentation-only Services hub card (kit §4 ServiceCard).
class HubServiceCard extends StatelessWidget {
  const HubServiceCard.provider({
    super.key,
    required this.providerName,
    required this.serviceTypeLine,
    this.rateLine,
    this.avatarUrl,
    this.avatarInitial,
    this.trustBadges = const [],
    this.trailing,
    this.onTap,
  })  : kind = HubServiceCardKind.provider,
        requestTitle = null,
        areaLine = null,
        postedLine = null,
        repliesLine = null,
        showOpenRequestBadge = false,
        openRequestBadgeLabel = null;

  const HubServiceCard.request({
    super.key,
    required this.requestTitle,
    this.areaLine,
    this.postedLine,
    this.repliesLine,
    this.showOpenRequestBadge = true,
    this.openRequestBadgeLabel,
    this.trustBadges = const [],
    this.trailing,
    this.onTap,
  })  : kind = HubServiceCardKind.request,
        providerName = null,
        serviceTypeLine = null,
        rateLine = null,
        avatarUrl = null,
        avatarInitial = null;

  final HubServiceCardKind kind;

  final String? providerName;
  final String? serviceTypeLine;
  final String? rateLine;
  final String? avatarUrl;
  final String? avatarInitial;

  final String? requestTitle;
  final String? areaLine;
  final String? postedLine;
  final String? repliesLine;
  final bool showOpenRequestBadge;
  final String? openRequestBadgeLabel;

  final List<HubServiceTrustBadge> trustBadges;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lg,
          child: kind == HubServiceCardKind.provider
              ? _ProviderBody(
                  providerName: providerName!,
                  serviceTypeLine: serviceTypeLine!,
                  rateLine: rateLine,
                  avatarUrl: avatarUrl,
                  avatarInitial: avatarInitial,
                  trustBadges: trustBadges,
                  trailing: trailing,
                )
              : _RequestBody(
                  requestTitle: requestTitle!,
                  areaLine: areaLine,
                  postedLine: postedLine,
                  repliesLine: repliesLine,
                  showOpenRequestBadge: showOpenRequestBadge,
                  openRequestBadgeLabel: openRequestBadgeLabel,
                  trustBadges: trustBadges,
                  trailing: trailing,
                ),
        ),
      ),
    );
  }
}

class _ProviderBody extends StatelessWidget {
  const _ProviderBody({
    required this.providerName,
    required this.serviceTypeLine,
    this.rateLine,
    this.avatarUrl,
    this.avatarInitial,
    required this.trustBadges,
    this.trailing,
  });

  final String providerName;
  final String serviceTypeLine;
  final String? rateLine;
  final String? avatarUrl;
  final String? avatarInitial;
  final List<HubServiceTrustBadge> trustBadges;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final rate = rateLine?.trim();
    final badges = _visibleBadges(trustBadges);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarTile(url: avatarUrl, initial: avatarInitial),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                providerName,
                style: AppTextStyles.h3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                serviceTypeLine,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (rate != null && rate.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  rate,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (badges.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _TrustBadgeRow(badges: badges),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _RequestBody extends StatelessWidget {
  const _RequestBody({
    required this.requestTitle,
    this.areaLine,
    this.postedLine,
    this.repliesLine,
    required this.showOpenRequestBadge,
    this.openRequestBadgeLabel,
    required this.trustBadges,
    this.trailing,
  });

  final String requestTitle;
  final String? areaLine;
  final String? postedLine;
  final String? repliesLine;
  final bool showOpenRequestBadge;
  final String? openRequestBadgeLabel;
  final List<HubServiceTrustBadge> trustBadges;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final area = areaLine?.trim();
    final posted = postedLine?.trim();
    final replies = repliesLine?.trim();
    final maxExtra = showOpenRequestBadge
        ? HubLayoutTokens.serviceCardMaxTrustBadges - 1
        : HubLayoutTokens.serviceCardMaxTrustBadges;
    final extraBadges = _visibleBadges(trustBadges, maxCount: maxExtra);
    final openLabel = openRequestBadgeLabel?.trim();
    final badges = [
      if (showOpenRequestBadge &&
          openLabel != null &&
          openLabel.isNotEmpty)
        HubServiceTrustBadge(
          label: openLabel,
          tone: HubServiceTrustBadgeTone.brand,
        ),
      ...extraBadges,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                requestTitle,
                style: AppTextStyles.h3,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
          ],
        ),
        if (area != null && area.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            area,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (posted != null && posted.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            posted,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (replies != null && replies.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            replies,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _TrustBadgeRow(badges: badges),
        ],
      ],
    );
  }
}

List<HubServiceTrustBadge> _visibleBadges(
  List<HubServiceTrustBadge> raw, {
  int? maxCount,
}) {
  final limit = maxCount ?? HubLayoutTokens.serviceCardMaxTrustBadges;
  return raw
      .where((b) => b.label.trim().isNotEmpty)
      .take(limit)
      .toList();
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({this.url, this.initial});

  final String? url;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final size = HubLayoutTokens.serviceCardAvatarSize;
    final trimmedUrl = url?.trim();
    if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          trimmedUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialAvatar(size: size, initial: initial),
        ),
      );
    }
    return _InitialAvatar(size: size, initial: initial);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.size, this.initial});

  final double size;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final raw = (initial ?? '?').trim();
    final letter =
        raw.isEmpty ? '?' : raw.substring(0, 1).toUpperCase();
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.brandFamilyMain.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.brandFamilyText,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustBadgeRow extends StatelessWidget {
  const _TrustBadgeRow({required this.badges});

  final List<HubServiceTrustBadge> badges;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: badges.map((b) => _TrustBadgeChip(badge: b)).toList(),
    );
  }
}

class _TrustBadgeChip extends StatelessWidget {
  const _TrustBadgeChip({required this.badge});

  final HubServiceTrustBadge badge;

  static const _tintAlpha = 0.16;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (badge.tone) {
      HubServiceTrustBadgeTone.verified => (
          AppColors.greenFamilyMain.withValues(alpha: _tintAlpha),
          AppColors.greenFamilyMain,
        ),
      HubServiceTrustBadgeTone.brand => (
          AppColors.brandFamilyMain.withValues(alpha: _tintAlpha),
          AppColors.brandFamilyMain,
        ),
      HubServiceTrustBadgeTone.neutral => (
          AppColors.textPrimary.withValues(alpha: _tintAlpha),
          AppColors.textSecondary,
        ),
    };

    return Container(
      height: HubLayoutTokens.trustBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(HubLayoutTokens.trustBadgeRadius),
        border: badge.tone == HubServiceTrustBadgeTone.neutral
            ? Border.all(color: AppColors.glassBorder)
            : null,
      ),
      child: Text(
        badge.label,
        style: TextStyle(
          color: foreground,
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
