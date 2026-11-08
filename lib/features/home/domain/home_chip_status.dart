import 'package:flutter/foundation.dart';

/// Visual emphasis for a Home chip micro-line (text carries meaning; not color-only).
enum HomeChipStatusTone {
  neutral,
  attention,
}

/// Read-only status micro-line for Home chips and tool cards.
@immutable
class HomeChipStatus {
  const HomeChipStatus.loading()
      : isLoading = true,
        line = '',
        tone = HomeChipStatusTone.neutral;

  const HomeChipStatus.ready({
    required this.line,
    this.tone = HomeChipStatusTone.neutral,
  }) : isLoading = false;

  final bool isLoading;
  final String line;
  final HomeChipStatusTone tone;
}
