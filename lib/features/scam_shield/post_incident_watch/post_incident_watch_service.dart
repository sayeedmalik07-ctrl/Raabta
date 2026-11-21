import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_prefs.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_repository.dart';

abstract final class PostIncidentWatchService {
  static const watchDays = 30;

  static Future<void> onIncidentFlowCompleted({
    DateTime Function()? clock,
  }) async {
    if (await PostIncidentWatchPrefs.isPermanentlyDismissed()) return;
    if (!await PostIncidentWatchPrefs.isReminderEnabled()) return;
    final now = clock?.call() ?? DateTime.now();
    await PostIncidentWatchRepository().writeWatchUntil(
      now.add(const Duration(days: watchDays)),
    );
  }

  static Future<bool> isWatchActive({DateTime Function()? clock}) async {
    if (await PostIncidentWatchPrefs.isPermanentlyDismissed()) return false;
    if (!await PostIncidentWatchPrefs.isReminderEnabled()) return false;
    final until = await PostIncidentWatchRepository().readWatchUntil();
    if (until == null) return false;
    final now = clock?.call() ?? DateTime.now();
    if (!until.isAfter(now)) {
      await PostIncidentWatchRepository().writeWatchUntil(null);
      return false;
    }
    return true;
  }

  static Future<void> dismissPermanently() async {
    await PostIncidentWatchPrefs.setPermanentlyDismissed(true);
    await PostIncidentWatchRepository().writeWatchUntil(null);
  }
}
