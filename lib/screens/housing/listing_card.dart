import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';
import 'package:raabta/widgets/housing/scam_safety_badge.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum ListingBadgeType { featured, premium, urgent, top, none }

/// Hub kit ListingCard outer radius (~22px).
const _kListingCardRadius = 22.0;

/// Hub kit media top corner radius.
const _kMediaTopRadius = AppRadius.xl;

// Legacy design palette values preserved for dark mode.
const _legacyDarkSurface = Color(0xFF0D1520);
const _legacyDarkBackground = Color(0xFF050A0F);
const _legacyDarkSurfaceElevated = Color(0xFF111D2C);
const _legacyDarkBorder = Color(0x1AFFFFFF);
const _legacyPrimary = Color(0xFF22D3EE);
const _legacySecondary = Color(0xFF6366F1);
const _legacyGold = Color(0xFFFFB800);
const _legacySuccess = Color(0xFF34D399);
const _legacyError = Color(0xFFF87171);

Color _listingPrimary() => AppColors.brandFamilyMain;

Color _listingSecondary() =>
    AppColors.isLight ? AppColors.brandFamilyMain : AppColors.brandFamilyDark;

Color _listingGold() => AppColors.goldFamilyMain;

Color _listingSurface() =>
    AppColors.isLight ? AppColors.glassSurface : _legacyDarkSurface;

Color _listingCardBorder({
  required ListingBadgeType badge,
  required bool featured,
}) {
  if (badge == ListingBadgeType.top) {
    return _listingPrimary().withValues(alpha: 0.5);
  }
  if (featured) {
    return _listingGold().withValues(alpha: 0.3);
  }
  return AppColors.isLight ? AppColors.glassBorder : _legacyDarkBorder;
}

ListingBadgeType badgeTypeForListing(HousingListing listing, int index) {
  if (listing.featured) return ListingBadgeType.featured;
  if (listing.daysAgo <= 1) return ListingBadgeType.urgent;
  if (listing.verified && index % 4 == 2) return ListingBadgeType.premium;
  if (listing.verified && listing.pricePerMonth >= 3000 && index % 3 == 0) {
    return ListingBadgeType.top;
  }
  if (index % 5 == 3) return ListingBadgeType.premium;
  return ListingBadgeType.none;
}

List<String> _listingAttributeLabels(HousingListing listing, String locale) {
  final labels = <String>[
    HousingStrings.furnishedLabel(listing.furnished, locale),
    HousingStrings.format(
      'tag_bed',
      locale,
      params: {'count': '${listing.bedrooms}'},
    ),
    HousingStrings.format(
      'tag_bath',
      locale,
      params: {'count': '${listing.bathrooms}'},
    ),
    HousingStrings.listingTypeLabel(listing.type, locale),
    if (listing.amenities.contains('WiFi')) '📶 WiFi',
    if (listing.amenities.contains('AC')) '❄️ AC',
  ];
  return labels.take(4).toList();
}

