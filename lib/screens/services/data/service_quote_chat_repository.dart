import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/screens/services/domain/service_quote_chat_message.dart';
import 'package:raabta/screens/services/l10n/service_quote_strings.dart';
import 'package:raabta/services/firebase_service.dart';

class ServiceQuoteChatRepository {
  ServiceQuoteChatRepository({FirebaseFirestore? firestore})
      : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null;

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>>? _messagesRef(
    String requestListingId,
    String providerId,
  ) {
    if (_firestore == null) return null;
    return _firestore
        .collection('service_listings')
        .doc(requestListingId)
        .collection('quote_chats')
        .doc(providerId)
        .collection('messages');
  }

  Stream<List<ServiceQuoteChatMessage>> watchMessages({
    required String requestListingId,
    required String providerId,
  }) {
    final ref = _messagesRef(requestListingId, providerId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs
              .map((doc) =>
                  ServiceQuoteChatMessage.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<ServiceQuoteChatMessage?> sendMessage({
    required String requestListingId,
    required String providerId,
    required String text,
    required String peerUid,
  }) async {
    final ref = _messagesRef(requestListingId, providerId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return null;

    final doc = ref.doc();
    final message = ServiceQuoteChatMessage(
      id: doc.id,
      requestListingId: requestListingId,
      providerId: providerId,
      senderId: uid,
      text: text.trim(),
      createdAt: DateTime.now(),
      peerUid: peerUid,
    );

    await doc.set(message.toJson());
    return message;
  }

  Future<void> sendQuoteSystemMessage({
    required String requestListingId,
    required String providerId,
    required String messageKey,
    required String locale,
    Map<String, String> params = const {},
  }) async {
    final ref = _messagesRef(requestListingId, providerId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return;

    final text = ServiceQuoteStrings.format(messageKey, locale, params: params);
    final doc = ref.doc();
    final message = ServiceQuoteChatMessage(
      id: doc.id,
      requestListingId: requestListingId,
      providerId: providerId,
      senderId: uid,
      text: text,
      createdAt: DateTime.now(),
      messageKind: 'quote_system',
    );

    await doc.set(message.toJson());
  }
}
