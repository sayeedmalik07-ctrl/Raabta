import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';

class PrayerRecord {
  const PrayerRecord({
    required this.dateKey,
    required this.prayerKey,
    required this.status,
    this.updatedAt,
  });

  /// yyyy-MM-dd
  final String dateKey;
  final String prayerKey;
  final PrayerTrackingStatus status;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'prayerKey': prayerKey,
        'status': status.name,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory PrayerRecord.fromJson(Map<String, dynamic> json) {
    return PrayerRecord(
      dateKey: json['dateKey'] as String,
      prayerKey: json['prayerKey'] as String,
      status: PrayerTrackingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PrayerTrackingStatus.prayed,
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

class PrayerStats {
  const PrayerStats({
    required this.currentStreak,
    required this.weeklyCompletion,
    required this.monthlyCompletion,
    required this.prayerPercentage,
    required this.dailyCounts,
  });

  final int currentStreak;
  final double weeklyCompletion;
  final double monthlyCompletion;
  final double prayerPercentage;
  final Map<String, int> dailyCounts;
}
