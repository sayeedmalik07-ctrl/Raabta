/// On-device WBGT meter log entry (not uploaded).
class ClimateWbgtMeterReading {
  const ClimateWbgtMeterReading({
    required this.recordedAt,
    required this.meterWbgtC,
    required this.estimateWbgtC,
    required this.estimateBandKey,
    this.note,
  });

  final DateTime recordedAt;
  final double meterWbgtC;
  final double estimateWbgtC;
  final String estimateBandKey;
  final String? note;

  double get differenceC => meterWbgtC - estimateWbgtC;

  Map<String, dynamic> toJson() => {
        'recordedAt': recordedAt.toIso8601String(),
        'meterWbgtC': meterWbgtC,
        'estimateWbgtC': estimateWbgtC,
        'estimateBandKey': estimateBandKey,
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  factory ClimateWbgtMeterReading.fromJson(Map<String, dynamic> json) {
    return ClimateWbgtMeterReading(
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now(),
      meterWbgtC: (json['meterWbgtC'] as num).toDouble(),
      estimateWbgtC: (json['estimateWbgtC'] as num).toDouble(),
      estimateBandKey: json['estimateBandKey'] as String? ?? 'lower',
      note: json['note'] as String?,
    );
  }
}
