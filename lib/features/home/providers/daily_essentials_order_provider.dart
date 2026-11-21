import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/services/home/quick_tool_usage_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Usage-ranked Daily Essentials for the home screen.
final dailyEssentialsOrderProvider = StateNotifierProvider<
    DailyEssentialsOrderNotifier, AsyncValue<List<QuickActionTool>>>(
  DailyEssentialsOrderNotifier.new,
);

class DailyEssentialsOrderNotifier
    extends StateNotifier<AsyncValue<List<QuickActionTool>>> {
  DailyEssentialsOrderNotifier(Ref ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final tools = QuickToolUsageTracker(prefs).sortedDailyEssentials();
      state = AsyncValue.data(tools);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> recordOpen(String route) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tracker = QuickToolUsageTracker(prefs);
      await tracker.recordTapForRoute(route);
      state = AsyncValue.data(tracker.sortedDailyEssentials());
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
