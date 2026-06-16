import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/housing_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingCard extends ConsumerWidget {
  const ListingCard({
    super.key,
    required this.listing,
  });

  final HousingListing listing;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _verifiedGreen = Color(0xFF22C55E);
  static const Color _scamRed = Color(0xFFEF4444);
  static const Color _whatsappGreen = Color(0xFF25D366);

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedListingIdsProvider);
    final isSaved = savedIds.contains(listing.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HousingDetailScreen(listingId: listing.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: listing.featured
              ? Border.all(color: _cyanColor.withValues(alpha: 0.4))
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PhotoCarousel(photoUrls: listing.photoUrls),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (listing.featured)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _cyanColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '⭐ FEATURED',
                                    style: TextStyle(
                                      color: _cyanColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            Text(
                              listing.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '📍 ${listing.area}',
                              style: const TextStyle(
                                color: _subtitleColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              listing.priceLabel,
                              style: const TextStyle(
                                color: _cyanColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => ref
                                .read(savedListingIdsProvider.notifier)
                                .toggle(listing.id),
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? _cyanColor : _subtitleColor,
                            ),
                          ),
                          if (listing.verified)
                            _Badge(
                              label: 'VERIFIED',
                              color: _verifiedGreen,
                              icon: '✓',
                            )
                          else if (listing.scamFlagged)
                            _Badge(
                              label: 'POSSIBLE SCAM',
                              color: _scamRed,
                              icon: '⚠️',
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TagChip(label: listing.furnishedLabel),
                      _TagChip(label: '${listing.bedrooms} Bed'),
                      _TagChip(label: '${listing.bathrooms} Bath'),
                      _TagChip(label: listing.typeLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${listing.postedLabel} · ${listing.posterNationalityFlag}',
                        style: const TextStyle(
                          color: _subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () => _openWhatsApp(context),
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _whatsappGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
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

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.photoUrls});

  final List<String> photoUrls;

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
    final photos = widget.photoUrls.isEmpty
        ? ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800']
        : widget.photoUrls;

    return SizedBox(
      height: 180,
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
                  color: const Color(0xFF1A2535),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF1A2535),
                  child: const Icon(Icons.home, color: Colors.white54, size: 48),
                ),
              );
            },
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

class _Badge extends StatelessWidget {
  const _Badge({
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
        borderRadius: BorderRadius.circular(6),
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
        color: const Color(0xFF050A0F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A2535)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8A9BB0),
          fontSize: 12,
        ),
      ),
    );
  }
}
