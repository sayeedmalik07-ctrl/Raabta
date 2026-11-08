class ServiceQuoteChatMessage {
  const ServiceQuoteChatMessage({
    required this.id,
    required this.requestListingId,
    required this.providerId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.messageKind,
    this.peerUid,
  });

  final String id;
  final String requestListingId;
  final String providerId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final String? messageKind;
  final String? peerUid;

  bool get isQuoteSystem => messageKind == 'quote_system';

  Map<String, dynamic> toJson() => {
        'requestListingId': requestListingId,
        'providerId': providerId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        if (messageKind != null) 'messageKind': messageKind,
        if (peerUid != null && peerUid!.isNotEmpty) 'peerUid': peerUid,
      };

  factory ServiceQuoteChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return ServiceQuoteChatMessage(
      id: id,
      requestListingId: json['requestListingId'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      messageKind: json['messageKind'] as String?,
    );
  }
}
