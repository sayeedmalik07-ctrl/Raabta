import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/screens/services/data/service_quote_chat_repository.dart';
import 'package:raabta/screens/services/data/service_quote_repository.dart';
import 'package:raabta/screens/services/domain/service_quote.dart';
import 'package:raabta/screens/services/domain/service_quote_chat_message.dart';

final serviceQuoteRepositoryProvider = Provider<ServiceQuoteRepository>(
  (ref) => ServiceQuoteRepository(),
);

final serviceQuoteChatRepositoryProvider = Provider<ServiceQuoteChatRepository>(
  (ref) => ServiceQuoteChatRepository(),
);

final serviceRequestQuotesProvider = StreamProvider.autoDispose
    .family<List<ServiceQuote>, String>((ref, requestListingId) {
  if (requestListingId.isEmpty) return Stream.value(const []);
  return ref
      .watch(serviceQuoteRepositoryProvider)
      .watchRequestQuotes(requestListingId);
});

typedef ServiceQuoteChatParams = ({String requestListingId, String providerId});

final serviceQuoteChatMessagesProvider = StreamProvider.autoDispose
    .family<List<ServiceQuoteChatMessage>, ServiceQuoteChatParams>((ref, params) {
  if (params.requestListingId.isEmpty || params.providerId.isEmpty) {
    return Stream.value(const []);
  }
  return ref.watch(serviceQuoteChatRepositoryProvider).watchMessages(
        requestListingId: params.requestListingId,
        providerId: params.providerId,
      );
});
