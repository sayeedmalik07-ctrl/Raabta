import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/home/providers/life_events_providers.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/screens/profile/providers/life_intelligence_activity_providers.dart';
import 'package:raabta/services/life_intelligence/life_intelligence_push_orchestrator.dart';
import 'package:raabta/services/life_intelligence_health_insurance_employer_reader.dart';

/// Evaluates V2 Life Intelligence push eligibility and delivers via NotificationEngine.
Future<void> evaluateLifeIntelligencePushOnHomeLoad(WidgetRef ref) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return;

  final eosbHistory = await ref.read(eosbHistoryProvider.future);
  final sponsorshipRepo =
      await ref.read(sponsorshipTransferRepositoryProvider.future);
  final hiEmployerKey =
      await LifeIntelligenceHealthInsuranceEmployerReader
          .loadLatestNormalizedEmployerKey();

  final ackRepo = await ref.read(lifeIntelligencePushAckRepositoryProvider.future);
  final now = DateTime.now();
  final lifeEventActive =
      ref.read(lifeEventHealthCoverageActiveProvider) != null;

  final eligibleType = await LifeIntelligencePushOrchestrator.selectEligiblePushType(
    sponsorshipTransferCompleted: sponsorshipRepo.hasCompletedCheck(),
    eosbHistory: eosbHistory,
    healthInsuranceEmployerKey: hiEmployerKey,
    lifeEventHealthCoverageActive: lifeEventActive,
    ackRepo: ackRepo,
    now: now,
  );

  if (eligibleType == null) return;

  final locale = await LifeIntelligencePushOrchestrator.resolveLocale();
  await LifeIntelligencePushOrchestrator.trySendPush(
    type: eligibleType,
    eosbHistory: eosbHistory,
    healthInsuranceEmployerKey: hiEmployerKey,
    locale: locale,
    now: now,
  );
}
