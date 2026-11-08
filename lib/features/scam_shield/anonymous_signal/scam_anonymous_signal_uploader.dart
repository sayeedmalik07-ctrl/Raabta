import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_schema.dart';
import 'package:raabta/features/scam_shield/services/scam_app_check_service.dart';

typedef ScamAnonymousSignalHttpClient = Future<http.Response> Function(
  Uri uri, {
  required Map<String, String> headers,
  required String body,
});

class ScamAnonymousSignalUploadResult {
  const ScamAnonymousSignalUploadResult({
    required this.ok,
    this.statusCode,
    this.error,
  });

  final bool ok;
  final int? statusCode;
  final String? error;

  static const silentFail = ScamAnonymousSignalUploadResult(ok: false);
}

abstract final class ScamAnonymousSignalUploader {
  static ScamAnonymousSignalHttpClient? httpClientOverride;

  static Future<ScamAnonymousSignalUploadResult> uploadBatch({
    required String installKey,
    required List<ScamAnonymousSignalEvent> events,
  }) async {
    if (events.isEmpty) {
      return const ScamAnonymousSignalUploadResult(ok: true, statusCode: 200);
    }
    if (events.length > ScamAnonymousSignalSchema.maxEventsPerBatch) {
      return const ScamAnonymousSignalUploadResult(
        ok: false,
        error: 'batch_too_large',
      );
    }

    final appCheck = await ScamAppCheckService.instance.getToken();
    if (appCheck == null || appCheck.isEmpty) {
      return const ScamAnonymousSignalUploadResult(
        ok: false,
        error: 'app_check_unavailable',
      );
    }

    final uri = Uri.parse(
      '${AppConfig.backendUrl}/api/scam-shield/anonymous-signal/batch',
    );
    final body = jsonEncode({
      'installKey': installKey,
      'events': events.map((e) => e.toJson()).toList(),
    });
    final headers = {
      'Content-Type': 'application/json',
      'X-Firebase-AppCheck': appCheck,
    };

    try {
      final client = httpClientOverride ?? _defaultPost;
      final response = await client(uri, headers: headers, body: body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ScamAnonymousSignalUploadResult(
          ok: true,
          statusCode: response.statusCode,
        );
      }
      return ScamAnonymousSignalUploadResult(
        ok: false,
        statusCode: response.statusCode,
        error: 'http_${response.statusCode}',
      );
    } catch (_) {
      return ScamAnonymousSignalUploadResult.silentFail;
    }
  }

  static Future<http.Response> _defaultPost(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) {
    return http.post(uri, headers: headers, body: body);
  }
}
