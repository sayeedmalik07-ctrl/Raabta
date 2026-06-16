import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/area_map_preview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HousingDetailScreen extends ConsumerWidget {
  const HousingDetailScreen({
    super.key,
    required this.listingId,
    this.initialListing,
  });

  final String listingId;
  final HousingListing? initialListing;

  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _scamRed = Color(0xFFEF4444);

  Future<void> _openWhatsApp(HousingListing listing) async {
    final message = Uri.encodeComponent(
      'Hi ${listing.contactName}, I saw your listing "${listing.title}" on Raabta. Is it still available?',
    );
    final uri = Uri.parse('https://wa.me/${listing.whatsapp}?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call(HousingListing listing) async {
    final uri = Uri.parse('tel:${listing.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _share(HousingListing listing) async {
    await Share.share(
      'Check out this listing on Raabta: ${listing.title} in ${listing.area} — ${listing.priceLabel}\n${listing.shareLink}',
    );
  }

  Future<void> _showReportForm(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final detailsController = TextEditingController();
    final contactController = TextEditingController();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Listing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Reason (e.g. Possible scam)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Details'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Your contact (optional)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: _scamRed,
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (submitted != true || !context.mounted) return;

    try {
      await ref.read(housingRepositoryProvider).reportListing(
            listingId,
            ListingReport(
              reason: reasonController.text.trim().isEmpty
                  ? 'Suspicious listing'
                  : reasonController.text.trim(),
              details: detailsController.text.trim(),
              reporterContact: contactController.text.trim(),
            ),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. Our team will review it.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report saved. Connect to server to sync.')),
      );
    }
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _subtitleColor),
      filled: true,
      fillColor: _backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialListing != null) {
      return _DetailBody(
        listing: initialListing!,
        onWhatsApp: () => _openWhatsApp(initialListing!),
        onCall: () => _call(initialListing!),
        onShare: () => _share(initialListing!),
        onReport: () => _showReportForm(context, ref),
        ref: ref,
      );
    }

    final listingAsync = ref.watch(housingListingDetailProvider(listingId));

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: listingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _cyanColor),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: _subtitleColor, size: 48),
              const SizedBox(height: 12),
              Text(error.toString(), style: const TextStyle(color: _subtitleColor)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.invalidate(housingListingDetailProvider(listingId)),
                child: const Text('Retry', style: TextStyle(color: _cyanColor)),
              ),
            ],
          ),
        ),
        data: (listing) {
          if (listing == null) {
            return const Center(
              child: Text(
                'Listing not found',
                style: TextStyle(color: _subtitleColor),
              ),
            );
          }

          return _DetailBody(
            listing: listing,
            onWhatsApp: () => _openWhatsApp(listing),
            onCall: () => _call(listing),
            onShare: () => _share(listing),
            onReport: () => _showReportForm(context, ref),
            ref: ref,
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.listing,
    required this.onWhatsApp,
    required this.onCall,
    required this.onShare,
    required this.onReport,
    required this.ref,
  });

  final HousingListing listing;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback onShare;
  final VoidCallback onReport;
  final WidgetRef ref;

  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _verifiedGreen = Color(0xFF22C55E);
  static const Color _scamRed = Color(0xFFEF4444);
  static const Color _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    final savedIds = ref.watch(savedListingIdsProvider);
    final isSaved = savedIds.contains(listing.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: _backgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  ref.read(savedListingIdsProvider.notifier).toggle(listing.id),
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? _cyanColor : Colors.white,
              ),
            ),
            IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.share, color: Colors.white),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: listing.photoUrls.isEmpty
                ? Container(color: _surfaceColor)
                : PageView.builder(
                    itemCount: listing.photoUrls.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: listing.photoUrls[index],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const ColoredBox(color: _surfaceColor),
                      );
                    },
                  ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  if (listing.verified)
                    _StatusBadge(
                      label: 'VERIFIED',
                      color: _verifiedGreen,
                      icon: '✓',
                    ),
                  if (listing.scamFlagged) ...[
                    const SizedBox(width: 8),
                    _StatusBadge(
                      label: 'POSSIBLE SCAM',
                      color: _scamRed,
                      icon: '⚠️',
                    ),
                  ],
                  if (listing.status == ListingStatus.pending) ...[
                    const SizedBox(width: 8),
                    _StatusBadge(
                      label: 'PENDING',
                      color: Colors.orange,
                      icon: '⏳',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                listing.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '📍 ${listing.area} · ${listing.postedLabel} · ${listing.posterNationalityFlag}',
                style: const TextStyle(color: _subtitleColor, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                listing.priceLabel,
                style: const TextStyle(
                  color: _cyanColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: listing.furnishedLabel),
                  _Tag(label: '${listing.bedrooms} Bed'),
                  _Tag(label: '${listing.bathrooms} Bath'),
                  _Tag(label: listing.typeLabel),
                  _Tag(label: genderLabel(listing.genderPreference)),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                listing.description,
                style: const TextStyle(color: _subtitleColor, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Text(
                'Amenities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: listing.amenities
                    .map(
                      (a) => Chip(
                        label: Text(a),
                        backgroundColor: _surfaceColor,
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        side: const BorderSide(color: Color(0xFF1A2535)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Area Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              AreaMapPreview(
                area: listing.area,
                latitude: listing.latitude,
                longitude: listing.longitude,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onWhatsApp,
                      icon: const Icon(Icons.chat),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _whatsappGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('In-app messaging coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _cyanColor,
                        side: BorderSide(color: _cyanColor.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1A2535)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onReport,
                icon: const Icon(Icons.flag_outlined, color: _scamRed),
                label: const Text(
                  'Report Listing',
                  style: TextStyle(color: _scamRed),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$icon $label',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF050A0F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A2535)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF8A9BB0), fontSize: 12)),
    );
  }
}
