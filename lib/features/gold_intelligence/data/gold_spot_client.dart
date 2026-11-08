import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';

/// Fetches international gold spot (USD/troy oz) directly when the Raabta backend is unavailable.
abstract final class GoldSpotClient {
  static const _swissquoteUrl =
      'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XAU/USD';

  static Future<({double usdPerOz, String source})?> fetchUsdPerOz() async {
    for (final source in [_fetchSwissquote, _fetchMetalsLive]) {
      try {
        final result = await source();
        if (result != null && result.usdPerOz > 0) return result;
      } catch (e) {
        debugPrint('GoldSpotClient: ${e.toString()}');
      }
    }
    return null;
  }

  static double usdOzToQarPerGram24k(double usdPerOz) {
    final usdPerGram = usdPerOz / GoldQatarConstants.gramsPerTroyOz;
    return double.parse(
      (usdPerGram * GoldQatarConstants.qarUsdPeg).toStringAsFixed(2),
    );
  }

  static Future<({double usdPerOz, String source})?> _fetchSwissquote() async {
    final res = await http
        .get(Uri.parse(_swissquoteUrl), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    if (data is! List || data.isEmpty) return null;

    final quote = (data[0] as Map<String, dynamic>)['spreadProfilePrices'];
    if (quote is! List || quote.isEmpty) return null;

    final first = quote[0] as Map<String, dynamic>;
    final bid = (first['bid'] as num?)?.toDouble();
    final ask = (first['ask'] as num?)?.toDouble();
    if (bid == null || ask == null || bid <= 0 || ask <= 0) return null;

    return (usdPerOz: double.parse(((bid + ask) / 2).toStringAsFixed(2)), source: 'swissquote');
  }

  static Future<({double usdPerOz, String source})?> _fetchMetalsLive() async {
    final res = await http
        .get(
          Uri.parse('https://api.metals.live/v1/spot/gold'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    num? rawPrice;
    if (data is List && data.isNotEmpty) {
      rawPrice = (data[0] as Map<String, dynamic>)['price'] as num?;
    } else if (data is Map<String, dynamic>) {
      rawPrice = data['price'] as num?;
    }
    final price = rawPrice?.toDouble();
    if (price == null || price <= 0) return null;
    return (usdPerOz: price.toDouble(), source: 'metals.live');
  }
}
