import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/models/money_models.dart';

class ExchangeApiService {
  ExchangeApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:3000';

  final http.Client _client;
  final String _baseUrl;

  Future<ExchangeRatesResponse> fetchRates({
    required String from,
    required String to,
  }) async {
    final uri = Uri.parse('$_baseUrl/exchange-rates').replace(
      queryParameters: {'from': from, 'to': to},
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw ExchangeApiException(
        'Failed to load rates (${response.statusCode})',
      );
    }

    return ExchangeRatesResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> saveRateAlert({
    required String currency,
    required double targetRate,
    String? userId,
  }) async {
    final uri = Uri.parse('$_baseUrl/rate-alerts');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'currency': currency,
            'targetRate': targetRate,
            'userId': userId ?? 'anonymous',
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ExchangeApiException('Failed to save rate alert');
    }
  }

  Future<void> trackAffiliateClick({
    required String exchangeHouseId,
    required String exchangeHouseName,
    required String currency,
    required double amount,
  }) async {
    final uri = Uri.parse('$_baseUrl/affiliate-click');
    await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'exchangeHouseId': exchangeHouseId,
            'exchangeHouseName': exchangeHouseName,
            'currency': currency,
            'amount': amount,
          }),
        )
        .timeout(const Duration(seconds: 5));
  }
}

class ExchangeApiException implements Exception {
  ExchangeApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
