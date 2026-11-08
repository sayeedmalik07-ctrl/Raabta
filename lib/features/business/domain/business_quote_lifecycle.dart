import 'package:raabta/features/business/domain/business_quote_request.dart';

abstract final class BusinessQuoteLifecycle {
  BusinessQuoteLifecycle._();

  static const requestValidity = Duration(hours: 48);
  static const maxDescriptionLength = 500;
  static const maxQuoteDescriptionLength = 500;
  static const maxQuoteNoteLength = 300;

  static int expiryFromNowMs([DateTime? from]) =>
      (from ?? DateTime.now()).add(requestValidity).millisecondsSinceEpoch;

  static BusinessQuoteRequest expireIfNeeded(BusinessQuoteRequest request) {
    if (!request.isExpired) return request;
    return request.copyWith(
      status: BusinessQuoteStatus.expired,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessQuoteRequest? ownerSubmitQuote(
    BusinessQuoteRequest request, {
    required double price,
    required String description,
    String? note,
  }) {
    if (request.status != BusinessQuoteStatus.pending) return null;
    if (request.isExpired) return _expired(request);
    if (price <= 0 || description.trim().isEmpty) return null;
    final now = DateTime.now();
    return request.copyWith(
      status: BusinessQuoteStatus.quoted,
      ownerQuotePrice: price,
      ownerQuoteDescription: description.trim(),
      ownerQuoteNote: note?.trim(),
      quotedAt: now,
      updatedAt: now,
    );
  }

  static BusinessQuoteRequest? ownerDecline(BusinessQuoteRequest request) {
    if (request.status != BusinessQuoteStatus.pending) return null;
    if (request.isExpired) return _expired(request);
    return request.copyWith(
      status: BusinessQuoteStatus.declined,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessQuoteRequest? requesterCancel(BusinessQuoteRequest request) {
    if (request.status != BusinessQuoteStatus.pending) return null;
    if (request.isExpired) return _expired(request);
    return request.copyWith(
      status: BusinessQuoteStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  static BusinessQuoteRequest _expired(BusinessQuoteRequest request) {
    return request.copyWith(
      status: BusinessQuoteStatus.expired,
      updatedAt: DateTime.now(),
    );
  }
}
