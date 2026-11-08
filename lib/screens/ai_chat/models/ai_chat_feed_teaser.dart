import 'package:flutter/material.dart';

/// Lightweight feed pick shown on chat empty state (reuses [aiFeedProvider] cache).
class AiChatFeedTeaser {
  const AiChatFeedTeaser({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.accentColor,
    required this.promptOnChatRoute,
  });

  final String title;
  final String subtitle;
  final String route;
  final Color accentColor;

  /// Message sent when [route] is `/ai-chat` (already on chat).
  final String promptOnChatRoute;
}
