import 'package:raabta/models/admin_report_model.dart';
import 'package:raabta/services/report_service.dart';

class ClassifiedsChatReportMessageSnapshot {
  const ClassifiedsChatReportMessageSnapshot({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.createdAtIso,
  });

  final String messageId;
  final String senderId;
  final String text;
  final String createdAtIso;

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAtIso,
      };
}

/// Builds a frozen message window for admin review (no live thread access).
abstract final class ClassifiedsChatReportService {
  static const surroundingCount = 2;

  static List<ClassifiedsChatReportMessageSnapshot> buildSnapshotWindow({
    required List<ClassifiedsChatReportMessageSnapshot> allMessages,
    required String reportedMessageId,
  }) {
    if (allMessages.isEmpty) return const [];

    var index = allMessages.indexWhere((m) => m.messageId == reportedMessageId);
    if (index < 0) index = allMessages.length - 1;

    final start = (index - surroundingCount).clamp(0, allMessages.length - 1);
    final end = (index + surroundingCount).clamp(0, allMessages.length - 1);
    return allMessages.sublist(start, end + 1);
  }

  static Future<void> submitChatReport({
    required ReportService reportService,
    required String locale,
    required String targetId,
    required String targetType,
    required String title,
    required String description,
    required String reportedMessageId,
    required List<ClassifiedsChatReportMessageSnapshot> allMessages,
    String? peerUid,
  }) async {
    final window = buildSnapshotWindow(
      allMessages: allMessages,
      reportedMessageId: reportedMessageId,
    );

    final snapshotPayload = {
      'reportedMessageId': reportedMessageId,
      if (peerUid != null && peerUid.isNotEmpty) 'peerUid': peerUid,
      'messages': window.map((m) => m.toJson()).toList(),
      'locale': locale,
      'capturedAt': DateTime.now().toUtc().toIso8601String(),
    };

    await reportService.submitReport(
      type: AdminReportType.chat,
      title: title,
      description: description,
      targetId: targetId,
      targetType: targetType,
      chatSnapshot: snapshotPayload,
    );
  }
}
