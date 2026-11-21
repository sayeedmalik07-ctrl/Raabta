import 'package:flutter/foundation.dart';

/// In-memory session cap — not persisted.
abstract final class ForewarningSession {
  static var _shownThisSession = false;

  static bool get hasShownThisSession => _shownThisSession;

  static void markShown() {
    _shownThisSession = true;
  }

  @visibleForTesting
  static void resetForTest() {
    _shownThisSession = false;
  }
}
