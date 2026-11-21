import 'package:raabta/screens/services/data/service_taxonomy.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Human-readable category (never raw Firestore ids like `home_maintenance`).
String serviceListingCategoryLabel(ServiceListing listing) {
  final id = listing.serviceCategoryId.trim();
  if (id.isNotEmpty) {
    final match = findServiceCategoryById(id);
    if (match != null) return match.name;
  }
  final raw = listing.serviceCategory.trim();
  if (raw.isEmpty) return '';
  final byRawId = findServiceCategoryById(raw);
  if (byRawId != null) return byRawId.name;
  if (raw.contains('_')) {
    return raw
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
  return raw;
}

/// Provider card/detail headline — poster name first (title is the offer line).
String serviceHubProviderHeadline(ServiceListing listing) {
  final name = listing.providerName.trim();
  if (name.isNotEmpty) return name;
  final title = listing.title.trim();
  if (title.isNotEmpty) return title;
  final service = listing.serviceName.trim();
  if (service.isNotEmpty) return service;
  return listing.displayTitle;
}

/// Secondary line under provider headline (listing title when distinct).
String? serviceHubProviderOfferLine(ServiceListing listing) {
  if (listing.isRequest) return null;
  final headline = serviceHubProviderHeadline(listing);
  final title = listing.title.trim();
  if (title.isEmpty) return null;
  if (title.toLowerCase() == headline.toLowerCase()) return null;
  return title;
}
