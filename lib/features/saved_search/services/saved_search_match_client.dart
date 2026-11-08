import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';

/// Triggers server-side saved-search matching after a listing is published.
class SavedSearchMatchClient {
  SavedSearchMatchClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> triggerMatch({
    required SavedSearchVertical vertical,
    required String listingId,
    required String publisherUserId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    final uri = Uri.parse('${AppConfig.backendUrl}/api/saved-search/match-listing');
    try {
      await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'vertical': vertical.storageValue,
          'listingId': listingId,
          'excludeUserId': publisherUserId,
        }),
      );
    } catch (_) {
      // Non-blocking — publish success must not depend on alert delivery.
    }
  }
}
