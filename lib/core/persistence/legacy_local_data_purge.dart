import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_claim_dispute_repository.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/warranty_storage.dart';
import 'package:raabta/features/scam_shield/data/scam_evidence_repository.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time purge of pre-isolation device-global sensitive keys.
///
/// Legacy data cannot be safely attributed to any UID — it is discarded, not
/// migrated to the first authenticated user.
abstract final class LegacyLocalDataPurge {
  static const deviceGlobalPurgeFlag =
      'local_data_isolation_legacy_global_purge_v1';

  static const _legacyStringKeys = [
    LocalDataIsolationKeys.eosbOfflineCache,
    LocalDataIsolationKeys.eosbCalculationHistory,
    LocalDataIsolationKeys.eosbSalaryConsent,
    LocalDataIsolationKeys.eosbLocale,
    LocalDataIsolationKeys.eosbReengagementTrigger,
    LocalDataIsolationKeys.eosbOvertimeInput,
    LocalDataIsolationKeys.eosbOvertimeResult,
    LocalDataIsolationKeys.eosbOvertimeHistory,
    LocalDataIsolationKeys.sponsorshipInput,
    LocalDataIsolationKeys.sponsorshipResult,
    LocalDataIsolationKeys.sponsorshipLocale,
    LocalDataIsolationKeys.sponsorshipCheckDone,
    LocalDataIsolationKeys.sponsorshipChecklist,
    LocalDataIsolationKeys.tenancyLeaseInput,
    LocalDataIsolationKeys.tenancyComplianceResult,
    LocalDataIsolationKeys.tenancyLocale,
    LocalDataIsolationKeys.tenancyCheckCompleted,
    LocalDataIsolationKeys.tenancyChecklist,
    LocalDataIsolationKeys.tenancyPacketMeta,
    LocalDataIsolationKeys.hiComplianceInput,
    LocalDataIsolationKeys.hiComplianceResult,
    LocalDataIsolationKeys.hiInsurerHistory,
    LocalDataIsolationKeys.hiComplianceDone,
    LocalDataIsolationKeys.hiLastOpened,
    LocalDataIsolationKeys.hiLocale,
    HealthInsuranceClaimDisputeRepository.cacheKey,
    HealthInsuranceClaimDisputeRepository.activeIdKey,
    WarrantyStorage.legacyGlobalKey,
    CvRepository.latestIdKey,
    CvRepository.indexKey,
  ];

  static Future<void> purgeDeviceGlobalSensitiveData(
    SharedPreferences prefs,
  ) async {
    if (prefs.getBool(deviceGlobalPurgeFlag) ?? false) return;

    for (final key in _legacyStringKeys) {
      await prefs.remove(key);
    }

    final allKeys = prefs.getKeys().toList();
    for (final key in allKeys) {
      if (key.startsWith(CvRepository.documentKeyPrefix) &&
          !key.contains('::')) {
        await prefs.remove(key);
      }
      if (key.startsWith('tenancy_condition_records_v1_') &&
          !key.contains('::')) {
        await prefs.remove(key);
      }
    }

    await ScamShieldHistoryRepository.instance.purgeLegacyDeviceGlobalEntries();
    await ScamEvidenceRepository.instance.purgeLegacyDeviceGlobalRecords();

    await prefs.setBool(deviceGlobalPurgeFlag, true);
  }
}
