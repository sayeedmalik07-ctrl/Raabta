import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/widgets/hub/hub_detail_action_bar.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_offer_strings.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/models/marketplace_models.dart';

/// Bottom inset for content above the sticky [HubDetailActionBar] on marketplace detail.
double marketplaceDetailActionBarScrollInset(BuildContext context) {
  const barHeight = 48.0;
  const verticalPadding = AppSpacing.md * 2;
  return barHeight + verticalPadding + MediaQuery.paddingOf(context).bottom;
}

class MarketplaceListingDetailActionBar extends StatelessWidget {
  const MarketplaceListingDetailActionBar({
    super.key,
    required this.listing,
    required this.locale,
    required this.isOwner,
    required this.isSaved,
    required this.offersEnabled,
    required this.onSave,
    required this.onShare,
    required this.onContact,
  });

  final MarketplaceListing listing;
  final String locale;
  final bool isOwner;
  final bool isSaved;
  final bool offersEnabled;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onContact;

  static const barKey = Key('marketplace_detail_action_bar');

  double? _parsePriceHint(String raw) {
    final match = RegExp(r'[\d,]+').firstMatch(raw);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', ''));
  }

  void _openMakeOffer(BuildContext context) {
    final hint = _parsePriceHint(listing.price);
    context.push(
      '/marketplace/listing/${listing.id}/offer',
      extra: {
        'sellerId': listing.ownerUserId ?? '',
        'title': listing.title,
        'priceHint': hint,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final saveTooltip = isSaved
        ? CommonActionStrings.t('action_saved', locale)
        : CommonActionStrings.t('action_save', locale);
    final shareTooltip = CommonActionStrings.t('action_share', locale);

    if (isOwner) {
      return KeyedSubtree(
        key: barKey,
        child: HubDetailActionBar(
          isSaved: isSaved,
          onSave: onSave,
          onShare: onShare,
          saveTooltip: saveTooltip,
          shareTooltip: shareTooltip,
          backgroundColor: AppColors.surface,
        ),
      );
    }

    final contactLabel = MarketplaceStrings.t('mp_contact_seller', locale);
    final offerLabel = MarketplaceOfferStrings.t('mp_make_offer', locale);

    return KeyedSubtree(
      key: barKey,
      child: HubDetailActionBar(
        primaryLabel: contactLabel,
        onPrimary: () {
          PostEngine().analytics.trackEnquiry(
            listingId: listing.id,
            verticalId: 'marketplace',
          );
          onContact();
        },
        secondaryLabel: offersEnabled ? offerLabel : null,
        onSecondary: offersEnabled ? () => _openMakeOffer(context) : null,
        isSaved: isSaved,
        onSave: onSave,
        onShare: onShare,
        saveTooltip: saveTooltip,
        shareTooltip: shareTooltip,
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
