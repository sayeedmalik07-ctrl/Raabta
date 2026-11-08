import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/cost_of_living/presentation/providers/cost_of_living_providers.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/intelligence/presentation/providers/evidence_trail_providers.dart';
import 'package:raabta/features/quick_actions/bill_tracker_screen.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/intelligence/consistency_checker.dart';
import 'package:raabta/services/intelligence/home_intelligence_focus_service.dart';

final homeIntelligenceFocusServiceProvider =
    Provider<HomeIntelligenceFocusService>(
  (ref) => const HomeIntelligenceFocusService(),
);

/// Document Vault rows for intelligence risk detection — same collection as Phase 5.
final userScannedDocumentsProvider =
    StreamProvider<List<DocumentVaultRecord>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('scanned_documents')
      .where('userId', isEqualTo: uid)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    final records = <DocumentVaultRecord>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      records.add(
        DocumentVaultRecord(
          id: doc.id,
          displayName: data['displayName'] as String? ??
              data['holderName'] as String?,
          docType: data['docType'] as String?,
          expiryDate: _parseExpiry(data['expiryDate']),
        ),
      );
    }
    return records;
  });
});

DateTime? _parseExpiry(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

List<BillDueRecord> _mapBills(List<BillEntry> bills) {
  return bills
      .map(
        (bill) => BillDueRecord(
          id: bill.id,
          provider: bill.provider,
          dueDate: bill.dueDate,
          isPaid: bill.isPaid,
          amount: bill.amount,
        ),
      )
      .toList();
}

/// Top 1–3 critical/high intelligence items for Today's Focus.
final homeIntelligenceFocusProvider =
    Provider<AsyncValue<List<HomeIntelligenceFocusItem>>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return const AsyncValue.data([]);
  }

  final documentsAsync = ref.watch(userScannedDocumentsProvider);
  final billsAsync = ref.watch(userBillsProvider);
  final historyAsync = ref.watch(eosbHistoryProvider);
  final evidenceAsync = ref.watch(evidenceEntriesProvider);
  final profile = ref.watch(userAIProfileProvider);
  final overtimeCompanyName = ref.watch(overtimeTruthProvider).input.companyName;

  if (documentsAsync.isLoading ||
      billsAsync.isLoading ||
      historyAsync.isLoading ||
      evidenceAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (documentsAsync.hasError) {
    return AsyncValue.error(
      documentsAsync.error!,
      documentsAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (billsAsync.hasError) {
    return AsyncValue.error(
      billsAsync.error!,
      billsAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (historyAsync.hasError) {
    return AsyncValue.error(
      historyAsync.error!,
      historyAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (evidenceAsync.hasError) {
    return AsyncValue.error(
      evidenceAsync.error!,
      evidenceAsync.stackTrace ?? StackTrace.empty,
    );
  }

  final documents = documentsAsync.valueOrNull ?? const [];
  final bills = _mapBills(billsAsync.valueOrNull ?? const []);
  final history = historyAsync.valueOrNull ?? const [];
  final latestEosb = history.isNotEmpty ? history.first : null;
  final evidenceEntries = (evidenceAsync.valueOrNull ?? const [])
      .map(EvidenceDeadlineRecord.fromEntry)
      .toList();

  final items = ref.watch(homeIntelligenceFocusServiceProvider).resolveTopItems(
        userId: uid,
        documents: documents,
        bills: bills,
        eosbInput: latestEosb?.input,
        eosbBreakdown: latestEosb?.result.breakdown,
        eosbCalculationId: latestEosb?.id,
        evidenceEntries: evidenceEntries,
        eosbSalary: latestEosb?.input != null
            ? EosbSalarySnapshot(
                basicSalary: latestEosb!.input.basicSalary,
                updatedAt: latestEosb.savedAt,
              )
            : null,
        eosbTimestamp: EosbTimestampSnapshot(updatedAt: latestEosb?.savedAt),
        expatScoreTimestamp: ExpatScoreTimestampSnapshot(
          lastCalculated: profile?.score.lastCalculated,
        ),
        eosbEmployer: latestEosb?.input != null
            ? EosbEmployerSnapshot(
                companyName: latestEosb!.input.companyName,
              )
            : null,
        overtimeEmployer: overtimeCompanyName.trim().isNotEmpty
            ? OvertimeEmployerSnapshot(companyName: overtimeCompanyName)
            : null,
      );

  return AsyncValue.data(items);
});
