import 'package:raabta/models/notification_models.dart';
import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

class JobApplicationNotificationService {
  Future<void> notifyStatusChanged({
    required String recipientUserId,
    required String jobId,
    required String jobTitle,
    required String statusKey,
    String locale = 'English',
  }) async {
    if (!ComplianceFlagsGate.current.jobApplicationStatusEnabled) return;
    final statusLabel = JobsApplicationStrings.t(statusKey, locale);
    await NotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.general,
        title: JobsApplicationStrings.t('jobs_app_notif_title', locale),
        body: JobsApplicationStrings.format(
          'jobs_app_notif_body',
          locale,
          params: {'title': jobTitle, 'status': statusLabel},
        ),
        route: '/jobs/my-applications',
        dedupKey: 'job_app_${jobId}_${recipientUserId}_$statusKey',
        remoteUserIds: [recipientUserId],
        data: {
          'jobId': jobId,
          'kind': 'job_application_status',
          'statusKey': statusKey,
        },
      ),
    );
  }
}
