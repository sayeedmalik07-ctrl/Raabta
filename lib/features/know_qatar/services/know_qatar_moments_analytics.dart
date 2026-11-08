import 'package:flutter/foundation.dart';

/// Debug-only analytics — never include moment ids, sections, or PII.
abstract final class KnowQatarMomentsAnalytics {
  static void Function(String line)? debugSink;

  static void momentsPickerUsed() {
    _log('moments_picker_used');
  }

  static void nextStepTapped({required String actionCategory}) {
    _log('next_step_tapped category=$actionCategory');
  }

  static void _log(String message) {
    final line = '[KnowQatar] $message';
    debugSink?.call(line);
    debugPrint(line);
  }
}
