import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';
import 'package:raabta/models/visa_models.dart';

/// Pure client-side persona derivation — zero AI, zero Firestore writes.
abstract final class KnowQatarPersonaService {
  /// Priority: Family → Working Resident → New Resident → Visitor.
  static KnowQatarPersona derivePersona(KnowQatarPersonaInput input) {
    if (_hasFamilyVisaSignal(input)) return KnowQatarPersona.family;
    if (input.hasCompletedEosbCalculation) {
      return KnowQatarPersona.workingResident;
    }
    if (_hasAdvancedIndustrySignal(input.advancedProfileIndustry)) {
      return KnowQatarPersona.workingResident;
    }
    if (_isNewResidentSignal(input.expatLifeLevel)) {
      return KnowQatarPersona.newResident;
    }
    return KnowQatarPersona.visitor;
  }

  static KnowQatarPersonaInput fromDeadlines(List<DocumentDeadline> deadlines) {
    return KnowQatarPersonaInput(
      deadlineDocumentTypes: deadlines
          .map((d) => d.typeId ?? d.documentType)
          .where((s) => s.trim().isNotEmpty)
          .toList(growable: false),
      deadlineGuideCategoryIds: deadlines
          .map((d) => d.guideCategoryId)
          .where((s) => s.trim().isNotEmpty)
          .toList(growable: false),
      deadlineDocumentLabels: deadlines
          .where((d) => !d.isVisitVisaEntry)
          .map((d) => d.documentType)
          .where((s) => s.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  /// Family Visa is not a separate picker type — Visit Visa links to the
  /// `family_visa` guide; legacy entries may label documents with "family".
  static bool _hasFamilyVisaSignal(KnowQatarPersonaInput input) {
    for (final guideId in input.deadlineGuideCategoryIds) {
      if (guideId.trim().toLowerCase() == 'family_visa') return true;
    }
    for (final type in input.deadlineDocumentTypes) {
      final normalized = type.trim().toLowerCase();
      if (normalized == 'visitvisa' ||
          normalized == 'visit_visa' ||
          normalized == 'family visa') {
        return true;
      }
    }
    for (final label in input.deadlineDocumentLabels) {
      final lower = label.toLowerCase();
      if (lower.contains('family visa') ||
          (lower.contains('family') && lower.contains('visa'))) {
        return true;
      }
    }
    return false;
  }

  static bool _hasAdvancedIndustrySignal(String? industry) {
    return industry != null && industry.trim().isNotEmpty;
  }

  /// Reuses Phase 1 Decision-5 signal: [ExpatLifeScore.level] from profile.
  static bool _isNewResidentSignal(String? expatLifeLevel) {
    final level = expatLifeLevel?.trim().toLowerCase() ?? '';
    if (level.isEmpty) return false;
    return level.contains('new') || level.contains('arrival');
  }

  static String bannerKeyFor(KnowQatarPersona persona) {
    switch (persona) {
      case KnowQatarPersona.visitor:
        return 'kq_persona_banner_visitor';
      case KnowQatarPersona.newResident:
        return 'kq_persona_banner_new_resident';
      case KnowQatarPersona.workingResident:
        return 'kq_persona_banner_working_resident';
      case KnowQatarPersona.family:
        return 'kq_persona_banner_family';
    }
  }
}
