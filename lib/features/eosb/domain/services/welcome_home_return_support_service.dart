import 'package:raabta/features/disruption_readiness/data/disruption_readiness_catalog.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_readiness_models.dart';
import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/data/models/return_support_models.dart';
import 'package:raabta/features/eosb/domain/services/home_country_support_service.dart';

/// Resolves Welcome Home programme content from profile or session country id.
class WelcomeHomeReturnSupportService {
  const WelcomeHomeReturnSupportService();

  static const _homeCountry = HomeCountrySupportService();

  WelcomeHomeReturnSupportView resolve({
    required HomeCountryUserContext context,
    String? sessionCountryId,
  }) {
    final sessionId = sessionCountryId?.trim().toLowerCase();
    if (sessionId != null && sessionId.isNotEmpty) {
      return _viewForCatalogCountry(
        countryId: sessionId,
        homeState: context.homeState,
        matchKind: WelcomeHomeMatchKind.sessionCountry,
        forceRegion: null,
      );
    }

    if (!context.hasNationality) {
      return WelcomeHomeReturnSupportView(
        matchKind: WelcomeHomeMatchKind.noNationality,
        bundle: MigrantSupportCatalog.genericUnavailableBundle,
        fallbackLinks: const [],
      );
    }

    final supportView = _homeCountry.resolve(context);
    if (supportView.status == HomeCountrySupportStatus.supported &&
        supportView.countryId != null) {
      final countryId = supportView.countryId!;
      final regionId = _matchedKeralaRegionId(context);
      return _viewForCatalogCountry(
        countryId: countryId,
        homeState: context.homeState,
        matchKind: WelcomeHomeMatchKind.profileSupported,
        forceRegion: countryId == 'india' ? regionId : null,
      );
    }

    return WelcomeHomeReturnSupportView(
      matchKind: WelcomeHomeMatchKind.unsupportedNationality,
      countryDisplayNameKey: null,
      bundle: MigrantSupportCatalog.genericUnavailableBundle,
      fallbackLinks: _embassyFallbackForUnknownNationality(context.nationality),
    );
  }

  String? _matchedKeralaRegionId(HomeCountryUserContext context) {
    final india = MigrantSupportCatalog.india;
    final region = india.regions['kerala'];
    if (region == null) return null;
    final parsed = _parseIdentity(context.nationality, context.homeState);
    for (final r in india.regions.values) {
      if (_homeCountryMatchesRegion(parsed.homeState, r)) {
        return r.regionId;
      }
    }
    return null;
  }

  _ParsedIdentity _parseIdentity(String nationality, String homeState) {
    var nat = nationality.trim();
    var state = homeState.trim();
    if (state.isEmpty && nat.contains(',')) {
      final list = nat.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      if (list.length >= 2) {
        nat = list.first;
        state = list.sublist(1).join(', ');
      }
    }
    return _ParsedIdentity(nationality: nat, homeState: state);
  }

  bool _homeCountryMatchesRegion(String homeState, HomeCountrySupportRegionDef region) {
    final normalized = homeState.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (normalized == region.regionId) return true;
    for (final alias in region.regionAliases) {
      if (alias.trim().toLowerCase() == normalized) return true;
    }
    return false;
  }

  WelcomeHomeReturnSupportView _viewForCatalogCountry({
    required String countryId,
    required String homeState,
    required WelcomeHomeMatchKind matchKind,
    required String? forceRegion,
  }) {
    HomeCountrySupportCountryDef? countryDef;
    for (final c in MigrantSupportCatalog.countries) {
      if (c.countryId == countryId) {
        countryDef = c;
        break;
      }
    }

    final displayKey = countryDef?.displayNameKey;

    if (countryId == 'india') {
      final regionId = forceRegion ?? _regionForIndia(homeState);
      if (regionId == 'kerala') {
        return WelcomeHomeReturnSupportView(
          matchKind: matchKind,
          countryId: 'india',
          countryDisplayNameKey: displayKey,
          regionId: 'kerala',
          bundle: MigrantSupportCatalog.keralaReturnSupport,
          fallbackLinks: MigrantSupportCatalog.indiaConsularFallbacks,
        );
      }
      return WelcomeHomeReturnSupportView(
        matchKind: matchKind,
        countryId: 'india',
        countryDisplayNameKey: displayKey,
        bundle: MigrantSupportCatalog.indiaNationalUnavailableBundle,
        fallbackLinks: MigrantSupportCatalog.indiaConsularFallbacks,
      );
    }

    if (countryId == 'philippines') {
      return WelcomeHomeReturnSupportView(
        matchKind: matchKind,
        countryId: countryId,
        countryDisplayNameKey: displayKey,
        bundle: MigrantSupportCatalog.philippinesReturnSupport,
        fallbackLinks: const [],
      );
    }

    if (countryId == 'nepal') {
      return WelcomeHomeReturnSupportView(
        matchKind: matchKind,
        countryId: countryId,
        countryDisplayNameKey: displayKey,
        bundle: MigrantSupportCatalog.nepalReturnSupport,
        fallbackLinks: const [],
      );
    }

    return WelcomeHomeReturnSupportView(
      matchKind: matchKind,
      countryId: countryId,
      countryDisplayNameKey: displayKey,
      bundle: MigrantSupportCatalog.genericUnavailableBundle,
      fallbackLinks: _embassyFallbackForCountryId(countryId),
    );
  }

  String? _regionForIndia(String homeState) {
    final region = MigrantSupportCatalog.india.regions['kerala'];
    if (region == null) return null;
    if (_homeCountryMatchesRegion(homeState, region)) return 'kerala';
    return null;
  }

  List<ReturnSupportFallbackLinkDef> _embassyFallbackForUnknownNationality(
    String nationality,
  ) {
    final id = _guessEmbassyCountryId(nationality);
    if (id == null) return const [];
    return _embassyFallbackForCountryId(id);
  }

  String? _guessEmbassyCountryId(String nationality) {
    final lower = nationality.trim().toLowerCase();
    if (lower.contains('india')) return 'india';
    if (lower.contains('nepal')) return 'nepal';
    if (lower.contains('philipp') || lower.contains('filipino')) {
      return 'philippines';
    }
    if (lower.contains('bangladesh') || lower.contains('bengali')) {
      return 'bangladesh';
    }
    if (lower.contains('pakistan')) return 'pakistan';
    if (lower.contains('sri') || lower.contains('lanka')) return 'sri_lanka';
    return null;
  }

  List<ReturnSupportFallbackLinkDef> _embassyFallbackForCountryId(String countryId) {
    final entry = DisruptionEmbassyCatalog.forCountryId(countryId);
    if (entry == null ||
        entry.status != DisruptionEmbassyPortalStatus.verified ||
        entry.portalUrl == null) {
      return const [];
    }
    final titleKey = switch (entry.countryId) {
      'india' => 'wh_fallback_embassy_india_title',
      'nepal' => 'wh_fallback_embassy_nepal_title',
      'philippines' => 'wh_fallback_embassy_ph_title',
      _ => 'wh_fallback_embassy_generic_title',
    };
    return [
      ReturnSupportFallbackLinkDef(
        id: 'embassy_${entry.countryId}',
        titleKey: titleKey,
        descriptionKey: 'wh_fallback_embassy_desc',
        url: entry.portalUrl,
      ),
    ];
  }
}

class _ParsedIdentity {
  const _ParsedIdentity({required this.nationality, required this.homeState});

  final String nationality;
  final String homeState;
}
