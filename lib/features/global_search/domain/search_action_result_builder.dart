import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/employer_track_record_lookup_screen.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Converts [SearchAnalysis] into zero or more high-intent action results (S2).
///
/// Deterministic, pure, and independent of UI / Firestore / AI.
abstract final class SearchActionResultBuilder {
  static const confidenceThreshold = 0.70;

  static const _corridorCurrencies = {'INR', 'PKR', 'BDT', 'NPR', 'PHP'};

  static List<GlobalSearchResultItem> build({
    required SearchAnalysis analysis,
    required String locale,
  }) {
    final items = <GlobalSearchResultItem>[];

    final eosb = _buildEosbAction(analysis, locale);
    if (eosb != null) items.add(eosb);

    final scanner = _buildScannerAction(analysis, locale);
    if (scanner != null) items.add(scanner);

    final employer = _buildEmployerVerifyAction(analysis, locale);
    if (employer != null) items.add(employer);

    final agency = _buildAgencyVerifyAction(analysis, locale);
    if (agency != null) items.add(agency);

    final currency = _buildCurrencyAction(analysis, locale);
    if (currency != null) items.add(currency);

    return items;
  }

  static GlobalSearchResultItem? _buildEosbAction(
    SearchAnalysis analysis,
    String locale,
  ) {
    if (!_isEosbCalculateCommand(analysis)) return null;
    if (!_meetsThreshold(
      analysis,
      isExactCommand: _isExactEosbCommand(analysis.normalizedQuery),
    )) {
      return null;
    }

    return GlobalSearchResultItem(
      id: 'action_calculate_eosb',
      category: GlobalSearchCategory.actions,
      title: AppShellStrings.t('global_search_action_eosb_title', locale),
      subtitle: AppShellStrings.t('global_search_action_eosb_subtitle', locale),
      routePath: '/eosb/employee-info',
      score: 1000,
      resultKind: GlobalSearchResultKind.calculation,
      actionId: SearchActionId.calculateEosb,
      confidence: analysis.confidence,
    );
  }

  static GlobalSearchResultItem? _buildScannerAction(
    SearchAnalysis analysis,
    String locale,
  ) {
    if (analysis.intent != SearchIntent.scanDocument) return null;
    if (!_meetsThreshold(
      analysis,
      isExactCommand: _isExactScannerCommand(analysis.normalizedQuery),
    )) {
      return null;
    }

    return GlobalSearchResultItem(
      id: 'action_scan_document',
      category: GlobalSearchCategory.actions,
      title: AppShellStrings.t('global_search_action_scan_title', locale),
      subtitle: AppShellStrings.t('global_search_action_scan_subtitle', locale),
      routePath: '/scanner/capture',
      score: 990,
      resultKind: GlobalSearchResultKind.action,
      actionId: SearchActionId.scanDocument,
      confidence: analysis.confidence,
    );
  }

  static GlobalSearchResultItem? _buildEmployerVerifyAction(
    SearchAnalysis analysis,
    String locale,
  ) {
    final employer = analysis.employerName?.trim();
    if (employer == null || employer.isEmpty) return null;
    if (analysis.intent != SearchIntent.verifyEmployer &&
        !_hasEmployerVerifyCue(analysis.normalizedQuery)) {
      return null;
    }
    if (!_meetsThreshold(analysis, isExactCommand: false)) {
      return null;
    }

    final route = EmployerTrackRecordLookupScreen.route(employerName: employer);
    return GlobalSearchResultItem(
      id: 'action_verify_employer',
      category: GlobalSearchCategory.actions,
      title: AppShellStrings.t('global_search_action_employer_title', locale),
      subtitle: AppShellStrings.format(
        'global_search_action_employer_subtitle',
        locale,
        params: {'employer': employer},
      ),
      routePath: route,
      score: 980,
      resultKind: GlobalSearchResultKind.action,
      actionId: SearchActionId.verifyEmployer,
      queryParameters: {'employer': employer},
      confidence: analysis.confidence,
    );
  }

  static GlobalSearchResultItem? _buildAgencyVerifyAction(
    SearchAnalysis analysis,
    String locale,
  ) {
    if (analysis.intent != SearchIntent.verifyAgency &&
        !_hasAgencyVerifyCue(analysis.normalizedQuery)) {
      return null;
    }
    if (!_meetsThreshold(
      analysis,
      isExactCommand: _isExactAgencyCommand(analysis.normalizedQuery),
    )) {
      return null;
    }
    final route = AgencyVerificationScreen.route();
    final agency = analysis.agencyName?.trim();
    final subtitle = agency != null && agency.isNotEmpty
        ? AppShellStrings.format(
            'global_search_action_agency_named_subtitle',
            locale,
            params: {'agency': agency},
          )
        : AppShellStrings.t('global_search_action_agency_subtitle', locale);

    return GlobalSearchResultItem(
      id: 'action_verify_agency',
      category: GlobalSearchCategory.actions,
      title: AppShellStrings.t('global_search_action_agency_title', locale),
      subtitle: subtitle,
      routePath: route,
      score: 970,
      resultKind: GlobalSearchResultKind.action,
      actionId: SearchActionId.verifyAgency,
      confidence: analysis.confidence,
    );
  }

