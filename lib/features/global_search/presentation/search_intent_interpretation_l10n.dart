import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/global_search/domain/search_intent_interpretation.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Resolves [SearchIntentInterpretation] segments into localized display text.
abstract final class SearchIntentInterpretationL10n {
  static String headerKey(SearchIntentInterpretationHeader header) {
    return switch (header) {
      SearchIntentInterpretationHeader.lookingFor =>
        'global_search_intent_looking_for',
      SearchIntentInterpretationHeader.searching =>
        'global_search_intent_searching',
    };
  }

  static String segmentLabel(
    SearchIntentInterpretationSegment segment,
    String locale,
  ) {
    return switch (segment) {
      SearchIntentInterpretationIntentSegment(:final intent) =>
        _intentLabel(intent, locale),
      SearchIntentInterpretationAreaSegment(:final area) => area,
      SearchIntentInterpretationNearMeSegment() =>
        AppShellStrings.t('global_search_intent_near_me', locale),
      SearchIntentInterpretationMaxPriceSegment(:final amount) =>
        AppShellStrings.format(
          'global_search_intent_under_qar',
          locale,
          params: {'amount': amount.toString()},
        ),
      SearchIntentInterpretationMinPriceSegment(:final amount) =>
        AppShellStrings.format(
          'global_search_intent_from_qar',
          locale,
          params: {'amount': amount.toString()},
        ),
      SearchIntentInterpretationBedroomsSegment(:final count) =>
        AppShellStrings.format(
          'global_search_intent_bedrooms',
          locale,
          params: {'count': count.toString()},
        ),
      SearchIntentInterpretationTextSegment(:final value) => value,
      SearchIntentInterpretationCurrencyPairSegment(
        :final from,
        :final to,
        :final amount,
      ) =>
        amount != null && amount > 0
            ? AppShellStrings.format(
                'global_search_intent_currency_amount',
                locale,
                params: {
                  'amount': _formatAmount(amount),
                  'from': from.toUpperCase(),
                  'to': to.toUpperCase(),
                },
              )
            : AppShellStrings.format(
                'global_search_intent_currency_pair',
                locale,
                params: {
                  'from': from.toUpperCase(),
                  'to': to.toUpperCase(),
                },
              ),
    };
  }

  static String _intentLabel(SearchIntent intent, String locale) {
    final key = switch (intent) {
      SearchIntent.findJob => 'global_search_intent_label_jobs',
      SearchIntent.findHousing => 'global_search_intent_label_housing',
      SearchIntent.findBusiness => 'global_search_intent_label_business',
      SearchIntent.findService => 'global_search_intent_label_service',
      SearchIntent.findDoctor => 'global_search_intent_label_doctor',
      SearchIntent.checkRate => 'global_search_intent_label_money',
      SearchIntent.visaQuestion => 'global_search_intent_label_visa',
      SearchIntent.communityQuestion =>
        'global_search_intent_label_community',
      SearchIntent.eosbCalculator => 'global_search_intent_label_eosb',
      SearchIntent.prayerMosque => 'global_search_intent_label_prayer',
      SearchIntent.tripPlanner => 'global_search_intent_label_trip',
      SearchIntent.verifyEmployer =>
        'global_search_intent_label_verify_employer',
      SearchIntent.verifyAgency => 'global_search_intent_label_verify_agency',
      SearchIntent.scanDocument => 'global_search_intent_label_scan_document',
      SearchIntent.unknown => 'global_search_intent_label_search',
    };
    return AppShellStrings.t(key, locale);
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
