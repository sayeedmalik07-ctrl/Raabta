import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/router/ai_chat_entrance_orb.dart';

/// Debounced navigation into `/ai-chat` from the Home sparkle orb.
abstract final class HomeAiAssistantLauncher {
  static const debounce = Duration(milliseconds: 600);

  static DateTime? _lastLaunch;

  /// Returns false when debounced (no navigation).
  static bool open(
    BuildContext context, {
    String? query,
    bool autoSendInitialMessage = false,
    Rect? entranceSourceRect,
  }) {
    final now = DateTime.now();
    if (_lastLaunch != null && now.difference(_lastLaunch!) < debounce) {
      return false;
    }
    _lastLaunch = now;

    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    var sourceRect = entranceSourceRect;
    if (sourceRect == null) {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize) {
        final topLeft = renderObject.localToGlobal(Offset.zero);
        sourceRect = topLeft & renderObject.size;
      }
    }

    context.push(
      '/ai-chat',
      extra: {
        if (query != null && autoSendInitialMessage) 'query': query,
        if (query != null && !autoSendInitialMessage) 'composerHint': query,
        'autoSendInitialMessage': autoSendInitialMessage,
        'livingEntrance': true,
        if (sourceRect != null)
          'entranceOrbRect': AiChatEntranceOrbRectCodec.encode(sourceRect),
      },
    );
    return true;
  }

  @visibleForTesting
  static void resetDebounceForTest() {
    _lastLaunch = null;
  }
}
