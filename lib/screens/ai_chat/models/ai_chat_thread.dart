class AiChatThreadSummary {
  const AiChatThreadSummary({
    required this.id,
    required this.title,
    this.updatedAt,
    this.contextSource,
    this.messageCount = 0,
  });

  final String id;
  final String title;
  final DateTime? updatedAt;
  final String? contextSource;
  final int messageCount;

  factory AiChatThreadSummary.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawUpdated = data['updatedAt'];
    DateTime? updatedAt;
    if (rawUpdated != null) {
      try {
        updatedAt = (rawUpdated as dynamic).toDate() as DateTime;
      } catch (_) {
        updatedAt = DateTime.tryParse(rawUpdated.toString());
      }
    }
    final messages = data['messages'] as List<dynamic>? ?? [];
    return AiChatThreadSummary(
      id: id,
      title: data['title'] as String? ?? 'Raabta AI',
      updatedAt: updatedAt,
      contextSource: data['contextSource'] as String?,
      messageCount: messages.length,
    );
  }
}
