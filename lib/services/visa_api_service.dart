import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/models/visa_models.dart';

class VisaApiService {
  VisaApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:3000';

  final http.Client _client;
  final String _baseUrl;

  Future<VisaGuide> fetchGuide({
    required String categoryId,
    required String language,
  }) async {
    final uri = Uri.parse('$_baseUrl/visa-guides/$categoryId').replace(
      queryParameters: {'language': languageToCode(language)},
    );

    final response =
        await _client.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 404) {
      throw VisaApiException('Guide not found');
    }
    if (response.statusCode != 200) {
      throw VisaApiException('Failed to load guide');
    }

    return VisaGuide.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      language,
    );
  }
}

class VisaApiException implements Exception {
  VisaApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
