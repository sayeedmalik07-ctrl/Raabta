import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/scam_shield/data/scam_evidence_repository.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_history_repository.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_secure_store.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_models.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_repository.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_temp_files.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_hive_store.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_state_repository.dart';

/// Wipes local-only sensitive Scam Shield data (Phase 34).
abstract final class SensitiveSafetyDataDeleter {
  static Future<void> deleteAll({String? uid}) async {
    final resolved = uid ?? UidScopedPreferences.resolveUid();
    if (resolved != null) {
      await ScamEvidenceRepository.instance.clearForUid(resolved);
      await ScamShieldHistoryRepository.instance.clearForUid(resolved);
    }
    await ReportPackRepository.saveDraft(const ReportPackDraft(), uid: resolved);
    await ReportPackTempFiles.purgeAll();
    await FamilyVerificationSecureStore.deleteAllSensitive();
    final alerts = SecurityAlertStateRepository();
    await alerts.write(SecurityAlertStateRepository.userBankFraudLineKey, null);
    await PersonalContextHiveStore.deleteAll();
  }
}
