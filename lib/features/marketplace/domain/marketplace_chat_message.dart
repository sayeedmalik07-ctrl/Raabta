import 'package:raabta/features/marketplace/domain/marketplace_payment_phishing_detector.dart';

class MarketplaceChatMessage {
  const MarketplaceChatMessage({
    required this.id,
    required this.listingId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.embeddedQrPayload,
    this.imageAttached = false,
    this.phishingScan,
    this.messageKind,
    this.peerUid,
  });

  final String id;
  final String listingId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final String? embeddedQrPayload;
  final bool imageAttached;
  final MarketplacePhishingScanResult? phishingScan;
  final String? messageKind;
  final String? peerUid;

  bool get isOfferSystem => messageKind == 'offer_system';

  bool get hasPhishingSignals => phishingScan?.hasSignals ?? false;

  Map<String, dynamic> toJson() => {
        'listingId': listingId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'embeddedQrPayload': embeddedQrPayload,
        'imageAttached': imageAttached,
        if (messageKind != null) 'messageKind': messageKind,
        if (peerUid != null && peerUid!.isNotEmpty) 'peerUid': peerUid,
        if (phishingScan != null && phishingScan!.hasSignals)
          'phishingSignalKinds':
              phishingScan!.signals.map((s) => s.kind.name).toList(),
      };

  factory MarketplaceChatMessage.fromJson(String id, Map<String, dynamic> json) {
    final text = json['text'] as String? ?? '';
    final qr = json['embeddedQrPayload'] as String?;
    final kind = json['messageKind'] as String?;
    final scan = kind == 'offer_system'
        ? const MarketplacePhishingScanResult.clean()
        : MarketplacePaymentPhishingDetector.scan(
            text: text,
            embeddedQrPayload: qr,
          );

    return MarketplaceChatMessage(
      id: id,
      listingId: json['listingId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: text,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      embeddedQrPayload: qr,
      imageAttached: json['imageAttached'] as bool? ?? false,
      phishingScan: scan.hasSignals ? scan : null,
      messageKind: kind,
    );
  }
}
