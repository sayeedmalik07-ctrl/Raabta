/// User-configured gold alert stored on `users/{uid}.goldAlerts`.
class GoldAlert {
  const GoldAlert({
    required this.id,
    required this.type,
    this.purity = 22,
    this.thresholdQar,
    this.direction = 'below',
    this.gainQar,
    this.createdAt,
  });

  final String id;
  final String type; // price_threshold | locker_gain
  final int purity;
  final double? thresholdQar;
  final String direction; // above | below
  final double? gainQar;
  final String? createdAt;

  factory GoldAlert.fromJson(Map<String, dynamic> json) {
    return GoldAlert(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'price_threshold',
      purity: (json['purity'] as num?)?.toInt() ?? 22,
      thresholdQar: (json['thresholdQar'] as num?)?.toDouble(),
      direction: json['direction'] as String? ?? 'below',
      gainQar: (json['gainQar'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        if (purity != 22) 'purity': purity,
        if (thresholdQar != null) 'thresholdQar': thresholdQar,
        if (direction != 'below') 'direction': direction,
        if (gainQar != null) 'gainQar': gainQar,
        'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      };

  String get displayTitle {
    if (type == 'locker_gain') {
      return 'Portfolio gain ≥ QAR ${gainQar?.toStringAsFixed(0) ?? '—'}';
    }
    final dir = direction == 'above' ? 'rises above' : 'drops below';
    return '${purity}K $dir QAR ${thresholdQar?.toStringAsFixed(2) ?? '—'}/g';
  }
}

/// Shared dedup keys — keep in sync with [runGoldAlertChecks] in services/goldQatar.js.
abstract final class GoldAlertDedupKeys {
  static String priceThreshold(String alertId, double thresholdQar) =>
      'gold_price_${alertId}_$thresholdQar';

  static String lockerGain(String alertId, double targetQar) =>
      'jewelry_gain_${alertId}_$targetQar';
}
