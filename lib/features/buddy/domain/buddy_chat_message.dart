class BuddyChatMessage {
  const BuddyChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.peerUid,
  });

  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final String peerUid;

  Map<String, dynamic> toJson() => {
        'threadId': threadId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'peerUid': peerUid,
      };

  factory BuddyChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return BuddyChatMessage(
      id: id,
      threadId: json['threadId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      peerUid: json['peerUid'] as String? ?? '',
    );
  }
}
