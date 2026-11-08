import 'package:raabta/features/bill_tracker/friends_family_loans/data/repository/loan_repository.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/bill_tracker_repository.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Purges Bill Tracker + Friends & Family loan data on account deletion.
abstract final class BillTrackerUserDataPurge {
  static const _localUserIdKey = 'raabta_user_id';

  static Future<void> purgeForAccountDeletion({
    required String firebaseUid,
    BillTrackerRepository? billTrackerRepository,
    LoanRepository? loanRepository,
  }) async {
    final billRepo = billTrackerRepository ?? BillTrackerRepository();
    final loanRepo = loanRepository ?? LoanRepository();

    final userIds = <String>{firebaseUid};
    final prefs = await SharedPreferences.getInstance();
    final localId = prefs.getString(_localUserIdKey);
    if (localId != null && localId.isNotEmpty) {
      userIds.add(localId);
    }

    for (final userId in userIds) {
      await billRepo.deleteAllForUser(userId);
      await loanRepo.deleteAllForUser(userId);
    }

    await DraftService.instance.clearDraft(DraftBoxKeys.billTrackerAdd);
  }
}
