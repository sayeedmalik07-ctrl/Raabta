import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/housing/data/housing_chat_repository.dart';
import 'package:raabta/features/housing/data/housing_viewing_repository.dart';
import 'package:raabta/features/housing/domain/housing_chat_message.dart';
import 'package:raabta/features/housing/domain/housing_viewing_request.dart';

final housingChatRepositoryProvider = Provider<HousingChatRepository>(
  (ref) => HousingChatRepository(),
);

final housingViewingRepositoryProvider = Provider<HousingViewingRepository>(
  (ref) => HousingViewingRepository(
    chatRepository: ref.watch(housingChatRepositoryProvider),
  ),
);

final housingListingViewingsProvider =
    StreamProvider.autoDispose.family<List<HousingViewingRequest>, String>(
  (ref, listingId) {
    return ref
        .watch(housingViewingRepositoryProvider)
        .watchListingRequests(listingId);
  },
);

final housingOwnerViewingsProvider =
    StreamProvider.autoDispose.family<List<HousingViewingRequest>, String>(
  (ref, ownerId) {
    if (ownerId.isEmpty) return Stream.value(const []);
    return ref.watch(housingViewingRepositoryProvider).watchOwnerRequests(ownerId);
  },
);

final housingChatMessagesProvider =
    StreamProvider.autoDispose.family<List<HousingChatMessage>, String>(
  (ref, listingId) {
    return ref.watch(housingChatRepositoryProvider).watchMessages(listingId);
  },
);
