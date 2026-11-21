import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';

/// Neutral room identifiers for condition capture — display via [displayLabel].
abstract final class TenancyConditionRoomSuggestions {
  static const ids = [
    'living_room',
    'master_bedroom',
    'bedroom',
    'kitchen',
    'bathroom',
    'balcony',
    'hallway',
    'storage',
  ];

  /// Canonical English label stored for room matching (locale-neutral).
  static String canonicalLabel(String id) {
    return switch (id) {
      'living_room' => 'Living Room',
      'master_bedroom' => 'Master Bedroom',
      'bedroom' => 'Bedroom',
      'kitchen' => 'Kitchen',
      'bathroom' => 'Bathroom',
      'balcony' => 'Balcony',
      'hallway' => 'Hallway',
      'storage' => 'Storage',
      _ => id,
    };
  }

  static String displayLabel(String id, String locale) {
    return TenancyStrings.t('tenancy_room_$id', locale);
  }
}
