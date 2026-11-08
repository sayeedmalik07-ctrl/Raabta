import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';

/// Resolves static migrant support content from nationality + optional state.
class HomeCountrySupportService {
  const HomeCountrySupportService();

  HomeCountrySupportView resolve(HomeCountryUserContext context) {
    final nationality = context.nationality.trim();
    if (nationality.isEmpty) {
      return const HomeCountrySupportView.hidden();
    }

    final parsed = _parseNationalityAndState(nationality, context.homeState);
    final country = _matchCountry(parsed.nationality);
    if (country == null) {
      return HomeCountrySupportView.comingSoon(
        countryLabel: parsed.nationality,
        qatarProcedureChannels: MigrantSupportCatalog.qatarProcedureChannels,
      );
    }

    final regions = <HomeCountrySupportRegionDef>[];
    if (parsed.homeState.isNotEmpty) {
      for (final region in country.regions.values) {
        if (_matchesRegion(parsed.homeState, region)) {
          regions.add(region);
        }
      }
    }

    return HomeCountrySupportView.supported(
      countryId: country.countryId,
      nationalResources: country.nationalResources,
      regionalSections: regions,
      qatarProcedureChannels: MigrantSupportCatalog.qatarProcedureChannels,
    );
  }

  BeforeYouSignView resolveBeforeYouSign(HomeCountryUserContext context) {
    final nationality = context.nationality.trim();
    if (nationality.isEmpty) {
      return const BeforeYouSignView.hidden();
    }

    final parsed = _parseNationalityAndState(nationality, context.homeState);
    final country = _matchCountry(parsed.nationality);
    final checklist = country?.beforeYouSign;
    if (checklist == null) {
      return const BeforeYouSignView.hidden();
    }

    return BeforeYouSignView.supported(
      countryId: country!.countryId,
      checklist: checklist,
      offerAuthenticityChecklist:
          MigrantSupportCatalog.offerAuthenticityChecklist,
      qatarVerificationChannels: MigrantSupportCatalog.qatarVerificationChannels,
    );
  }

  _ParsedIdentity _parseNationalityAndState(
    String nationality,
    String homeState,
  ) {
    var nat = nationality.trim();
    var state = homeState.trim();

    if (state.isEmpty && nat.contains(',')) {
      final parts = nat.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
      final list = parts.toList();
      if (list.length >= 2) {
        nat = list.first;
        state = list.sublist(1).join(', ');
      }
    }

    if (state.isEmpty && nat.contains(' - ')) {
      final parts = nat.split(' - ').map((p) => p.trim()).where((p) => p.isNotEmpty);
      final list = parts.toList();
      if (list.length >= 2) {
        nat = list.first;
        state = list.sublist(1).join(' - ');
      }
    }

    return _ParsedIdentity(nationality: nat, homeState: state);
  }

  HomeCountrySupportCountryDef? _matchCountry(String nationality) {
    final normalized = _normalize(nationality);
    for (final country in MigrantSupportCatalog.countries) {
      for (final alias in country.nationalityAliases) {
        if (_normalize(alias) == normalized) return country;
      }
    }
    return null;
  }

  bool _matchesRegion(String homeState, HomeCountrySupportRegionDef region) {
    final normalized = _normalize(homeState);
    if (_normalize(region.regionId) == normalized) return true;
    for (final alias in region.regionAliases) {
      if (_normalize(alias) == normalized) return true;
    }
    return false;
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class _ParsedIdentity {
  const _ParsedIdentity({required this.nationality, required this.homeState});

  final String nationality;
  final String homeState;
}
