import 'package:raabta/features/scam_shield/check_number/calling_code_catalog.dart';
import 'package:raabta/features/scam_shield/check_number/qatar_numbering_catalog.dart';
import 'package:scam_shield_core/features/scam_shield/check_number/number_facts.dart';
import 'package:scam_shield_core/features/scam_shield/check_number/number_normalizer.dart';

abstract final class NumberFactsParser {
  static Future<NumberFacts> parse(String rawInput) async {
    final plan = await QatarNumberingCatalog.load();
    await CallingCodeCatalog.load();

    final stripped = NumberNormalizer.stripToDialChars(rawInput.trim());
    if (stripped.isEmpty) {
      return const NumberFacts(
        type: NumberFactType.invalid,
        normalizedE164: null,
        displayNational: '',
      );
    }

    if (RegExp(r'^\d{1,5}$').hasMatch(stripped)) {
      return NumberFacts(
        type: NumberFactType.shortCode,
        normalizedE164: null,
        displayNational: stripped,
      );
    }

    var digits = stripped;
    if (digits.startsWith('+')) digits = digits.substring(1);
    digits = digits.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith(plan.countryCallingCode)) {
      final national = digits.substring(plan.countryCallingCode.length);
      return _classifyQatarNational(
        national: national,
        plan: plan,
      );
    }

    if (digits.length == plan.nationalSignificantLength &&
        !digits.startsWith('0')) {
      return _classifyQatarNational(national: digits, plan: plan);
    }

    final match = CallingCodeCatalog.matchLongestCode(digits);
    if (match != null && match.code != plan.countryCallingCode) {
      return NumberFacts(
        type: NumberFactType.international,
        normalizedE164: '+$digits',
        displayNational: digits,
        internationalCountryEn: match.countryEn,
        internationalCountryAr: match.countryAr,
      );
    }

    if (digits.length >= 8) {
      return NumberFacts(
        type: NumberFactType.international,
        normalizedE164: '+$digits',
        displayNational: digits,
        internationalCountryEn: 'Unknown',
        internationalCountryAr: 'Unknown',
      );
    }

    return NumberFacts(
      type: NumberFactType.invalid,
      normalizedE164: null,
      displayNational: stripped,
    );
  }

  static NumberFacts _classifyQatarNational({
    required String national,
    required QatarNumberingPlan plan,
  }) {
    if (national.length != plan.nationalSignificantLength) {
      return NumberFacts(
        type: NumberFactType.invalid,
        normalizedE164: '+${plan.countryCallingCode}$national',
        displayNational: national,
        numberingPlanVerified: plan.verified,
      );
    }

    final e164 = '+${plan.countryCallingCode}$national';
    if (!plan.verified) {
      return NumberFacts(
        type: NumberFactType.qatarNationalUnverified,
        normalizedE164: e164,
        displayNational: national,
        numberingPlanVerified: false,
      );
    }

    final lead = national.substring(0, 1);
    if (plan.mobileLeadingDigits.contains(lead)) {
      return NumberFacts(
        type: NumberFactType.qatarMobile,
        normalizedE164: e164,
        displayNational: national,
        numberingPlanVerified: true,
      );
    }
    if (lead == plan.landlineLeadingDigit) {
      return NumberFacts(
        type: NumberFactType.qatarLandline,
        normalizedE164: e164,
        displayNational: national,
        numberingPlanVerified: true,
      );
    }
    return NumberFacts(
      type: NumberFactType.qatarNationalUnverified,
      normalizedE164: e164,
      displayNational: national,
      numberingPlanVerified: true,
    );
  }
}
