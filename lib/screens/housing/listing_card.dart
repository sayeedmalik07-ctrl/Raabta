import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/housing_detail_screen.dart';
import 'package:raabta/widgets/housing/scam_safety_badge.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum ListingBadgeType { featured, premium, urgent, top, none }

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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HousingDetailScreen(listingId: listingId),
      ),
    );
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
    bool compact = false,
  }) {
    return TextButton(
      onPressed: () => openDetail(context, listingId),
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 6 : 8,
        ),
        minimumSize: Size(compact ? 0 : 64, compact ? 32 : 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text('View', style: TextStyle(fontSize: compact ? 11 : 13)),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final message = Uri.encodeComponent(
      'Hi, I saw your listing "${listing.title}" on Raabta. Is it still available?',
    );
    final uri = Uri.parse('https://wa.me/${listing.whatsapp}?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
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
    final savedIds = ref.watch(savedListingIdsProvider);
    final isSaved = savedIds.contains(listing.id);
    final badge = badgeTypeForListing(listing, listIndex);

    return GestureDetector(
      onTap: () => openDetail(context, listing.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: badge == ListingBadgeType.top
                ? AppColors.primary.withValues(alpha: 0.5)
                : listing.featured
                    ? AppColors.gold.withValues(alpha: 0.3)
                    : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PhotoCarousel(
              listing: listing,
              badge: badge,
              isSaved: isSaved,
              onSave: () => ref
                  .read(savedListingIdsProvider.notifier)
                  .toggle(listing.id),
              onShare: _shareListing,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: AppTextStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '📍 ${listing.area}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    listing.priceLabel,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _TagChip(label: listing.furnishedLabel),
                      _TagChip(label: '🛏️ ${listing.bedrooms}'),
                      _TagChip(label: '🚿 ${listing.bathrooms}'),
                      _TagChip(label: listing.typeLabel),
                      if (listing.amenities.contains('WiFi'))
                        const _TagChip(label: '📶 WiFi'),
                      if (listing.amenities.contains('AC'))
                        const _TagChip(label: '❄️ AC'),
                    ],
                  ),
                  if (listing.scamVerdict != null ||
                      listing.scamScore != null ||
                      listing.scamFlagged ||
                      listing.verified) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (listing.verified)
                          const _StatusBadge(
                            label: 'VERIFIED',
                            color: AppColors.success,
                            icon: '✓',
                          ),
                        ScamSafetyBadge(
                          listing: listing,
                          compact: true,
                          showFlags: listing.scamVerdict ==
                              ScamVerdict.suspicious,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${listing.postedLabel} · ${listing.posterNationalityFlag}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      _WhatsAppButton(
                        listing: listing,
                        onPressed: () => _openWhatsApp(context),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      buildViewButton(context, listing.id),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonetizationBadge extends StatelessWidget {
  const MonetizationBadge({super.key, required this.type});

  final ListingBadgeType type;

  @override
  Widget build(BuildContext context) {
    if (type == ListingBadgeType.none) return const SizedBox.shrink();

    final (label, color, bg) = switch (type) {
      ListingBadgeType.featured => (
          '⭐ FEATURED',
          AppColors.gold,
          AppColors.gold.withValues(alpha: 0.2),
        ),
      ListingBadgeType.premium => (
          '💎 PREMIUM',
          AppColors.secondary,
          AppColors.secondary.withValues(alpha: 0.2),
        ),
      ListingBadgeType.urgent => (
          '🔥 URGENT',
          AppColors.error,
          AppColors.error.withValues(alpha: 0.2),
        ),
      ListingBadgeType.top => (
          '🏆 TOP',
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.15),
        ),
      ListingBadgeType.none => ('', Colors.transparent, Colors.transparent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: type == ListingBadgeType.top
            ? Border.all(color: AppColors.primary)
            : null,
      ),
      child: Text(
        label,
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
    required this.onSave,
    required this.onShare,
  });

  final HousingListing listing;
  final ListingBadgeType badge;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;

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

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: photos[index],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A2535), Color(0xFF0D1520)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceElevated,
                  child: const Icon(Icons.home, color: Colors.white54, size: 48),
                ),
              );
            },
          ),
          if (widget.badge != ListingBadgeType.none)
            Positioned(
              top: 10,
              left: 10,
              child: MonetizationBadge(type: widget.badge),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                _OverlayIconButton(
                  icon: widget.isSaved ? Icons.favorite : Icons.favorite_border,
                  onPressed: widget.onSave,
                ),
                const SizedBox(height: 4),
                _OverlayIconButton(
                  icon: Icons.share_outlined,
                  onPressed: widget.onShare,
                ),
              ],
            ),
          ),
          if (photos.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
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

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton({
    required this.listing,
    this.compact = false,
    this.onPressed,
  });

  final HousingListing listing;
  final bool compact;
  final VoidCallback? onPressed;

  Future<void> _defaultLaunch(BuildContext context) async {
    final message = Uri.encodeComponent(
      'Hi, I saw your listing "${listing.title}" on Raabta. Is it still available?',
    );
    final uri = Uri.parse('https://wa.me/${listing.whatsapp}?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 32 : 36,
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () => _defaultLaunch(context),
        icon: Icon(Icons.chat, size: compact ? 14 : 18),
        label: Text('WhatsApp', style: TextStyle(fontSize: compact ? 11 : 13)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '$icon $label',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.surfaceElevated),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}
