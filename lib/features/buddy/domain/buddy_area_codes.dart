import 'package:raabta/models/housing_models.dart';

/// Canonical coarse areas — single source: [qatarAreas] in housing_models.dart.
abstract final class BuddyAreaCodes {
  static List<String> get all => qatarAreas;

  static bool isValid(String? code) =>
      code != null && code.isNotEmpty && qatarAreas.contains(code);
}
