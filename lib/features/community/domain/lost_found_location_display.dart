import 'package:raabta/features/community/domain/lost_found_area.dart';

/// Human-readable location line for feed/detail (backward compatible).
abstract final class LostFoundLocationDisplay {
  static String format({
    required String location,
    String? areaCode,
  }) {
    final place = location.trim();
    final area = LostFoundArea.normalizeAreaCode(areaCode);
    if (area != null && place.isNotEmpty) return '$area · $place';
    if (area != null) return area;
    return place;
  }
}