  static GlobalSearchResultItem? _buildCurrencyAction(
    SearchAnalysis analysis,
    String locale,
  ) {
    final from = analysis.fromCurrency?.toUpperCase();
    final to = analysis.toCurrency?.toUpperCase();
    if (from == null || to == null) return null;

    final hasConversionPattern = from != to ||
        analysis.conversionAmount != null ||
        analysis.normalizedQuery.contains('convert') ||
        analysis.normalizedQuery.contains(' to ');

    if (!hasConversionPattern) return null;
    if (analysis.intent != SearchIntent.checkRate &&
        analysis.conversionAmount == null &&
        from == to) {
      return null;
    }
    if (!_meetsThreshold(
      analysis,
      isExactCommand: analysis.conversionAmount != null,
    )) {
      return null;
    }

    final corridorCode = _corridorCountryCode(from: from, to: to);
    if (corridorCode == null) {
      return GlobalSearchResultItem(
        id: 'action_convert_currency',
        category: GlobalSearchCategory.actions,
        title: AppShellStrings.t('global_search_action_currency_title', locale),
        subtitle: _currencySubtitle(from, to, analysis.conversionAmount, locale),
        routePath: '/money-services/corridor-comparator',
        score: 960,
        resultKind: GlobalSearchResultKind.action,
        actionId: SearchActionId.convertCurrency,
        confidence: analysis.confidence,
      );
    }

    final params = <String, String>{'country': corridorCode};
    final amount = analysis.conversionAmount;
    if (amount != null && amount > 0) {
      params['amount'] = _formatAmount(amount);
    }

    final query = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    return GlobalSearchResultItem(
      id: 'action_convert_currency',
      category: GlobalSearchCategory.actions,
      title: AppShellStrings.t('global_search_action_currency_title', locale),
      subtitle: _currencySubtitle(from, to, amount, locale),
      routePath: '/money-services/corridor-comparator?$query',
      score: 960,
      resultKind: GlobalSearchResultKind.action,
      actionId: SearchActionId.convertCurrency,
      queryParameters: params,
      confidence: analysis.confidence,
    );
  }

  static String? _corridorCountryCode({
    required String from,
    required String to,
  }) {
    if (from == 'QAR' && _corridorCurrencies.contains(to)) return to;
    if (to == 'QAR' && _corridorCurrencies.contains(from)) return from;
    if (_corridorCurrencies.contains(to)) return to;
    if (_corridorCurrencies.contains(from)) return from;
    return null;
  }

  static String _currencySubtitle(
    String from,
    String to,
    double? amount,
    String locale,
  ) {
    if (amount != null && amount > 0) {
      return AppShellStrings.format(
        'global_search_action_currency_amount_subtitle',
        locale,
        params: {
          'amount': _formatAmount(amount),
          'from': from,
          'to': to,
        },
      );
    }
    return AppShellStrings.format(
      'global_search_action_currency_pair_subtitle',
      locale,
      params: {'from': from, 'to': to},
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }
    return amount.toStringAsFixed(2);
  }

  static bool _meetsThreshold(
    SearchAnalysis analysis, {
    required bool isExactCommand,
  }) {
    if (isExactCommand) return true;
    return analysis.confidence >= confidenceThreshold;
  }

  static bool _isEosbCalculateCommand(SearchAnalysis analysis) {
    final lower = analysis.normalizedQuery;
    if (_isExactEosbCommand(lower)) return true;

    const calcWords = ['calculate', 'calculator', 'compute'];
    const eosbWords = ['eosb', 'gratuity', 'end of service'];
    final hasCalc = calcWords.any(lower.contains);
    final hasEosb =
        eosbWords.any(lower.contains) ||
        analysis.intent == SearchIntent.eosbCalculator;
    return hasCalc && hasEosb;
  }

  static bool _isExactEosbCommand(String lower) {
    const exactPhrases = [
      'calculate eosb',
      'calculate gratuity',
      'eosb calculator',
      'calculate end of service',
    ];
    return exactPhrases.any((p) => lower.contains(p));
  }

  static bool _isExactScannerCommand(String lower) {
    const exactPhrases = [
      'scan document',
      'document scanner',
      'scan my document',
    ];
    if (exactPhrases.any((p) => lower.contains(p))) return true;
    return lower.trim() == 'scan';
  }

  static bool _isExactAgencyCommand(String lower) {
    const exactPhrases = [
      'verify recruitment agency',
      'check recruitment agency',
      'agency verification',
      'verify agency',
      'check agency',
    ];
    return exactPhrases.any((p) => lower.contains(p));
  }

  static bool _hasEmployerVerifyCue(String lower) {
    return lower.contains('verify') ||
        lower.contains('check') ||
        lower.contains('reliable') ||
        lower.contains('track record');
  }

  static bool _hasAgencyVerifyCue(String lower) {
    return lower.contains('recruitment') ||
        lower.contains('agency') ||
        lower.contains('verify') ||
        lower.contains('check');
  }
}
