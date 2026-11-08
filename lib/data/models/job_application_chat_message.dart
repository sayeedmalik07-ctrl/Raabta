import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';

class JobApplicationChatMessage {
  const JobApplicationChatMessage({
    required this.id,
    required this.jobId,
    required this.applicantUid,
    required this.senderId,
    required this.createdAt,
    this.text,
    this.messageKind,
    this.applicationStatusKey,
    this.peerUid,
  });

  final String id;
  final String jobId;
  final String applicantUid;
  final String senderId;
  final String? text;
  final DateTime createdAt;
  final String? messageKind;
  final String? applicationStatusKey;
  final String? peerUid;

  bool get isApplicationSystem => messageKind == 'application_system';

  /// Authoritative display text — system messages derive from [applicationStatusKey].
  String localizedBody(String locale) {
    if (isApplicationSystem && applicationStatusKey != null) {
      final statusLabel =
          JobsApplicationStrings.t(applicationStatusKey!, locale);
      return JobsApplicationStrings.format(
        'jobs_app_chat_status_updated',
        locale,
        params: {'status': statusLabel},
      );
    }
    return text ?? '';
  }

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'applicantUid': applicantUid,
        'senderId': senderId,
        'createdAt': createdAt.toIso8601String(),
        if (!isApplicationSystem && text != null) 'text': text,
        if (messageKind != null) 'messageKind': messageKind,
        if (applicationStatusKey != null)
          'applicationStatusKey': applicationStatusKey,
        if (peerUid != null && peerUid!.isNotEmpty) 'peerUid': peerUid,
      };

  factory JobApplicationChatMessage.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return JobApplicationChatMessage(
      id: id,
      jobId: json['jobId'] as String? ?? '',
      applicantUid: json['applicantUid'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      messageKind: json['messageKind'] as String?,
      applicationStatusKey: json['applicationStatusKey'] as String?,
    );
  }
}
