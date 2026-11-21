/// Limited V1 working-day rule for Qatar Labour Law Art. 67 (standard branch).
///
/// Approved B2 scope only:
/// - Next calendar day after [terminationDate]
/// - If that day is Friday (usual weekly rest — Art. 75), advance to next non-Friday
///
/// Does NOT model: Saturday rest, public holidays, shift workers, or employer schedules.
/// This is not a complete Qatar legal working-day calendar.
library;

/// Version tag stored on Truth Certificate Art. 67 facts when standard branch applies.
abstract final class Art67WorkingDayRuleVersion {
  static const v1FridaySkip = 'art67-working-day-v1-friday-skip';
}

/// Version tag for the seven-calendar-day exception branch.
abstract final class Art67SevenDayRuleVersion {
  static const v1Calendar = 'art67-seven-day-v1-calendar';
}

abstract final class Art67WorkingDay {
  Art67WorkingDay._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Working day after [terminationDate] per approved V1 rule (Friday skip only).
  static DateTime nextWorkingDayAfterTermination(DateTime terminationDate) {
    var candidate = dateOnly(terminationDate).add(const Duration(days: 1));
    while (candidate.weekday == DateTime.friday) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