class ListingCard extends ConsumerWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.listIndex = 0,
    this.isSponsored = false,
  });

  final HousingListing listing;
  final int listIndex;
  final bool isSponsored;

  static void openDetail(BuildContext context, String listingId) {
    context.push('/housing/listing/$listingId');
  }

  static Widget buildWhatsAppButton(
    HousingListing listing, {
    bool compact = false,
  }) {
    return _WhatsAppButton(listing: listing, compact: compact);
  }

  static Widget buildViewButton(
    BuildContext context,
    String listingId, {
    required String locale,
    bool compact = false,
  }) {
    return TextButton(
      onPressed: () => openDetail(context, listingId),
      style: TextButton.styleFrom(
        backgroundColor: _listingPrimary().withValues(alpha: 0.15),
        foregroundColor: _listingPrimary(),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 6 : 8,
        ),
        minimumSize: Size(compact ? 0 : 64, compact ? 32 : 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        HousingStrings.t('action_view', locale),
        style: TextStyle(fontSize: compact ? 11 : 13),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String locale) async {
    final message = Uri.encodeComponent(
      'Hi, I saw your listing "${listing.title}" on Raabta. Is it still available?',
    );
    final uri = Uri.parse('https://wa.me/${listing.whatsapp}?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            CommonActionStrings.t('error_whatsapp_unavailable', locale),
          ),
        ),
      );
    }
  }

  void _shareListing() {
    Share.share(
      'Check out ${listing.title} on Raabta: ${listing.shareLink}',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final savedIds = ref.watch(savedListingIdsProvider);
    final isSaved = savedIds.contains(listing.id);
    final badge = badgeTypeForListing(listing, listIndex);

    final metaLine =
        '${listing.area} · ${HousingStrings.postedLabel(listing.daysAgo, locale)} · ${listing.posterNationalityFlag}';
    final attributeLabels = _listingAttributeLabels(listing, locale);
    final trustWidgets = _listingTrustBadges(
      listing: listing,
      locale: locale,
    );

    return GestureDetector(
      onTap: () => openDetail(context, listing.id),
      child: Container(
        decoration: BoxDecoration(
          color: _listingSurface(),
          borderRadius: BorderRadius.circular(_kListingCardRadius),
          border: Border.all(
            color: _listingCardBorder(
              badge: badge,
              featured: listing.featured,
            ),
          ),
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
            _PhotoCarousel(
              listing: listing,
              badge: badge,
              isSaved: isSaved,
              locale: locale,
              onSave: () => ref
                  .read(savedListingIdsProvider.notifier)
                  .toggle(listing.id),
              onShare: _shareListing,
              onWhatsApp: () => _openWhatsApp(context, locale),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.priceLabel,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: _listingPrimary(),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    listing.title,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    metaLine,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attributeLabels.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final label in attributeLabels)
                          _TagChip(label: label),
                      ],
                    ),
                  ],
                  if (trustWidgets.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: trustWidgets,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _listingTrustBadges({
  required HousingListing listing,
  required String locale,
}) {
  if (listing.scamVerdict == null &&
      listing.scamScore == null &&
      !listing.scamFlagged &&
      !listing.verified) {
    return const [];
  }
  final badges = <Widget>[
    if (listing.verified)
      _StatusBadge(
        label: HousingStrings.t('status_verified', locale),
        color: AppColors.success,
        icon: '✓',
      ),
    ScamSafetyBadge(
      listing: listing,
      locale: locale,
      compact: true,
      showFlags: listing.scamVerdict == ScamVerdict.suspicious,
    ),
  ];
  return badges.take(3).toList();
}

class MonetizationBadge extends StatelessWidget {
  const MonetizationBadge({
    super.key,
    required this.type,
    required this.locale,
  });

  final ListingBadgeType type;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (type == ListingBadgeType.none) return const SizedBox.shrink();

    final (labelKey, color, bg) = switch (type) {
      ListingBadgeType.featured => (
          'badge_featured',
          _listingGold(),
          _listingGold().withValues(alpha: 0.2),
        ),
      ListingBadgeType.premium => (
          'badge_premium',
          _listingSecondary(),
          _listingSecondary().withValues(alpha: 0.2),
        ),
      ListingBadgeType.urgent => (
          'badge_urgent',
          AppColors.isLight ? AppColors.error : _legacyError,
          (AppColors.isLight ? AppColors.error : _legacyError)
              .withValues(alpha: 0.2),
        ),
      ListingBadgeType.top => (
          'badge_top',
          _listingPrimary(),
          _listingPrimary().withValues(alpha: 0.15),
        ),
      ListingBadgeType.none => ('', Colors.transparent, Colors.transparent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: type == ListingBadgeType.top
            ? Border.all(color: _listingPrimary())
            : null,
      ),
      child: Text(
        HousingStrings.t(labelKey, locale),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({
    required this.listing,
    required this.badge,
    required this.isSaved,
    required this.locale,
    required this.onSave,
    required this.onShare,
    required this.onWhatsApp,
  });

  final HousingListing listing;
  final ListingBadgeType badge;
  final bool isSaved;
  final String locale;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onWhatsApp;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.listing.photoUrls.isEmpty
        ? ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800']
        : widget.listing.photoUrls;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_kMediaTopRadius),
            ),
            child: PageView.builder(
              controller: _controller,
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: photos[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.isLight
                            ? [AppColors.surfaceElevated, AppColors.surface]
                            : [
                                _legacyDarkSurfaceElevated,
                                _legacyDarkSurface,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.isLight
                            ? [AppColors.surfaceElevated, AppColors.surface]
                            : [
                                _legacyDarkSurfaceElevated,
                                _legacyDarkSurface,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.home_outlined,
                      color: AppColors.isLight
                          ? AppColors.textTertiary
                          : Colors.white54,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.badge != ListingBadgeType.none)
            Positioned(
              top: 10,
              left: 10,
              child: MonetizationBadge(
                type: widget.badge,
                locale: widget.locale,
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                _OverlayIconButton(
                  icon: widget.isSaved
                      ? Icons.favorite
                      : Icons.favorite_border,
                  onPressed: widget.onSave,
                ),
                const SizedBox(height: 4),
                _OverlayIconButton(
                  icon: Icons.share_outlined,
                  onPressed: widget.onShare,
                ),
                const SizedBox(height: 4),
                _OverlayWhatsAppButton(onPressed: widget.onWhatsApp),
              ],
            ),
          ),
          if (photos.length > 1)
            Positioned(
              bottom: 10,
              left: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '${_index + 1} of ${photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _OverlayWhatsAppButton extends StatelessWidget {
  const _OverlayWhatsAppButton({required this.onPressed});

  final VoidCallback onPressed;

  static const _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _whatsappGreen,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.chat, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _WhatsAppButton extends ConsumerWidget {
  const _WhatsAppButton({
    required this.listing,
    this.compact = false,
    this.onPressed,
  });

  final HousingListing listing;
  final bool compact;
  final VoidCallback? onPressed;

  Future<void> _defaultLaunch(BuildContext context, String locale) async {
    final message = Uri.encodeComponent(
      'Hi, I saw your listing "${listing.title}" on Raabta. Is it still available?',
    );
    final uri = Uri.parse('https://wa.me/${listing.whatsapp}?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            CommonActionStrings.t('error_whatsapp_unavailable', locale),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    return SizedBox(
      height: compact ? 32 : 36,
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () => _defaultLaunch(context, locale),
        icon: Icon(Icons.chat, size: compact ? 14 : 18),
        label: Text(
          CommonActionStrings.t('action_whatsapp', locale),
          style: TextStyle(fontSize: compact ? 11 : 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$icon $label',
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.isLight ? AppColors.background : _legacyDarkBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.isLight
              ? AppColors.glassBorder
              : _legacyDarkSurfaceElevated,
        ),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}
