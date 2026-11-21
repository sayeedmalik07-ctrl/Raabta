import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';

/// Triggers server-side Lost & Found matching after a listing is posted.
class LostFoundMatchClient {
  LostFoundMatchClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> triggerMatch({required String listingId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || listingId.trim().isEmpty) return;

    final token = await user.getIdToken();
    final uri = Uri.parse('${AppConfig.backendUrl}/api/community/lost-found/match');
    try {
      await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'listingId': listingId.trim()}),
      );
    } catch (_) {
      // Non-blocking — listing publish must not depend on matcher success.
    }
  }
}
