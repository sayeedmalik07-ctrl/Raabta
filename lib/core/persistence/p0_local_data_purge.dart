import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_claim_dispute_repository.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_repository.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/warranty_storage.dart';
import 'package:raabta/features/scam_shield/data/scam_evidence_repository.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_history_repository.dart';
import 'package:raabta/features/sponsorship_transfer/data/sponsorship_transfer_repository.dart';
import 'package:raabta/features/tenancy/data/tenancy_condition_repository.dart';
import 'package:raabta/features/tenancy/data/tenancy_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UID-scoped purge for P0 sensitive local data (account deletion).
abstract final class P0LocalDataPurge {
  static Future<void> purgeAllForUid(String uid) async {
    if (uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    await EosbRepository.purgeLocalDataForUser(prefs, uid);
    await SponsorshipTransferRepository.purgeLocalDataForUser(prefs, uid);
    await TenancyRepository.purgeLocalDataForUser(prefs, uid);
    await TenancyConditionRepository.purgeLocalDataForUser(prefs, uid);
    await HealthInsuranceRepository.purgeLocalDataForUser(prefs, uid);
    await HealthInsuranceClaimDisputeRepository.purgeLocalDataForUser(
      prefs,
      uid,
    );
    await WarrantyStorage.purgeLocalDataForUser(prefs, uid);
    await CvRepository.purgeLocalDataForUser(prefs, uid);

    await ScamShieldHistoryRepository.instance.clearForUid(uid);
    await ScamEvidenceRepository.instance.clearForUid(uid);
  }
}
