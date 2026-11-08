import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/data/moph_insurer_lookup_catalog.dart';
import 'package:raabta/features/health_insurance/domain/models/insurer_regulatory_body.dart';

/// Resolves user-entered insurer / TPA / plan names to underlying MOPH insurers.
class InsurerLookupService {
  const InsurerLookupService({required this.snapshot});

  final MophInsurerLookupSnapshot snapshot;

  /// Whether [name] matches a MOPH-licensed insurer (direct or alias).
  bool isRegisteredInsurer(String name) {
    final resolved = _resolveDirectOrAlias(name);
    return resolved != null;
  }

  /// Regulator routing for claim denial escalation — defaults to QCB.
  InsurerRegulatoryBody resolveRegulatoryBody({
    required String insurerName,
    required String cardLabel,
    bool manualReview = false,
  }) {
    if (manualReview) return InsurerRegulatoryBody.qcb;

    final candidates = <String>{
      if (insurerName.trim().isNotEmpty) insurerName.trim(),
      if (cardLabel.trim().isNotEmpty) cardLabel.trim(),
      if (insurerName.trim().isNotEmpty)
        _resolveDirectOrAlias(insurerName.trim()) ?? '',
      if (cardLabel.trim().isNotEmpty)
        _resolveDirectOrAlias(cardLabel.trim()) ?? '',
    }..removeWhere((s) => s.isEmpty);

    for (final name in candidates) {
      final normalized = MophInsurerLookupCatalog.normalize(name);
      for (final qfc in snapshot.qfcRegisteredInsurers) {
        if (MophInsurerLookupCatalog.normalize(qfc) == normalized ||
            normalized.contains(MophInsurerLookupCatalog.normalize(qfc)) ||
            MophInsurerLookupCatalog.normalize(qfc).contains(normalized)) {
          return InsurerRegulatoryBody.qfcra;
        }
      }
      for (final entry in snapshot.insurerRegulatoryBodies.entries) {
        if (MophInsurerLookupCatalog.normalize(entry.key) == normalized) {
          return InsurerRegulatoryBodyX.fromStorage(entry.value);
        }
      }
    }

    return InsurerRegulatoryBody.qcb;
  }

  /// Full lookup with TPA/plan mapping and user-facing messaging.
  InsurerLookupResult resolve(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const InsurerLookupResult(
        query: '',
        matchType: InsurerLookupMatchType.notFound,
      );
    }

    final direct = _resolveDirectOrAlias(trimmed);
    if (direct != null) {
      final type = _isDirectInsurer(trimmed)
          ? InsurerLookupMatchType.directInsurer
          : InsurerLookupMatchType.aliasMatch;
      return InsurerLookupResult(
        query: trimmed,
        matchType: type,
        resolvedInsurerName: direct,
        cardLabel: trimmed,
        isMophRegistered: true,
        userMessage: type == InsurerLookupMatchType.directInsurer
            ? '$direct — MOPH-registered ✓'
            : '$trimmed is registered as $direct — MOPH-registered ✓',
      );
    }

    final tpaMatch = _matchTpaOrPlan(trimmed);
    if (tpaMatch != null) {
      return _resultFromTpaMapping(trimmed, tpaMatch);
    }

