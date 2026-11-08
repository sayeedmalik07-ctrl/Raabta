import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/health_insurance/presentation/providers/claim_dispute_providers.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/features/tenancy/data/tenancy_firestore_payload.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/providers/tenancy_condition_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/life_events_correlation_service.dart';

final lifeEventsCorrelationServiceProvider =
    Provider<LifeEventsCorrelationService>((ref) {
  return LifeEventsCorrelationService();
});

/// Active correlation for the current Home session.
final lifeEventHealthCoverageActiveProvider =
    StateProvider<LifeEventHealthCoverageCorrelation?>((ref) => null);

final lifeEventHealthCoverageDismissedProvider =
    StateProvider<bool>((ref) => false);

final lifeEventShockClusterActiveProvider =
    StateProvider<LifeEventShockCluster?>((ref) => null);

final lifeEventShockClusterDismissedProvider =
    StateProvider<bool>((ref) => false);

/// Whether the v1 Life Event Health Coverage card should render.
bool isLifeEventHealthCoverageCardVisible({
  required LifeEventHealthCoverageCorrelation? correlation,
  required bool dismissed,
}) =>
    !dismissed && correlation != null;

/// Whether the Shock Cluster card should render (presentation priority over v1).
bool isLifeEventShockClusterCardVisible({
  required LifeEventHealthCoverageCorrelation? healthCoverageCorrelation,
  required bool healthCoverageDismissed,
  required LifeEventShockCluster? cluster,
  required bool clusterDismissed,
}) {
  if (clusterDismissed || cluster == null) return false;
  if (isLifeEventHealthCoverageCardVisible(
    correlation: healthCoverageCorrelation,
    dismissed: healthCoverageDismissed,
  )) {
    return false;
  }
  return true;
}

Future<LifeEventHealthCoverageCorrelation?> _loadCorrelation(
  WidgetRef ref,
) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return null;

  final eosbHistory = await ref.read(eosbHistoryProvider.future);
  final sponsorshipRepo =
      await ref.read(sponsorshipTransferRepositoryProvider.future);
  final healthRepo =
      await ref.read(healthInsuranceRepositoryProvider.future);

  return ref.read(lifeEventsCorrelationServiceProvider).loadHealthCoverageCorrelation(
        userId: uid,
        eosbHistory: eosbHistory,
        sponsorshipCachedResult: sponsorshipRepo.loadCachedResult(),
        healthInsuranceRepository: healthRepo,
      );
}

Future<LifeEventShockCluster?> _loadShockCluster(WidgetRef ref) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return null;

  final eosbHistory = await ref.read(eosbHistoryProvider.future);
  final sponsorshipRepo =
      await ref.read(sponsorshipTransferRepositoryProvider.future);
  final healthRepo =
      await ref.read(healthInsuranceRepositoryProvider.future);
  final claimDisputeRepo =
      await ref.read(claimDisputeRepositoryProvider.future);
  final tenancyRepo = await ref.read(tenancyRepositoryProvider.future);
  final tenancyConditionRepo =
      await ref.read(tenancyConditionRepositoryProvider.future);

  final tenancyResult = tenancyRepo.loadCachedResult();
  final tenancyInput = tenancyRepo.loadCachedInput();
  List<TenancyConditionRecord> tenancyConditionRecords = const [];
  if (tenancyResult != null) {
    final leaseId = TenancyFirestorePayload.recordIdFor(tenancyResult);
    tenancyConditionRecords =
        await tenancyConditionRepo.fetchForLease(leaseId);
  }

  return ref.read(lifeEventsCorrelationServiceProvider).loadShockCluster(
        userId: uid,
        eosbHistory: eosbHistory,
        sponsorshipCachedResult: sponsorshipRepo.loadCachedResult(),
        healthInsuranceRepository: healthRepo,
        claimDispute: claimDisputeRepo.loadCached(),
        tenancyCachedResult: tenancyResult,
        tenancyCachedInput: tenancyInput,
        tenancyConditionRecords: tenancyConditionRecords,
      );
}

/// Loads correlation and sends notification once when Home opens (deduped).
Future<void> evaluateLifeEventHealthCoverageOnHomeLoad(WidgetRef ref) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return;

  if (!ref.read(lifeEventHealthCoverageDismissedProvider)) {
    final correlation = await _loadCorrelation(ref);
    if (correlation == null) {
      ref.read(lifeEventHealthCoverageActiveProvider.notifier).state = null;
    } else {
      ref.read(lifeEventHealthCoverageActiveProvider.notifier).state =
          correlation;

      final locale = ref.read(userLanguageProvider);
      final service = ref.read(lifeEventsCorrelationServiceProvider);
      await service.maybeNotifyHealthCoverageCorrelation(
        correlation: correlation,
        locale: locale,
      );
      await service.recordHealthCoveragePromptShown(
        engine: correlation.engine,
        userId: uid,
      );
    }
  }

  if (ref.read(lifeEventShockClusterDismissedProvider)) return;

  final cluster = await _loadShockCluster(ref);
  if (cluster == null) {
    ref.read(lifeEventShockClusterActiveProvider.notifier).state = null;
    return;
  }

  ref.read(lifeEventShockClusterActiveProvider.notifier).state = cluster;

  final locale = ref.read(userLanguageProvider);
  final service = ref.read(lifeEventsCorrelationServiceProvider);
  await service.maybeNotifyShockCluster(
    cluster: cluster,
    locale: locale,
  );
  await service.recordShockClusterPromptShown(userId: uid);
}

Future<void> dismissLifeEventShockClusterCard(WidgetRef ref) async {
  ref.read(lifeEventShockClusterDismissedProvider.notifier).state = true;
  ref.read(lifeEventShockClusterActiveProvider.notifier).state = null;
  final uid = ref.read(currentUserProvider)?.uid;
  await ref
      .read(lifeEventsCorrelationServiceProvider)
      .recordShockClusterPromptShown(userId: uid);
}

Future<void> dismissLifeEventHealthCoverageCard(WidgetRef ref) async {
  final correlation = ref.read(lifeEventHealthCoverageActiveProvider);
  ref.read(lifeEventHealthCoverageDismissedProvider.notifier).state = true;
  ref.read(lifeEventHealthCoverageActiveProvider.notifier).state = null;
  final uid = ref.read(currentUserProvider)?.uid;
  if (correlation != null) {
    await ref
        .read(lifeEventsCorrelationServiceProvider)
        .recordHealthCoveragePromptShown(
          engine: correlation.engine,
          userId: uid,
        );
  }
}
