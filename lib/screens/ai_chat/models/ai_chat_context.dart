enum AiChatContextSource {
  eosb,
  visa,
  vault,
  health,
  general;

  static AiChatContextSource? fromRouteValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final source in AiChatContextSource.values) {
      if (source.name == value) return source;
    }
    return null;
  }

  String get routeValue => name;
}

class AiChatContext {
  const AiChatContext({
    required this.source,
    required this.label,
    this.body,
  });

  final AiChatContextSource source;
  final String label;
  final String? body;

  String get combinedExtraContext {
    final buffer = StringBuffer('Context: $label');
    if (body != null && body!.trim().isNotEmpty) {
      buffer.write('\n\n$body');
    }
    return buffer.toString();
  }
}
