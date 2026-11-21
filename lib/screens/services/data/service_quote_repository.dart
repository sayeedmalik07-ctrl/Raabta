import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/screens/services/data/service_quote_chat_repository.dart';
import 'package:raabta/screens/services/domain/service_quote.dart';
import 'package:raabta/screens/services/services/service_quote_notification_service.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/firebase_service.dart';

class ServiceQuoteRepository {
  ServiceQuoteRepository({
    FirebaseFirestore? firestore,
    ServiceQuoteChatRepository? chatRepository,
    ServiceQuoteNotificationService? notifications,
  })  : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _chat = chatRepository ?? ServiceQuoteChatRepository(),
        _notifications = notifications ?? ServiceQuoteNotificationService();

  final FirebaseFirestore? _firestore;
  final ServiceQuoteChatRepository _chat;
  final ServiceQuoteNotificationService _notifications;

  CollectionReference<Map<String, dynamic>>? _quotesRef(String requestListingId) {
    if (_firestore == null) return null;
    return _firestore
        .collection('service_listings')
        .doc(requestListingId)
        .collection('quotes');
  }

  Stream<List<ServiceQuote>> watchRequestQuotes(String requestListingId) {
    final ref = _quotesRef(requestListingId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs
              .map((doc) => ServiceQuote.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<ServiceQuote?> submitQuote({
    required String requestListingId,
    required String customerId,
    required String requestTitle,
    required double price,
    required String includedDescription,
    String? priceChangeNote,
    required String providerName,
    String locale = 'English',
  }) async {
    ComplianceFlagsGate.requireServiceQuotes();
    final ref = _quotesRef(requestListingId);
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || providerId == null || providerId == customerId) {
      return null;
    }
    if (price <= 0 || includedDescription.trim().isEmpty) return null;

    final doc = ref.doc(providerId);
    final quote = ServiceQuote(
      id: providerId,
      requestListingId: requestListingId,
      providerId: providerId,
      providerName: providerName.trim(),
      price: price,
      includedDescription: includedDescription.trim(),
      priceChangeNote: priceChangeNote?.trim(),
      createdAt: DateTime.now(),
    );

    await doc.set(quote.toJson());
    await _notifications.notifyQuoteReceived(
      recipientUserId: customerId,
      requestListingId: requestListingId,
      requestTitle: requestTitle,
      providerId: providerId,
      providerName: quote.providerName,
      price: price,
      locale: locale,
    );
    return quote;
  }

  Future<bool> selectQuote({
    required String requestListingId,
    required ServiceQuote quote,
    required String requestTitle,
    required String locale,
  }) async {
    ComplianceFlagsGate.requireServiceQuotes();
    if (_firestore == null) return false;
    final customerId = FirebaseAuth.instance.currentUser?.uid;
    if (customerId == null) return false;

    final listingRef = _firestore.collection('service_listings').doc(requestListingId);
    await _firestore.runTransaction((tx) async {
      final listingSnap = await tx.get(listingRef);
      if (!listingSnap.exists) {
        throw StateError('Request not found');
      }
      final data = listingSnap.data() ?? {};
      if (data['userId'] != customerId) {
        throw StateError('Not request owner');
      }
      tx.update(listingRef, {
        'quotesOpen': false,
        'selectedQuoteProviderId': quote.providerId,
      });
      tx.update(_quotesRef(requestListingId)!.doc(quote.providerId), {
        'status': ServiceQuoteStatus.selected.storageValue,
      });
    });

    await _chat.sendQuoteSystemMessage(
      requestListingId: requestListingId,
      providerId: quote.providerId,
      messageKey: 'svc_quote_chat_selected_system',
      locale: locale,
      params: {
        'price': quote.price.toStringAsFixed(0),
        'provider': quote.providerName,
      },
    );

    await _notifications.notifyQuoteSelected(
      recipientUserId: quote.providerId,
      requestListingId: requestListingId,
      requestTitle: requestTitle,
      price: quote.price,
      locale: locale,
    );
    return true;
  }
}
