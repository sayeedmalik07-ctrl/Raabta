import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/admin/services/admin_repository.dart';
import 'package:raabta/models/admin_report_model.dart';

class ReportService {
  ReportService({AdminRepository? repository})
      : _repository = repository ?? AdminRepository();

  final AdminRepository _repository;

  Future<void> submitReport({
    required AdminReportType type,
    required String title,
    required String description,
    String? targetId,
    String? targetType,
    String? reporterContact,
    Map<String, dynamic>? chatSnapshot,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final report = AdminReportModel(
      id: '',
      type: type,
      status: AdminReportStatus.open,
      title: title,
      description: description,
      targetId: targetId,
      targetType: targetType,
      reporterId: user?.uid,
      reporterContact: reporterContact,
      chatSnapshot: chatSnapshot,
    );
    await _repository.submitReport(report);
  }
}
