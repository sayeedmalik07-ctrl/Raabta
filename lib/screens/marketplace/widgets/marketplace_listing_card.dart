import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/metric_chip.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/models/marketplace_models.dart';

/// Hub kit listing card for Marketplace — photo-led (same grammar as Housing [ListingCard]).
class MarketplaceListingCard extends StatelessWidget {
  const MarketplaceListingCard({
    super.key,
    required this.listing,
    required this.locale,
    required this.isSaved,
    required this.onSave,
    required this.onTap,
    this.onBoost,
    this.onGetQr,
    this.isSponsored = false,
    this.compactGrid = false,
    this.showTrustBadges = true,
  });

  final MarketplaceListing listing;
  final String locale;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onTap;
  final VoidCallback? onBoost;
  final VoidCallback? onGetQr;
  final bool isSponsored;
  final bool compactGrid;
  final bool showTrustBadges;

  static const _kCardRadius = 22.0;
  static const _kMediaTopRadius = AppRadius.xl;

  @override
  Widget build(BuildContext context) {
    final badge = _badgeForListing(listing);
    final metaLine =
        '${listing.area} · ${listing.posted} · ${listing.sellerFlag}';

    final borderColor = isSponsored
        ? AppColors.goldFamilyMain.withValues(alpha: 0.35)
        : _cardBorderColor(badge);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.isLight
                  ? AppColors.surface
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(_kCardRadius),
              border: Border.all(color: borderColor),
              boxShadow: AppColors.isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ListingPhotoBlock(
                  listing: listing,
                  locale: locale,
                  badge: badge,
                  isSaved: isSaved,
                  onSave: onSave,
                  compact: compactGrid,
                ),
                Padding(
                  padding: EdgeInsets.all(
                    compactGrid ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.price,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.brandFamilyMain,
                          fontSize: compactGrid ? 16 : 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: compactGrid ? AppSpacing.xs : AppSpacing.xs,
                      ),
                      Text(
                        listing.title,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: compactGrid ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: compactGrid ? AppSpacing.xs : AppSpacing.xs,
                      ),
                      Text(
                        metaLine,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: compactGrid ? AppSpacing.sm : AppSpacing.sm,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: _ConditionBadge(
                              condition: listing.condition,
                              locale: locale,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          MetricChip(
                            icon: Icons.visibility_outlined,
                            value: '${listing.views}',
                            accentColor: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      if (showTrustBadges) _TrustBadgesRow(locale: locale),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onBoost != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onBoost,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(
                MarketplaceStrings.t('mp_boost', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.amberGlow,
                ),
              ),
            ),
          ),
        if (onGetQr != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onGetQr,
              icon: Icon(
                Icons.qr_code_2_outlined,
                size: 16,
                color: AppColors.cyanGlow,
              ),
              label: Text(
                MarketplaceStrings.t('mp_get_qr_listing', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cyanGlow,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static ListingBoostVisual _badgeForListing(MarketplaceListing listing) {
    if (listing.badge == ListingBoostBadge.featured) {
      return ListingBoostVisual.featured;
    }
    if (listing.badge == ListingBoostBadge.hot) {
      return ListingBoostVisual.hot;
    }
    return ListingBoostVisual.none;
  }

  static Color _cardBorderColor(ListingBoostVisual badge) {
    switch (badge) {
      case ListingBoostVisual.featured:
        return AppColors.goldFamilyMain.withValues(alpha: 0.3);
      case ListingBoostVisual.hot:
        return AppColors.error.withValues(alpha: 0.35);
      case ListingBoostVisual.none:
        return AppColors.glassBorder;
    }
  }
}

enum ListingBoostVisual { none, featured, hot }

class _ListingPhotoBlock extends StatelessWidget {
  const _ListingPhotoBlock({
    required this.listing,
    required this.locale,
    required this.badge,
    required this.isSaved,
    required this.onSave,
    required this.compact,
  });

  final MarketplaceListing listing;
  final String locale;
  final ListingBoostVisual badge;
  final bool isSaved;
  final VoidCallback onSave;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final photos = listing.photoUrls;
    final hasPhoto = photos.isNotEmpty;

    return AspectRatio(
      aspectRatio: compact ? 4 / 3 : 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(MarketplaceListingCard._kMediaTopRadius),
            ),
            child: hasPhoto
                ? CachedNetworkImage(
                    imageUrl: photos.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) =>
                        _PhotoPlaceholder(listing: listing),
                    errorWidget: (context, url, error) =>
                        _PhotoPlaceholder(listing: listing),
                  )
                : _PhotoPlaceholder(listing: listing),
          ),
          if (badge != ListingBoostVisual.none)
            Positioned(
              top: 10,
              left: 10,
              child: _BoostStripe(badge: badge, locale: locale),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: _OverlayIconButton(
              icon: isSaved ? Icons.favorite : Icons.favorite_border,
              onPressed: onSave,
              iconColor: isSaved ? AppColors.brandFamilyMain : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.listing});

  final MarketplaceListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceElevated, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          listing.emoji,
          style: TextStyle(fontSize: listing.photoUrls.isEmpty ? 48 : 40),
        ),
      ),
    );
  }
}

class _BoostStripe extends StatelessWidget {
  const _BoostStripe({required this.badge, required this.locale});

  final ListingBoostVisual badge;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final (labelKey, color) = switch (badge) {
      ListingBoostVisual.featured => (
        'mp_featured_badge',
        AppColors.goldFamilyMain,
      ),
      ListingBoostVisual.hot => ('mp_hot_badge', AppColors.error),
      ListingBoostVisual.none => ('', Colors.transparent),
    };
    if (badge == ListingBoostVisual.none) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        MarketplaceStrings.t(labelKey, locale),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
    required this.icon,
    required this.onPressed,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textPrimary.withValues(alpha: 0.42),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.condition, required this.locale});

  final String condition;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = MarketplaceStrings.conditionLabel(condition, locale);
    final lower = condition.toLowerCase();
    final isExcellent =
        lower.contains('excellent') || lower.contains('like new');

    return StatusBadge(
      label: label,
      color: isExcellent ? AppColors.success : AppColors.warning,
    );
  }
}

class _TrustBadgesRow extends StatelessWidget {
  const _TrustBadgesRow({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          StatusBadge(
            label: MarketplaceStrings.t('mp_trust_price_check', locale),
            color: AppColors.info,
          ),
          StatusBadge(
            label: MarketplaceStrings.t('mp_trust_meet_public', locale),
            color: AppColors.tealGlow,
          ),
        ],
      ),
    );
  }
}
