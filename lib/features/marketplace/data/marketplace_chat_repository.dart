import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/marketplace/domain/marketplace_chat_message.dart';
import 'package:raabta/features/marketplace/domain/marketplace_payment_phishing_detector.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_offer_strings.dart';
import 'package:raabta/services/firebase_service.dart';

class MarketplaceChatRepository {
  MarketplaceChatRepository({FirebaseFirestore? firestore})
      : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null;

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>>? _messagesRef(String listingId) {
    if (_firestore == null) return null;
    return _firestore
        .collection('marketplace_listings')
        .doc(listingId)
        .collection('chat_messages');
  }

  Stream<List<MarketplaceChatMessage>> watchMessages(String listingId) {
    final ref = _messagesRef(listingId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs
              .map((doc) => MarketplaceChatMessage.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<MarketplaceChatMessage?> sendMessage({
    required String listingId,
    required String text,
    required String peerUid,
    String? embeddedQrPayload,
    bool imageAttached = false,
  }) async {
    final ref = _messagesRef(listingId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return null;

    final scan = MarketplacePaymentPhishingDetector.scan(
      text: text,
      embeddedQrPayload: embeddedQrPayload,
    );

    final doc = ref.doc();
    final message = MarketplaceChatMessage(
      id: doc.id,
      listingId: listingId,
      senderId: uid,
      text: text.trim(),
      createdAt: DateTime.now(),
      embeddedQrPayload: embeddedQrPayload,
      imageAttached: imageAttached,
      phishingScan: scan.hasSignals ? scan : null,
      peerUid: peerUid,
    );

    await _firestore!.collection('marketplace_listings').doc(listingId).set(
      {'chatParticipantIds': FieldValue.arrayUnion([uid])},
      SetOptions(merge: true),
    );

    await doc.set(message.toJson());
    return message.copyWith(phishingScan: scan.hasSignals ? scan : null);
  }

  Future<void> sendOfferSystemMessage({
    required String listingId,
    required String messageKey,
    required String locale,
    required Map<String, String> params,
  }) async {
    final ref = _messagesRef(listingId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return;

    final text = MarketplaceOfferStrings.format(messageKey, locale, params: params);
    final doc = ref.doc();
    final message = MarketplaceChatMessage(
      id: doc.id,
      listingId: listingId,
      senderId: uid,
      text: text,
      createdAt: DateTime.now(),
      messageKind: 'offer_system',
    );

    await _firestore!.collection('marketplace_listings').doc(listingId).set(
      {'chatParticipantIds': FieldValue.arrayUnion([uid])},
      SetOptions(merge: true),
    );

    await doc.set(message.toJson());
  }

  Future<void> reportConversation({
    required String listingId,
    required String reason,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_firestore == null || uid == null) return;

    await _firestore.collection('marketplace_chat_reports').add({
      'listingId': listingId,
      'reporterUid': uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

extension MarketplaceChatMessageCopy on MarketplaceChatMessage {
  MarketplaceChatMessage copyWith({
    MarketplacePhishingScanResult? phishingScan,
  }) {
    return MarketplaceChatMessage(
      id: id,
      listingId: listingId,
      senderId: senderId,
      text: text,
      createdAt: createdAt,
      embeddedQrPayload: embeddedQrPayload,
      imageAttached: imageAttached,
      phishingScan: phishingScan ?? this.phishingScan,
    );
  }
}
