import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/screens/profile/models/life_intelligence_activity_item.dart';
import 'package:raabta/services/life_intelligence/life_intelligence_push_ack_repository.dart';
import 'package:raabta/services/life_intelligence/life_intelligence_push_orchestrator.dart';
import 'package:raabta/services/life_intelligence_health_insurance_employer_reader.dart';
import 'package:raabta/services/life_intelligence_signals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lifeIntelligencePushAckRepositoryProvider =
    FutureProvider<LifeIntelligencePushAckRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LifeIntelligencePushAckRepository(prefs);
});

final lifeIntelligenceActivityItemsProvider =
    FutureProvider<List<LifeIntelligenceActivityItem>>((ref) async {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const [];

  final ackRepo = await ref.watch(lifeIntelligencePushAckRepositoryProvider.future);
  final acknowledged = await ackRepo.loadAcknowledgedTokens();

  final eosbHistory = await ref.watch(eosbHistoryProvider.future);
  final sponsorshipRepo =
      await ref.watch(sponsorshipTransferRepositoryProvider.future);
  final hiEmployerKey =
      await LifeIntelligenceHealthInsuranceEmployerReader
          .loadLatestNormalizedEmployerKey();

  final now = DateTime.now();
  final items = <LifeIntelligenceActivityItem>[];

  if (LifeIntelligenceSignalsService.evaluateEmployerTransferStarted(
    sponsorshipTransferCompleted: sponsorshipRepo.hasCompletedCheck(uid: uid),
    hasEosbHistory: eosbHistory.isNotEmpty,
  )) {
    final token = LifeIntelligencePushOrchestrator.ackTokenFor(
      type: LifeIntelligenceSignalType.employerTransferStarted,
      eosbHistory: eosbHistory,
      healthInsuranceEmployerKey: hiEmployerKey,
    );
    if (!acknowledged.contains(token)) {
      items.add(
        LifeIntelligenceActivityItem(
          sourceId: LifeIntelligencePushAckRepository.sourceIdFor(
            LifeIntelligenceSignalType.employerTransferStarted,
          ),
          type: LifeIntelligenceSignalType.employerTransferStarted,
          titleKey: 'my_activity_li_transfer_title',
          bodyKey: 'my_activity_li_transfer_body',
          route: LifeIntelligenceSignalsService.eosbRoute,
          sortTime: eosbHistory.isNotEmpty
              ? eosbHistory.first.savedAt
              : now,
          ackToken: token,
        ),
      );
    }
  }

  final eosbKey = eosbHistory.isNotEmpty
      ? eosbHistory.first.input.effectiveNormalizedEmployerKey
      : '';
  if (LifeIntelligenceSignalsService.evaluateEmployerNameMismatch(
    eosbEmployerKey: eosbKey,
    healthInsuranceEmployerKey: hiEmployerKey,
  )) {
    final token = LifeIntelligencePushOrchestrator.ackTokenFor(
      type: LifeIntelligenceSignalType.employerNameMismatch,
      eosbHistory: eosbHistory,
      healthInsuranceEmployerKey: hiEmployerKey,
    );
    if (!acknowledged.contains(token)) {
      items.add(
        LifeIntelligenceActivityItem(
          sourceId: LifeIntelligencePushAckRepository.sourceIdFor(
            LifeIntelligenceSignalType.employerNameMismatch,
          ),
          type: LifeIntelligenceSignalType.employerNameMismatch,
          titleKey: 'my_activity_li_mismatch_title',
          bodyKey: 'my_activity_li_mismatch_body',
          route: LifeIntelligenceSignalsService.healthInsuranceRoute,
          sortTime: eosbHistory.isNotEmpty
              ? eosbHistory.first.savedAt
              : now,
          ackToken: token,
        ),
      );
    }
  }

  items.sort((a, b) => b.sortTime.compareTo(a.sortTime));
  return items;
});

Future<void> dismissLifeIntelligenceActivityItem(
  WidgetRef ref,
  LifeIntelligenceActivityItem item,
) async {
  final ackRepo = await ref.read(lifeIntelligencePushAckRepositoryProvider.future);
  await ackRepo.acknowledge(item.ackToken);
  ref.invalidate(lifeIntelligenceActivityItemsProvider);
}
