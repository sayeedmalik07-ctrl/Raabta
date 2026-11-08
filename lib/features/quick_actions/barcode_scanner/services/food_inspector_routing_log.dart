import 'dart:developer' as developer;

/// Cost-visibility logging for Food Inspector additive routing.
class FoodInspectorRoutingLog {
  FoodInspectorRoutingLog._();

  static void localHit({
    required int resolvedCount,
    required int bundledCount,
    required int sharedCacheCount,
    String? detail,
  }) {
    developer.log(
      'foodInspectorLocalHit '
      'resolved=$resolvedCount '
      'bundled=$bundledCount '
      'sharedCache=$sharedCacheCount'
      '${detail != null ? ' $detail' : ''}',
      name: 'FoodInspector',
    );
  }

  static void claudeFallback({
    required List<String> codes,
    required String reason,
  }) {
    developer.log(
      'foodInspectorClaudeFallback '
      'codes=${codes.join(",")} '
      'reason=$reason',
      name: 'FoodInspector',
    );
  }
}
