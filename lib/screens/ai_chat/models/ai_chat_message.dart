class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.isStreaming = false,
    this.createdAt,
  });

  final String id;
  final bool isUser;
  final String text;
  final bool isStreaming;
  final DateTime? createdAt;

  AiChatMessage copyWith({
    String? id,
    bool? isUser,
    String? text,
    bool? isStreaming,
    DateTime? createdAt,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUser': isUser,
        'text': text,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
