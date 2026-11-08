import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/housing/domain/housing_chat_message.dart';
import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/housing_firestore_service.dart';

class HousingChatRepository {
  HousingChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>>? _messagesRef(String listingId) {
    if (_firestore == null) return null;
    return _firestore!
        .collection(HousingFirestoreService.listingsCollection)
        .doc(listingId)
        .collection('chat_messages');
  }

  Stream<List<HousingChatMessage>> watchMessages(String listingId) {
    final ref = _messagesRef(listingId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs
              .map((doc) => HousingChatMessage.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<HousingChatMessage?> sendMessage({
    required String listingId,
    required String text,
    required String peerUid,
  }) async {
    final ref = _messagesRef(listingId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return null;

    final doc = ref.doc();
    final message = HousingChatMessage(
      id: doc.id,
      listingId: listingId,
      senderId: uid,
      text: text.trim(),
      createdAt: DateTime.now(),
      peerUid: peerUid,
    );

    await doc.set(message.toJson());
    return message;
  }

  Future<void> sendViewingSystemMessage({
    required String listingId,
    required String viewingRequestId,
    required String viewingSystemEvent,
    required String messageKey,
    required String locale,
    required Map<String, String> params,
    String? confirmedAtIso,
  }) async {
    final ref = _messagesRef(listingId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return;

    final text = HousingViewingStrings.format(messageKey, locale, params: params);
    final doc = ref.doc();
    final message = HousingChatMessage(
      id: doc.id,
      listingId: listingId,
      senderId: uid,
      text: text,
      createdAt: DateTime.now(),
      messageKind: 'viewing_system',
      viewingRequestId: viewingRequestId,
      viewingSystemEvent: viewingSystemEvent,
      confirmedAtIso: confirmedAtIso,
    );

    await doc.set(message.toJson());
  }
}
