import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/providers/auth_providers.dart';

/// Changes whenever the authenticated Firebase UID changes (sign-in/out/switch).
///
/// Watch this in sensitive StateNotifierProviders so in-memory state resets.
final currentAuthUidProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});
