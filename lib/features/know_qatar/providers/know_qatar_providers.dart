import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/know_qatar/data/know_qatar_catalog.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';
import 'package:raabta/features/know_qatar/domain/services/know_qatar_order_service.dart';
import 'package:raabta/features/know_qatar/domain/services/know_qatar_persona_service.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

final knowQatarSectionOrderProvider = Provider<List<String>>((ref) {
  final profile = ref.watch(userAIProfileProvider);
  final level = profile?.score.level;
  final persona = ref.watch(knowQatarPersonaProvider);
  return KnowQatarOrderService.resolveOrder(
    expatLifeLevel: level,
    persona: persona,
  );
});

final knowQatarSectionsProvider = Provider((ref) {
  final order = ref.watch(knowQatarSectionOrderProvider);
  return KnowQatarCatalog.visibleOrdered(order);
});

/// Computed fresh each time Know Qatar loads — never written to Firestore.
final knowQatarPersonaProvider = Provider<KnowQatarPersona>((ref) {
  final profile = ref.watch(userAIProfileProvider);
  final deadlines = ref.watch(documentDeadlinesProvider).valueOrNull ?? const [];
  final eosbHistory = ref.watch(eosbHistoryProvider).valueOrNull ?? const [];

  final deadlineSignals = KnowQatarPersonaService.fromDeadlines(deadlines);
  final industry = profile != null &&
          profile.advancedProfileConsentGiven &&
          profile.advancedProfile != null &&
          (profile.advancedProfile!.industry?.trim().isNotEmpty ?? false)
      ? profile.advancedProfile!.industry
      : null;

  return KnowQatarPersonaService.derivePersona(
    KnowQatarPersonaInput(
      deadlineDocumentTypes: deadlineSignals.deadlineDocumentTypes,
      deadlineGuideCategoryIds: deadlineSignals.deadlineGuideCategoryIds,
      deadlineDocumentLabels: deadlineSignals.deadlineDocumentLabels,
      hasCompletedEosbCalculation: eosbHistory.isNotEmpty,
      expatLifeLevel: profile?.score.level,
      advancedProfileIndustry: industry,
    ),
  );
});

final knowQatarInitialSectionKeyProvider = Provider<String?>((ref) {
  ref.watch(knowQatarSectionOrderProvider);
  return null;
});

/// Published section keys for deep-link validation.
final knowQatarVisibleSectionKeysProvider = Provider<Set<String>>((ref) {
  final sections = ref.watch(knowQatarSectionsProvider);
  return sections.map((s) => s.sectionKey).toSet();
});
