import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/hub/hub_service_card.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/utils/service_listing_display_helpers.dart';

/// Maps [ServiceListing] to kit [HubServiceCard] (presentation only).
class ServiceHubListingCard extends StatelessWidget {
  const ServiceHubListingCard({
    super.key,
    required this.listing,
    required this.locale,
    required this.onTap,
  });

  final ServiceListing listing;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (listing.isRequest) {
      return HubServiceCard.request(
        key: Key('services_hub_card_${listing.id}'),
        requestTitle: serviceHubRequestTitle(listing, locale),
        areaLine: listing.area.trim().isEmpty ? null : listing.area.trim(),
        postedLine: serviceHubPostedLine(listing.createdAt, locale),
        showOpenRequestBadge: listing.acceptsQuotes,
        openRequestBadgeLabel: listing.acceptsQuotes
            ? ServicesStrings.t('hub_open_request_badge', locale)
            : null,
        onTap: onTap,
      );
    }

    return HubServiceCard.provider(
      key: Key('services_hub_card_${listing.id}'),
      providerName: serviceHubProviderHeadline(listing),
      serviceTypeLine: serviceHubServiceTypeLine(listing),
      rateLine: serviceHubRateLine(listing, locale),
      avatarUrl: listing.imageUrl,
      avatarInitial: _avatarInitial(listing),
      trustBadges: serviceHubTrustBadges(listing, locale),
      onTap: onTap,
    );
  }

  static String? _avatarInitial(ServiceListing listing) {
    final name = listing.providerName.trim();
    if (name.isNotEmpty) return name;
    return serviceHubProviderHeadline(listing);
  }
}

String serviceHubServiceTypeLine(ServiceListing listing) {
  final parts = <String>[];
  final headline = listing.isRequest
      ? listing.displayTitle
      : serviceHubProviderHeadline(listing);
  final offer = serviceHubProviderOfferLine(listing);
  if (offer != null) {
    parts.add(offer);
  }
  final service = listing.serviceName.trim();
  if (service.isNotEmpty &&
      service.toLowerCase() != headline.toLowerCase() &&
      (offer == null || service.toLowerCase() != offer.toLowerCase())) {
    parts.add(service);
  }
  final category = serviceListingCategoryLabel(listing);
  if (category.isNotEmpty) parts.add(category);
  if (parts.isNotEmpty) return parts.join(' · ');
  return listing.displayTitle;
}

String serviceHubRequestTitle(ServiceListing listing, String locale) {
  final raw = listing.displayTitle;
  final needsPrefix = ServicesStrings.t('hub_needs_prefix', locale);
  if (raw.toLowerCase().startsWith(needsPrefix.toLowerCase())) return raw;
  return '$needsPrefix $raw';
}

String serviceHubPostedLine(DateTime createdAt, String locale) {
  final now = DateTime.now();
  final diff = now.difference(createdAt);
  if (diff.inDays >= 1) {
    return ServicesStrings.format(
      'hub_posted_days_ago',
      locale,
      params: {'count': '${diff.inDays}'},
    );
  }
  if (diff.inHours >= 1) {
    return ServicesStrings.format(
      'hub_posted_hours_ago',
      locale,
      params: {'count': '${diff.inHours}'},
    );
  }
  return ServicesStrings.t('hub_posted_just_now', locale);
}

String? serviceHubRateLine(ServiceListing listing, String locale) {
  for (final entry in listing.schemaFields.entries) {
    final key = entry.key.toLowerCase();
    if (!_rateFieldKey(key)) continue;
    final value = entry.value;
    if (value is num && value.isFinite && value > 0) {
      return ServicesStrings.format(
        'hub_rate_from',
        locale,
        params: {'amount': value.toStringAsFixed(0)},
      );
    }
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) {
      if (text.toLowerCase().startsWith('qar') ||
          text.toLowerCase().startsWith('from')) {
        return text;
      }
      return ServicesStrings.format(
        'hub_rate_from',
        locale,
        params: {'amount': text},
      );
    }
  }
  return null;
}

bool _rateFieldKey(String key) {
  return key.contains('rate') ||
      key.contains('price') ||
      key.contains('budget') ||
      key.contains('fee') ||
      key.contains('cost');
}

List<HubServiceTrustBadge> serviceHubTrustBadges(
  ServiceListing listing,
  String locale,
) {
  final badges = <HubServiceTrustBadge>[];
  if (listing.posterIdentityVerified) {
    badges.add(
      HubServiceTrustBadge(
        label: ServicesStrings.t('provider_identity_verified', locale),
        tone: HubServiceTrustBadgeTone.verified,
      ),
    );
  }
  return badges;
}
