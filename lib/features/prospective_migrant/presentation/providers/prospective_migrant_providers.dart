import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/prospective_migrant/data/prospective_profile_repository.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';
import 'package:raabta/features/prospective_migrant/services/prospective_pdf_service.dart';

final prospectiveProfileProvider =
    AsyncNotifierProvider<ProspectiveProfileNotifier, ProspectiveProfile?>(
  ProspectiveProfileNotifier.new,
);

class ProspectiveProfileNotifier extends AsyncNotifier<ProspectiveProfile?> {
  @override
  Future<ProspectiveProfile?> build() async {
    return ProspectiveProfileRepository.instance.load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ProspectiveProfileRepository.instance.load());
  }

  Future<void> save(ProspectiveProfile profile) async {
    await ProspectiveProfileRepository.instance.save(profile);
    state = AsyncData(profile);
  }

  Future<void> clear() async {
    await ProspectiveProfileRepository.instance.clear();
    state = const AsyncData(null);
  }
}

final prospectiveLocaleProvider = Provider<String>(
  (ref) => ref.watch(appLocaleProvider),
);

final prospectivePreviewResultProvider = Provider<EosbResult?>((ref) {
  final profile = ref.watch(prospectiveProfileProvider).valueOrNull;
  if (profile == null || !profile.contractIntakeComplete) return null;
  const calc = EosbCalculationService();
  final input = const ProspectiveProfileMapper().toPreviewInput(profile);
  return calc.calculate(input);
});

final prospectivePdfServiceProvider = Provider<ProspectivePdfService>(
  (_) => const ProspectivePdfService(),
);
