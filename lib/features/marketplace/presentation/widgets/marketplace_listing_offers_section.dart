import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/marketplace/domain/marketplace_offer.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_offer_strings.dart';
import 'package:raabta/features/marketplace/providers/marketplace_offer_providers.dart';
import 'package:raabta/models/marketplace_models.dart';

class MarketplaceListingOffersSection extends ConsumerWidget {
  const MarketplaceListingOffersSection({
    super.key,
    required this.listing,
    required this.locale,
    required this.isOwner,
    required this.offersEnabled,
  });

  final MarketplaceListing listing;
  final String locale;
  final bool isOwner;
  final bool offersEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(marketplaceListingOffersProvider(listing.id));
    return offersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (offers) {
        if (!offersEnabled) {
          return const SizedBox.shrink();
        }
        if (isOwner) {
          final pending = offers
              .where((o) => o.status == MarketplaceOfferStatus.pending)
              .toList();
          if (pending.isEmpty) return const SizedBox.shrink();
          return _SellerOffersPanel(
            listing: listing,
            offers: pending,
            locale: locale,
          );
        }

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return const SizedBox.shrink();

        final mine = offers.where((o) => o.buyerId == uid).toList();
        if (mine.isEmpty) {
          return _MakeOfferButton(listing: listing, locale: locale);
        }

        final active = mine.firstWhere(
          (o) => o.status.isOpen,
          orElse: () => mine.first,
        );

        if (active.status.isOpen) {
          return _BuyerActiveOfferCard(
            listing: listing,
            offer: active,
            locale: locale,
          );
        }

        return _MakeOfferButton(listing: listing, locale: locale);
      },
    );
  }
}

class _MakeOfferButton extends StatelessWidget {
  const _MakeOfferButton({required this.listing, required this.locale});

  final MarketplaceListing listing;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          onTap: () => _openMakeOffer(context),
          child: Text(
            MarketplaceOfferStrings.t('mp_make_offer', locale),
            style: AppTypography.button.copyWith(color: AppColors.cyanGlow),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  void _openMakeOffer(BuildContext context) {
    final hint = _parsePrice(listing.price);
    context.push(
      '/marketplace/listing/${listing.id}/offer',
      extra: {
        'sellerId': listing.ownerUserId ?? '',
        'title': listing.title,
        'priceHint': hint,
      },
    );
  }

  double? _parsePrice(String raw) {
    final match = RegExp(r'[\d,]+').firstMatch(raw);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', ''));
  }
}

class _SellerOffersPanel extends ConsumerWidget {
  const _SellerOffersPanel({
    required this.listing,
    required this.offers,
    required this.locale,
  });

  final MarketplaceListing listing;
  final List<MarketplaceOffer> offers;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MarketplaceOfferStrings.format(
            'mp_seller_offers_count',
            locale,
            params: {'count': '${offers.length}'},
          ),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final offer in offers)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MarketplaceOfferStrings.format(
                      'mp_offer_line',
                      locale,
                      params: {'amount': offer.offeredPrice.toStringAsFixed(0)},
                    ),
                    style: AppTypography.title.copyWith(
                      color: AppColors.cyanGlow,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    MarketplaceOfferStrings.t(
                      'mp_offer_status_pending',
                      locale,
                    ),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      _actionChip(
                        context,
                        MarketplaceOfferStrings.t(
                          'mp_offer_action_accept',
                          locale,
                        ),
                        () => _accept(ref, offer),
                      ),
                      _actionChip(
                        context,
                        MarketplaceOfferStrings.t(
                          'mp_offer_action_decline',
                          locale,
                        ),
                        () => _decline(ref, offer),
                      ),
                      _actionChip(
                        context,
                        MarketplaceOfferStrings.t(
                          'mp_offer_action_counter',
                          locale,
                        ),
                        () => _counter(context, ref, offer),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _actionChip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }

  Future<void> _accept(WidgetRef ref, MarketplaceOffer offer) async {
    await ref
        .read(marketplaceOfferRepositoryProvider)
        .sellerAccept(
          offer: offer,
          listingTitle: listing.title,
          locale: locale,
        );
  }

  Future<void> _decline(WidgetRef ref, MarketplaceOffer offer) async {
    await ref
        .read(marketplaceOfferRepositoryProvider)
        .sellerDecline(
          offer: offer,
          listingTitle: listing.title,
          locale: locale,
        );
  }

  Future<void> _counter(
    BuildContext context,
    WidgetRef ref,
    MarketplaceOffer offer,
  ) async {
    final amount = await _promptCounterAmount(context);
    if (amount == null) return;
    await ref
        .read(marketplaceOfferRepositoryProvider)
        .sellerCounter(
          offer: offer,
          counterPrice: amount,
          listingTitle: listing.title,
          locale: locale,
        );
  }

  Future<double?> _promptCounterAmount(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          MarketplaceOfferStrings.t('mp_offer_counter_title', locale),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '0'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: Text(MarketplaceOfferStrings.t('mp_offer_submit', locale)),
          ),
        ],
      ),
    );
    controller.dispose();
    return result != null && result > 0 ? result : null;
  }
}

class _BuyerActiveOfferCard extends ConsumerWidget {
  const _BuyerActiveOfferCard({
    required this.listing,
    required this.offer,
    required this.locale,
  });

  final MarketplaceListing listing;
  final MarketplaceOffer offer;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusKey = offer.status == MarketplaceOfferStatus.awaitingBuyer
        ? 'mp_offer_status_counter_received'
        : 'mp_offer_status_yours_pending';

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MarketplaceOfferStrings.format(
                  'mp_offer_line',
                  locale,
                  params: {'amount': offer.offeredPrice.toStringAsFixed(0)},
                ),
                style: AppTypography.title.copyWith(color: AppColors.cyanGlow),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                MarketplaceOfferStrings.t(statusKey, locale),
                style: AppTypography.caption,
              ),
              if (offer.status == MarketplaceOfferStatus.awaitingBuyer) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ActionChip(
                      label: Text(
                        MarketplaceOfferStrings.t(
                          'mp_offer_action_accept',
                          locale,
                        ),
                      ),
                      onPressed: () => ref
                          .read(marketplaceOfferRepositoryProvider)
                          .buyerAcceptCounter(
                            offer: offer,
                            listingTitle: listing.title,
                            locale: locale,
                          ),
                    ),
                    ActionChip(
                      label: Text(
                        MarketplaceOfferStrings.t(
                          'mp_offer_action_decline',
                          locale,
                        ),
                      ),
                      onPressed: () => ref
                          .read(marketplaceOfferRepositoryProvider)
                          .buyerDeclineCounter(
                            offer: offer,
                            listingTitle: listing.title,
                            locale: locale,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
