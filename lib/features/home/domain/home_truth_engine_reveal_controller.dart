import 'dart:async';

import 'package:flutter/foundation.dart';

/// Section-level sensitive detail reveal for Truth Engine chips (hide by default).
class HomeTruthEngineRevealController {
  HomeTruthEngineRevealController({
    required this._onRevealedChanged,
    this.autoHideAfter = const Duration(seconds: 8),
    @visibleForTesting
    void Function(Duration duration, VoidCallback callback)? runAfter,
  }) {
    _runAfter = runAfter ?? _scheduleRunAfter;
  }

  static const defaultAutoHideAfter = Duration(seconds: 8);

  final VoidCallback _onRevealedChanged;
  final Duration autoHideAfter;
  late final void Function(Duration duration, VoidCallback callback) _runAfter;

  bool _revealed = false;
  Timer? _autoHideTimer;

  bool get isRevealed => _revealed;

  void toggle() {
    if (_revealed) {
      hide();
    } else {
      reveal();
    }
  }

  void reveal() {
    _revealed = true;
    _onRevealedChanged();
    _runAfter(autoHideAfter, () {
      if (_revealed) hide();
    });
  }

  void hide() {
    if (!_revealed && _autoHideTimer == null) return;
    _revealed = false;
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    _onRevealedChanged();
  }

  void onAppBackgrounded() => hide();

  void onRouteChanged() => hide();

  void dispose() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
  }

  void _scheduleRunAfter(Duration duration, VoidCallback callback) {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(duration, callback);
  }
}
