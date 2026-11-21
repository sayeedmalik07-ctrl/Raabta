import 'package:raabta/data/models/business_listing.dart';

/// Profile completeness for the signed-in user's business listing (presentation only).
int businessListingCompletenessPercent(BusinessListing business) {
  var filled = 0;
  const total = 9;

  if (business.logoUrl?.trim().isNotEmpty ?? false) filled++;
  if (business.coverUrl?.trim().isNotEmpty ?? false) filled++;
  if (business.description?.trim().isNotEmpty ?? false) filled++;
  if (business.servicesOffered.isNotEmpty) filled++;
  if (business.openingHours != null && business.openingHours!.isNotEmpty) {
    filled++;
  }
  if (business.website?.trim().isNotEmpty ?? false) filled++;
  if (business.phone.trim().isNotEmpty) filled++;
  if (business.socialLinks.isNotEmpty) filled++;
  if (business.location.trim().isNotEmpty) filled++;

  return ((filled / total) * 100).round().clamp(0, 100);
}
