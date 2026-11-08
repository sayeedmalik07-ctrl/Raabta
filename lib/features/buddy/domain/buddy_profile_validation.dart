import 'package:raabta/features/buddy/domain/buddy_area_codes.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_interest_taxonomy.dart';
import 'package:raabta/features/buddy/domain/buddy_spoken_languages.dart';
import 'package:raabta/features/buddy/domain/buddy_supported_countries.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';

enum BuddyValidationError {
  missingUid,
  nicknameEmpty,
  nicknameTooLong,
  noActiveRole,
  invalidCountryId,
  noSpokenLanguages,
  tooManySpokenLanguages,
  invalidSpokenLanguage,
  invalidAreaCode,
  invalidYearsBand,
  helperIneligibleTenure,
  tooManyInterests,
  invalidInterest,
  missingConsentVersion,
  invalidConsentVersion,
  missingAdultAttestation,
}

abstract final class BuddyProfileValidation {
  static List<BuddyValidationError> validate(BuddyProfile profile) {
    final errors = <BuddyValidationError>[];

    if (profile.uid.trim().isEmpty) {
      errors.add(BuddyValidationError.missingUid);
    }

    final nick = profile.displayNickname.trim();
    if (nick.isEmpty) {
      errors.add(BuddyValidationError.nicknameEmpty);
    } else if (nick.length > BuddyConstants.maxNicknameLength) {
      errors.add(BuddyValidationError.nicknameTooLong);
    }

    if (!profile.isNewcomer && !profile.isHelper) {
      errors.add(BuddyValidationError.noActiveRole);
    }

    if (!BuddySupportedCountries.isSupportedCountryId(profile.nationalityCountryId)) {
      errors.add(BuddyValidationError.invalidCountryId);
    }

    if (profile.spokenLanguageCodes.isEmpty) {
      errors.add(BuddyValidationError.noSpokenLanguages);
    } else if (profile.spokenLanguageCodes.length >
        BuddyConstants.maxSpokenLanguages) {
      errors.add(BuddyValidationError.tooManySpokenLanguages);
    } else {
      for (final code in profile.spokenLanguageCodes) {
        if (!BuddySpokenLanguages.allowedCodes.contains(code)) {
          errors.add(BuddyValidationError.invalidSpokenLanguage);
          break;
        }
      }
    }

    if (!BuddyAreaCodes.isValid(profile.areaCode)) {
      errors.add(BuddyValidationError.invalidAreaCode);
    }

    if (!BuddyConstants.allYearsBands.contains(profile.yearsInQatarBand)) {
      errors.add(BuddyValidationError.invalidYearsBand);
    }

    if (profile.isHelper &&
        !BuddyConstants.helperEligibleYearsBands
            .contains(profile.yearsInQatarBand)) {
      errors.add(BuddyValidationError.helperIneligibleTenure);
    }

    if (profile.interestTagIds.length > BuddyConstants.maxInterestTags) {
      errors.add(BuddyValidationError.tooManyInterests);
    } else {
      for (final id in profile.interestTagIds) {
        if (!BuddyInterestTaxonomy.allowedIds.contains(id)) {
          errors.add(BuddyValidationError.invalidInterest);
          break;
        }
      }
    }

    if (profile.consentVersion.trim().isEmpty) {
      errors.add(BuddyValidationError.missingConsentVersion);
    } else if (profile.consentVersion != BuddyConstants.consentVersion) {
      errors.add(BuddyValidationError.invalidConsentVersion);
    }

    if (profile.adultAttestationAt == null) {
      errors.add(BuddyValidationError.missingAdultAttestation);
    }

    return errors;
  }

  static bool isValid(BuddyProfile profile) => validate(profile).isEmpty;

  /// Part A matching discoverability — excludes paused and role-less profiles.
  static bool isDiscoverable(BuddyProfile profile) {
    if (profile.paused) return false;
    if (!profile.isNewcomer && !profile.isHelper) return false;
    return isValid(profile);
  }

  static bool isDiscoverableHelper(BuddyProfile profile) {
    return profile.isHelper && isDiscoverable(profile);
  }
}
