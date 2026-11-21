import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/persistence/legacy_local_data_purge.dart';
import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time legacy global purge when a user authenticates; no cross-user attach.
class LocalDataIsolationListener extends ConsumerStatefulWidget {
  const LocalDataIsolationListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LocalDataIsolationListener> createState() =>
      _LocalDataIsolationListenerState();
}

class _LocalDataIsolationListenerState
    extends ConsumerState<LocalDataIsolationListener> {
  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(currentUserProvider.select((u) => u?.uid),
        (previous, next) async {
      if (previous != next) {
        ref.read(userAIProfileProvider.notifier).resetForAuthChange();
        ref.read(expatLifeScoreProvider.notifier).resetForAuthChange();
        ref.read(aiChatProvider.notifier).resetForAuthChange();
        ref.read(claudeAIServiceProvider).clearCache();
      }
      if (next == null || next.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      await LegacyLocalDataPurge.purgeDeviceGlobalSensitiveData(prefs);
    });

    return widget.child;
  }
}
