class ReminderConstants {
  ReminderConstants._();

  static const List<int> expiryReminderDaysBefore = [30, 14, 3];

  static const String expiryReminderTitle = 'Document Expiring Soon';

  static String expiryReminderBody(String docTypeName, int daysLeft) {
    return '$docTypeName expires in $daysLeft days. '
        'Renew now to avoid issues.';
  }
}
