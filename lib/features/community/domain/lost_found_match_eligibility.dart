import 'package:raabta/features/community/domain/lost_found_area.dart';
import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/domain/lost_found_match_policy.dart';

/// Normalized listing slice used for eligibility + scoring (public fields only).
class LostFoundMatchListing {
  const LostFoundMatchListing({
    required this.id,
    required this.type,
    required this.status,
    required this.createdBy,
    this.areaCode,
    this.dateOccurred,
    this.title = '',
    this.itemDescription = '',
    this.relevantGroupIds = const [],
    this.attributes,
  });

  final String id;
  final String type;
  final String status;
  final String createdBy;
  final String? areaCode;
  final DateTime? dateOccurred;
  final String title;
  final String itemDescription;
  final List<String> relevantGroupIds;
  final LostFoundListingAttributes? attributes;

  bool get isOpen => status == 'open';
  bool get isLost => type == 'lost';
  bool get isFound => type == 'found';
  String? get category => attributes?.category;
}

abstract final class LostFoundMatchEligibility {
  /// Coarse area: when both sides have a canonical code they must match;
  /// when one or both are missing, area does not block (no GPS radius claim).
  static bool areasCompatible(String? rawA, String? rawB) {
    final a = LostFoundArea.normalizeAreaCode(rawA);
    final b = LostFoundArea.normalizeAreaCode(rawB);
    if (a != null && b != null) return a == b;
    return true;
  }

  /// Documents/cards auto-meet the score threshold — require explicit matching areas.
  static String? documentsCardsAreaFailure(String? rawA, String? rawB) {
    final a = LostFoundArea.normalizeAreaCode(rawA);
    final b = LostFoundArea.normalizeAreaCode(rawB);
    if (a == null || b == null) return 'documents_cards_missing_area';
    if (a != b) return 'area_mismatch';
    return null;
  }

  static bool datesWithinWindow(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    final diff = a.difference(b).inDays.abs();
    return diff <= LostFoundMatchPolicy.maxDateWindowDays;
  }

  static String? mandatoryFailureReason(
    LostFoundMatchListing source,
    LostFoundMatchListing candidate,
  ) {
    if (!source.isOpen || !candidate.isOpen) return 'status_not_open';
    if (source.id == candidate.id) return 'same_listing';
    if (source.createdBy == candidate.createdBy) return 'same_owner';
    if (source.isLost == candidate.isLost) return 'same_type';
    if (!source.isLost && !source.isFound) return 'invalid_source_type';
    if (!candidate.isLost && !candidate.isFound) return 'invalid_candidate_type';

    final catA = LostFoundCategory.normalize(source.category);
    final catB = LostFoundCategory.normalize(candidate.category);
    if (catA == null || catB == null) return 'missing_category';
    if (catA != catB) return 'category_mismatch';

    if (catA == LostFoundCategory.documentsCards) {
      final docArea = documentsCardsAreaFailure(
        source.areaCode,
        candidate.areaCode,
      );
      if (docArea != null) return docArea;
    } else if (!areasCompatible(source.areaCode, candidate.areaCode)) {
      return 'area_mismatch';
    }
    if (!datesWithinWindow(source.dateOccurred, candidate.dateOccurred)) {
      return 'date_out_of_window';
    }
    return null;
  }

  static bool isEligible(
    LostFoundMatchListing source,
    LostFoundMatchListing candidate,
  ) {
    return mandatoryFailureReason(source, candidate) == null;
  }
}
