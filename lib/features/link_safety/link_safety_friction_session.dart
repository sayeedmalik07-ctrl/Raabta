import 'package:flutter/foundation.dart';

/// In-memory only — concern-link friction at most once per URL per app session.
abstract final class LinkSafetyFrictionSession {
  static final _openedConcernLinks = <String>{};

  @visibleForTesting
  static void resetForTests() => _openedConcernLinks.clear();

  static bool shouldShowFriction(String url) =>
      !_openedConcernLinks.contains(url);

  static void markFrictionShown(String url) {
    _openedConcernLinks.add(url);
  }
}
