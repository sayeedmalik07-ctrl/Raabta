import 'package:raabta/features/buddy/domain/buddy_area_codes.dart';

/// Coarse Qatar area codes for Lost & Found (canonical list: [BuddyAreaCodes.all]).
abstract final class LostFoundArea {
  static List<String> get supportedCodes => BuddyAreaCodes.all;

  /// Returns a canonical code or `null` if missing/invalid (never trust raw client input).
  static String? normalizeAreaCode(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return BuddyAreaCodes.isValid(trimmed) ? trimmed : null;
  }
}
