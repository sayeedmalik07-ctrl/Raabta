import 'dart:convert';
import 'dart:io';

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

  Future<DocumentScanResult> scanDocument({
    required File imageFile,
    required String language,
    required bool isPremium,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse('$_baseUrl/api/document-scan');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'imageBase64': base64Image,
            'language': language,
            'isPremium': isPremium,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 429) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw VisaApiException(
        body['message'] as String? ?? 'Free scan limit reached',
      );
    }
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      throw VisaApiException(
        body?['error'] as String? ?? 'Document scan failed',
      );
    }

    return DocumentScanResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class VisaApiException implements Exception {
  VisaApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
