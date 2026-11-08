import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/home/domain/eosb_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/health_insurance_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/sponsorship_transfer_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/tenancy_truth_chip_mapper.dart';
import 'package:raabta/features/home/domain/truth_chip_unavailable_status.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Live Truth Engine chip status (A1–A4 mappers, UID-scoped local cache only).
final truthChipStatusProvider =
    FutureProvider.family<TruthChipStatus, TruthChipEngine>((ref, engine) async {
  ref.watch(currentAuthUidProvider);
  final locale = ref.watch(userLanguageProvider);
  final now = DateTime.now();

  switch (engine) {
    case TruthChipEngine.eosb:
      final history = await ref.watch(eosbHistoryProvider.future);
      return EosbTruthChipMapper.map(
        history: history,
        now: now,
        locale: locale,
      );
    case TruthChipEngine.sponsorshipTransfer:
      final repo = await ref.watch(sponsorshipTransferRepositoryProvider.future);
      return SponsorshipTransferTruthChipMapper.map(
        input: repo.loadCachedInput(),
        result: repo.loadCachedResult(),
        now: now,
        locale: locale,
      );
    case TruthChipEngine.tenancy:
      final repo = await ref.watch(tenancyRepositoryProvider.future);
      return TenancyTruthChipMapper.map(
        input: repo.loadCachedInput(),
        result: repo.loadCachedResult(),
        now: now,
        locale: locale,
      );
    case TruthChipEngine.healthInsurance:
      final repo = await ref.watch(healthInsuranceRepositoryProvider.future);
      return HealthInsuranceTruthChipMapper.map(
        input: repo.loadCachedInput(),
        result: repo.loadCachedResult(),
        now: now,
        locale: locale,
      );
  }
});

/// Sync [TruthChipStatus] for widgets and [ProviderContainer] tests.
final truthChipWatchStatusProvider =
    Provider.family<TruthChipStatus, TruthChipEngine>((ref, engine) {
  final locale = ref.watch(userLanguageProvider);
  final async = ref.watch(truthChipStatusProvider(engine));
  return mapTruthChipAsyncStatus(
    async: async,
    engine: engine,
    locale: locale,
  );
});

/// Maps [AsyncValue] from [truthChipStatusProvider] to a [TruthChipStatus] for UI.
@visibleForTesting
TruthChipStatus mapTruthChipAsyncStatus({
  required AsyncValue<TruthChipStatus> async,
  required TruthChipEngine engine,
  required String locale,
}) {
  return async.when(
    loading: () => TruthChipStatus.loading(
      engine: engine,
      titleKey: _titleKeyForEngine(engine),
      deepLink: engine.homeRoute,
    ),
    error: (_, _) => TruthChipUnavailableStatus.forEngine(engine, locale),
    data: (status) => status,
  );
}

/// Convenience for Consumer widgets (same pattern as [watchHomeChipStatus]).
TruthChipStatus watchTruthChipStatus(WidgetRef ref, TruthChipEngine engine) {
  return ref.watch(truthChipWatchStatusProvider(engine));
}

String _titleKeyForEngine(TruthChipEngine engine) => switch (engine) {
      TruthChipEngine.eosb => EosbTruthChipMapper.titleKey,
      TruthChipEngine.sponsorshipTransfer =>
        SponsorshipTransferTruthChipMapper.titleKey,
      TruthChipEngine.tenancy => TenancyTruthChipMapper.titleKey,
      TruthChipEngine.healthInsurance => HealthInsuranceTruthChipMapper.titleKey,
    };
