class HousingChatMessage {
  const HousingChatMessage({
    required this.id,
    required this.listingId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.messageKind,
    this.viewingRequestId,
    this.viewingSystemEvent,
    this.confirmedAtIso,
    this.peerUid,
  });

  final String id;
  final String listingId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final String? messageKind;
  final String? viewingRequestId;
  final String? viewingSystemEvent;
  final String? confirmedAtIso;
  final String? peerUid;

  bool get isViewingSystem => messageKind == 'viewing_system';

  Map<String, dynamic> toJson() => {
        'listingId': listingId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        if (peerUid != null && peerUid!.isNotEmpty) 'peerUid': peerUid,
        if (messageKind != null) 'messageKind': messageKind,
        if (viewingRequestId != null) 'viewingRequestId': viewingRequestId,
        if (viewingSystemEvent != null) 'viewingSystemEvent': viewingSystemEvent,
        if (confirmedAtIso != null) 'confirmedAtIso': confirmedAtIso,
      };

  factory HousingChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return HousingChatMessage(
      id: id,
      listingId: json['listingId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      messageKind: json['messageKind'] as String?,
      viewingRequestId: json['viewingRequestId'] as String?,
      viewingSystemEvent: json['viewingSystemEvent'] as String?,
      confirmedAtIso: json['confirmedAtIso'] as String?,
    );
  }
}
