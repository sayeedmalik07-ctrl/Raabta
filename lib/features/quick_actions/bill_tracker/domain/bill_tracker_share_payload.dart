/// Text from OS share sheet, held until Bill Tracker import screen consumes it.
abstract final class BillTrackerSharePayloadStore {
  static String? _pendingText;

  static void setText(String text) {
    _pendingText = text.trim();
  }

  static String? peekText() => _pendingText;

  static String? consumeText() {
    final text = _pendingText;
    _pendingText = null;
    return text;
  }
}
