import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/buddy/data/buddy_chat_repository.dart';
import 'package:raabta/features/buddy/data/buddy_profile_repository.dart';
import 'package:raabta/features/buddy/data/buddy_request_repository.dart';
import 'package:raabta/features/buddy/data/buddy_thread_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_chat_message.dart';
import 'package:raabta/features/buddy/models/buddy_thread.dart';
import 'package:raabta/features/buddy/domain/buddy_matching_engine.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';
import 'package:raabta/features/buddy/models/buddy_request.dart';
import 'package:raabta/features/buddy/services/buddy_entry_card_prefs.dart';
import 'package:raabta/features/buddy/services/buddy_matching_service.dart';
import 'package:raabta/providers/auth_providers.dart';

final buddyProfileRepositoryProvider = Provider<BuddyProfileRepository>(
  (ref) => BuddyProfileRepository(),
);

final buddyRequestRepositoryProvider = Provider<BuddyRequestRepository>(
  (ref) => BuddyRequestRepository(),
);

final buddyThreadRepositoryProvider = Provider<BuddyThreadRepository>(
  (ref) => BuddyThreadRepository(),
);

final buddyChatRepositoryProvider = Provider<BuddyChatRepository>(
  (ref) => BuddyChatRepository(),
);

final buddyMatchingServiceProvider = Provider<BuddyMatchingService>(
  (ref) => BuddyMatchingService(),
);

final buddyProfileProvider = FutureProvider<BuddyProfile?>((ref) async {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return null;
  return ref.read(buddyProfileRepositoryProvider).fetch(uid);
});

final buddySuggestionsProvider =
    FutureProvider<List<BuddyMatchCandidate>>((ref) async {
  final profile = await ref.watch(buddyProfileProvider.future);
  if (profile == null) return const [];
  return ref.read(buddyMatchingServiceProvider).suggestionsForNewcomer(
        newcomer: profile,
      );
});

final buddyIncomingRequestsProvider =
    FutureProvider<List<BuddyRequest>>((ref) async {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const [];
  return ref.read(buddyRequestRepositoryProvider).fetchIncomingForHelper(uid);
});

final buddyOutgoingRequestsProvider =
    FutureProvider<List<BuddyRequest>>((ref) async {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const [];
  return ref.read(buddyRequestRepositoryProvider).fetchOutgoingForNewcomer(uid);
});

final buddyEntryCardDismissedProvider = FutureProvider<bool>((ref) async {
  return BuddyEntryCardPrefs.isDismissed();
});

final buddyActiveThreadsProvider = FutureProvider<List<BuddyThread>>((ref) async {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const [];
  return ref.read(buddyThreadRepositoryProvider).fetchActiveForUser(uid);
});

final buddyThreadProvider = FutureProvider.family<BuddyThread?, String>(
  (ref, threadId) async {
    final uid = ref.watch(currentUserProvider)?.uid;
    if (uid == null) return null;
    return ref.read(buddyThreadRepositoryProvider).fetchForParticipant(
          threadId: threadId,
          uid: uid,
        );
  },
);

final buddyChatMessagesProvider =
    StreamProvider.family<List<BuddyChatMessage>, String>((ref, threadId) {
  return ref.read(buddyChatRepositoryProvider).watchMessages(threadId);
});
