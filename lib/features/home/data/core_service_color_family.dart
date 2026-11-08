import 'package:raabta/core/design/color_family.dart';

/// Home “All Services” / Explore Raabta core tiles (kit: brand family).
abstract final class CoreServiceColorFamily {
  static const ColorFamily tileFamily = RaabtaColorFamilies.brand;

  static const List<String> coreServiceTitles = [
    'Housing',
    'Money Services',
    'Visa Help',
    'Find Doctor',
    'Jobs',
    'Businesses',
  ];

  static ColorFamily forTitle(String title) {
    if (!coreServiceTitles.contains(title)) {
      throw ArgumentError.value(title, 'title', 'Unknown core service title');
    }
    return tileFamily;
  }

  /// Allowed decorative families on the core services grid (hue-budget prep).
  static bool isAllowedOnCoreServicesGrid(ColorFamily family) =>
      identical(family, RaabtaColorFamilies.brand);
}