    return InsurerLookupResult(
      query: trimmed,
      matchType: InsurerLookupMatchType.notFound,
      cardLabel: trimmed,
      userMessage:
          'We could not match "$trimmed" to a known MOPH insurer or plan — use manual review below.',
    );
  }

  /// Explicit manual-review path when user cannot find their card label.
  InsurerLookupResult manualReview(String freeText) {
    final trimmed = freeText.trim();
    return InsurerLookupResult(
      query: trimmed,
      matchType: InsurerLookupMatchType.manualReview,
      cardLabel: trimmed,
      userMessage:
          '"$trimmed" will be noted for manual review — compliance check cannot auto-verify MOPH registration until the catalogue is updated.',
    );
  }

  /// Suggestions for autocomplete (insurers + TPA/plan display names).
  List<InsurerLookupSuggestion> suggest(String query, {int limit = 12}) {
    final normalized = MophInsurerLookupCatalog.normalize(query);
    if (normalized.isEmpty) {
      return _allSuggestions().take(limit).toList();
    }

    final matches = <InsurerLookupSuggestion>[];
    for (final insurer in snapshot.insurers) {
      if (MophInsurerLookupCatalog.normalize(insurer).contains(normalized)) {
        matches.add(InsurerLookupSuggestion(
          label: insurer,
          kind: InsurerSuggestionKind.insurer,
          underlyingInsurer: insurer,
        ));
      }
    }
    for (final entry in snapshot.insurerAliases.entries) {
      if (entry.key.contains(normalized)) {
        matches.add(InsurerLookupSuggestion(
          label: entry.key,
          subtitle: entry.value,
          kind: InsurerSuggestionKind.alias,
          underlyingInsurer: entry.value,
        ));
      }
    }
    for (final mapping in snapshot.tpaMappings) {
      final names = [mapping.displayName, ...mapping.aliases];
      if (names.any((n) => MophInsurerLookupCatalog.normalize(n).contains(normalized))) {
        matches.add(InsurerLookupSuggestion(
          label: mapping.displayName,
          subtitle: mapping.isTpa ? 'Third-Party Administrator (TPA)' : 'Branded plan',
          kind: mapping.isTpa
              ? InsurerSuggestionKind.tpa
              : InsurerSuggestionKind.brandedPlan,
          underlyingInsurer: mapping.underlyingInsurers.length == 1
              ? mapping.underlyingInsurers.first
              : null,
          mapping: mapping,
        ));
      }
    }
    return matches.take(limit).toList();
  }

  List<InsurerLookupSuggestion> _allSuggestions() {
    final out = <InsurerLookupSuggestion>[];
    for (final i in snapshot.insurers) {
      out.add(InsurerLookupSuggestion(
        label: i,
        kind: InsurerSuggestionKind.insurer,
        underlyingInsurer: i,
      ));
    }
    for (final m in snapshot.tpaMappings) {
      out.add(InsurerLookupSuggestion(
        label: m.displayName,
        subtitle: m.isTpa ? 'TPA' : 'Branded plan',
        kind: m.isTpa ? InsurerSuggestionKind.tpa : InsurerSuggestionKind.brandedPlan,
        underlyingInsurer:
            m.underlyingInsurers.length == 1 ? m.underlyingInsurers.first : null,
        mapping: m,
      ));
    }
    return out;
  }

  InsurerLookupResult _resultFromTpaMapping(String query, TpaOrPlanMapping mapping) {
    if (mapping.isBrandedPlan && mapping.underlyingInsurers.length == 1) {
      final insurer = mapping.underlyingInsurers.first;
      return InsurerLookupResult(
        query: query,
        matchType: InsurerLookupMatchType.brandedPlan,
        resolvedInsurerName: insurer,
        cardLabel: query,
        isMophRegistered: true,
        userMessage:
            '${mapping.displayName} is a plan from $insurer — MOPH-registered ✓',
      );
    }

    if (mapping.underlyingInsurers.length == 1) {
      final insurer = mapping.underlyingInsurers.first;
      return InsurerLookupResult(
        query: query,
        matchType: InsurerLookupMatchType.tpaMapped,
        resolvedInsurerName: insurer,
        cardLabel: query,
        isMophRegistered: true,
        userMessage:
            '${mapping.displayName} is a TPA — your underlying insurer appears to be $insurer (MOPH-registered ✓). Confirm on your policy or with HR.',
      );
    }

    return InsurerLookupResult(
      query: query,
      matchType: InsurerLookupMatchType.tpaAmbiguous,
      cardLabel: query,
      possibleInsurers: mapping.underlyingInsurers,
      userMessage:
          '${mapping.displayName} is a Third-Party Administrator (TPA), not a MOPH-licensed insurer itself. '
          'It administers claims for various underlying insurers — ask HR or check your policy for the actual insurer name.',
    );
  }

  TpaOrPlanMapping? _matchTpaOrPlan(String query) {
    final n = MophInsurerLookupCatalog.normalize(query);
    for (final mapping in snapshot.tpaMappings) {
      final names = [
        mapping.displayName,
        ...mapping.aliases,
      ].map(MophInsurerLookupCatalog.normalize);
      if (names.any((name) => name == n || name.contains(n) || n.contains(name))) {
        return mapping;
      }
    }
    return null;
  }

  String? _resolveDirectOrAlias(String query) {
    final n = MophInsurerLookupCatalog.normalize(query);
    for (final insurer in snapshot.insurers) {
      if (MophInsurerLookupCatalog.normalize(insurer) == n) return insurer;
    }
    final alias = snapshot.insurerAliases[n];
    if (alias != null) return alias;
    for (final entry in snapshot.insurerAliases.entries) {
      if (n.contains(entry.key) || entry.key.contains(n)) return entry.value;
    }
    return null;
  }

  bool _isDirectInsurer(String query) {
    final n = MophInsurerLookupCatalog.normalize(query);
    return snapshot.insurers
        .any((i) => MophInsurerLookupCatalog.normalize(i) == n);
  }
}

enum InsurerSuggestionKind { insurer, alias, tpa, brandedPlan }

class InsurerLookupSuggestion {
  const InsurerLookupSuggestion({
    required this.label,
    required this.kind,
    this.subtitle,
    this.underlyingInsurer,
    this.mapping,
  });

  final String label;
  final String? subtitle;
  final InsurerSuggestionKind kind;
  final String? underlyingInsurer;
  final TpaOrPlanMapping? mapping;
}
