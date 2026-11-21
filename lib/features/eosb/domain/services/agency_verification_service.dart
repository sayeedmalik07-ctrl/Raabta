import 'package:raabta/features/eosb/data/agency_verification_catalog.dart';
import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/features/eosb/data/models/agency_verification_models.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/domain/services/home_country_support_service.dart';

/// Resolves agency-verification portal routing from nationality / country id.
///
/// Reuses [HomeCountrySupportService] country matching — no duplicate nationality logic.
class AgencyVerificationService {
  const AgencyVerificationService();

  static const _homeCountry = HomeCountrySupportService();

  AgencyVerificationView resolve(HomeCountryUserContext context) {
    final nationality = context.nationality.trim();
    if (nationality.isEmpty) {
      return const AgencyVerificationView.noCountrySelected();
    }

    final view = _homeCountry.resolve(context);
    if (view.status == HomeCountrySupportStatus.supported &&
        view.countryId != null) {
      return resolveByCountryId(view.countryId!);
    }

    return AgencyVerificationView.notYetConfirmed(
      countryId: nationality.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
      countryDisplayNameKey: null,
      notConfirmedReasonKey: 'agency_verify_generic_not_confirmed',
    );
  }

  AgencyVerificationView resolveByCountryId(String countryId) {
    final normalized = countryId.trim().toLowerCase();
    HomeCountrySupportCountryDef? countryDef;
    for (final country in MigrantSupportCatalog.countries) {
      if (country.countryId == normalized) {
        countryDef = country;
        break;
      }
    }

    final displayKey = countryDef?.displayNameKey;
    final entry = AgencyVerificationCatalog.entryForCountryId(normalized);

    if (entry == null) {
      return AgencyVerificationView.notYetConfirmed(
        countryId: normalized,
        countryDisplayNameKey: displayKey,
        notConfirmedReasonKey: 'agency_verify_generic_not_confirmed',
      );
    }

    if (entry.status == AgencyVerificationPortalStatus.verified &&
        entry.portal != null) {
      return AgencyVerificationView.verified(
        countryId: normalized,
        countryDisplayNameKey: displayKey,
        portal: entry.portal!,
      );
    }

    return AgencyVerificationView.notYetConfirmed(
      countryId: normalized,
      countryDisplayNameKey: displayKey,
      notConfirmedReasonKey:
          entry.notConfirmedReasonKey ?? 'agency_verify_generic_not_confirmed',
    );
  }
}
