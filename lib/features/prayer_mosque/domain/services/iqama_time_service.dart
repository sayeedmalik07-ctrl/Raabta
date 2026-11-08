import 'package:raabta/features/prayer_mosque/domain/config/iqama_offset_config.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';

/// Deterministic estimated congregation times — no AI, no Firestore.
abstract final class IqamaTimeService {
  IqamaTimeService._();

  /// Returns estimated congregation time for an obligatory prayer entry.
  /// Sunrise and non-obligatory entries return null.
  static DateTime? estimatedCongregationAt(PrayerScheduleEntry entry) {
    if (entry.isSunrise || !entry.isObligatory) return null;
    final offset = IqamaOffsetConfig.offsetForPrayerKey(entry.key);
    if (offset == null) return null;
    return entry.time.add(offset);
  }
}
