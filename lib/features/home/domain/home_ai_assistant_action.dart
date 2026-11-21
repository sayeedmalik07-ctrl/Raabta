import 'package:flutter/material.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_context.dart';

/// Destination for a Home assistant tile tap.
sealed class HomeAiAssistantActionTarget {
  const HomeAiAssistantActionTarget();
}

/// Navigate to an existing in-app route (no AI request).
final class HomeAiAssistantRouteTarget extends HomeAiAssistantActionTarget {
  const HomeAiAssistantRouteTarget(this.route);

  final String route;
}

/// Open `/ai-chat` with optional context (no auto-send).
final class HomeAiAssistantAiChatTarget extends HomeAiAssistantActionTarget {
  const HomeAiAssistantAiChatTarget({
    required this.contextSubtitle,
    required this.contextBody,
    this.contextSource = AiChatContextSource.general,
  });

  final String contextSubtitle;
  final String contextBody;
  final AiChatContextSource contextSource;
}

/// One deterministic contextual action for the Home floating AI surface.
class HomeAiAssistantAction {
  const HomeAiAssistantAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.target,
    this.summary,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Short secondary line shown on the intelligence surface tile.
  final String? summary;
  final HomeAiAssistantActionTarget target;
}
