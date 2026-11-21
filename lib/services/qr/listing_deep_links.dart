import 'package:raabta/config/app_config.dart';

/// Shareable listing URLs — same pattern as housing `shareUrl`.
class ListingDeepLinks {
  ListingDeepLinks._();

  static String marketplaceListing(String listingId) =>
      '${AppConfig.publicWebsiteUrl}/marketplace/listing/$listingId';

  static String businessListing(String businessId) =>
      '${AppConfig.publicWebsiteUrl}/businesses/$businessId';

  static String jobListing(String jobId) =>
      '${AppConfig.publicWebsiteUrl}/jobs/listing/$jobId';
}
