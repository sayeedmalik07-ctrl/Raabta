import 'package:raabta/data/models/business_listing.dart';

/// Draft and publish helpers for optional job → business linkage.
abstract final class JobPostBusinessLink {
  static const linkedBusinessIdDraftKey = 'linkedBusinessId';
  static const linkedBusinessNameDraftKey = 'linkedBusinessName';
  static const linkedBusinessNamePreviewKey = 'linkedBusinessName';

  static String? readLinkedBusinessId(Map<String, dynamic> draft) {
    final raw = draft[linkedBusinessIdDraftKey]?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static String? readLinkedBusinessName(Map<String, dynamic> draft) {
    final raw = draft[linkedBusinessNameDraftKey]?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static String employerIdentityStatusLabel(BusinessListing business) {
    return business.employerIdentityVerification?.status.storageValue ??
        'none';
  }
}
