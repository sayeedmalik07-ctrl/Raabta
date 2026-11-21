import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_catalog.dart';
import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_multilingual_matcher.dart';

/// Deterministic contract/offer scam-template scan (Phase 33) — no AI, no network.
abstract final class ContractScamPatternEngine {
  static ContractScamPatternResult scan({
    required String text,
    ContractScamPatternDomain domain = ContractScamPatternDomain.any,
    String? offerText,
    String? contractText,
  }) {
    final trimmed = text.trim();
    if (trimmed.length < 20) {
      return ContractScamPatternResult.empty;
    }

    final findings = <ContractScamPatternFinding>[];

    for (final group in ContractScamPatternCatalog.groups) {
      if (!_domainApplies(group.domain, domain, trimmed)) continue;
      if (!_matchesPositive(trimmed, group)) continue;
      if (_matchesAny(trimmed, group.negativePatterns)) continue;

      findings.add(
        ContractScamPatternFinding(
          groupId: group.id,
          categoryKey: group.categoryKey,
          wordingKey: group.wordingKey,
          sourceLabelKey: group.sourceLabelKey,
          nextStep: group.nextStep,
          priority: group.priority,
        ),
      );
    }

    final offer = offerText?.trim() ?? '';
    final contract = contractText?.trim() ?? '';
    if (offer.length >= 20 && contract.length >= 20) {
      final oSalary = _extractSalaryFigure(offer);
      final cSalary = _extractSalaryFigure(contract);
      if (oSalary != null && cSalary != null && oSalary != cSalary) {
        findings.add(
          const ContractScamPatternFinding(
            groupId: 'offer_contract_mismatch',
            categoryKey: 'cop_cat_mismatch',
            wordingKey: 'cop_find_mismatch',
            sourceLabelKey: 'cop_source_pattern',
            nextStep: ContractScamPatternNextStep.beforeYouSign,
            priority: 22,
          ),
        );
      }
    }

    findings.sort((a, b) => a.priority.compareTo(b.priority));
    final capped = findings.take(ContractScamPatternCatalog.maxFindings).toList();

    return ContractScamPatternResult(
      findings: capped,
      scannedCharacterCount: trimmed.length,
    );
  }

  static bool _domainApplies(
    ContractScamPatternDomain groupDomain,
    ContractScamPatternDomain requested,
    String text,
  ) {
    if (groupDomain == ContractScamPatternDomain.any) return true;
    if (requested != ContractScamPatternDomain.any) {
      return groupDomain == requested ||
          requested == ContractScamPatternDomain.any;
    }
    final lower = text.toLowerCase();
    final housingHint = lower.contains('rent') ||
        lower.contains('landlord') ||
        lower.contains('tenancy') ||
        lower.contains('lease') ||
        lower.contains('flat') ||
        lower.contains('apartment') ||
        lower.contains('إيجار');
    final employmentHint = lower.contains('employment') ||
        lower.contains('salary') ||
        lower.contains('visa') ||
        lower.contains('worker') ||
        lower.contains('job offer');
    if (groupDomain == ContractScamPatternDomain.housing) return true;
    if (groupDomain == ContractScamPatternDomain.employment) {
      if (housingHint && !employmentHint) return false;
      return true;
    }
    return true;
  }

  static bool _matchesPositive(String text, ContractScamPatternGroupDef group) {
    for (final p in group.resolvePositivePatterns()) {
      if (ScamMultilingualMatcher.containsPattern(text, p)) return true;
    }
    return false;
  }

  static bool _matchesAny(String text, List<String> patterns) {
    for (final p in patterns) {
      if (ScamMultilingualMatcher.containsPattern(text, p)) return true;
    }
    return false;
  }

  static int? _extractSalaryFigure(String text) {
    final match = RegExp(
      r'(?:qr|qar|riyal|salary| wage)\s*[:.]?\s*(\d[\d,]{2,})',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll(',', '');
    return int.tryParse(raw);
  }
}
