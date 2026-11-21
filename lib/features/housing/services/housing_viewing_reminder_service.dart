import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

/// Day-before and hour-before viewing reminders (Zillow-style default).
class HousingViewingReminderService {
  Future<void> scheduleForConfirmedViewing({
    required String requestId,
    required String listingId,
    required String listingTitle,
    required DateTime confirmedAt,
    required String locale,
  }) async {
    await NotificationEngine.instance.scheduleViewingReminders(
      viewingId: requestId,
      listingId: listingId,
      listingTitle: listingTitle,
      viewingAt: confirmedAt,
      locale: locale,
    );
  }

  Future<void> cancelForViewing(String requestId) async {
    await NotificationEngine.instance.cancelViewingReminders(requestId);
  }

  static String formatSlot(DateTime slot, String locale) {
    return HousingViewingStrings.format(
      'hv_slot_line',
      locale,
      params: {
        'date': _formatDate(slot),
        'time': _formatTime(slot),
      },
    );
  }

  static String summarizeSlots(List<DateTime> slots, String locale) {
    if (slots.isEmpty) return '';
    if (slots.length == 1) return formatSlot(slots.first, locale);
    return slots.map((s) => formatSlot(s, locale)).join('; ');
  }

  static String _formatDate(DateTime dt) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = dt.toLocal();
    return '${weekdays[local.weekday - 1]} ${months[local.month - 1]} ${local.day}';
  }

  static String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
