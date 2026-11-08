import 'package:shared_preferences/shared_preferences.dart';

import 'package:raabta/features/home/data/daily_essential_routes.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';

/// Persists quick-action tap counts for home row personalization.
class QuickToolUsageTracker {
  QuickToolUsageTracker(this._prefs);

  final SharedPreferences _prefs;

  static const _countPrefix = 'quick_tool_usage_count_';
  static const _lastUsedPrefix = 'quick_tool_usage_last_';

  static Future<void> recordTap(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await QuickToolUsageTracker(prefs).recordTapForRoute(route);
  }

  Future<void> recordTapForRoute(String route) async {
    final count = _prefs.getInt('$_countPrefix$route') ?? 0;
    await _prefs.setInt('$_countPrefix$route', count + 1);
    await _prefs.setInt(
      '$_lastUsedPrefix$route',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  int tapCount(String route) => _prefs.getInt('$_countPrefix$route') ?? 0;

  int lastUsedMillis(String route) =>
      _prefs.getInt('$_lastUsedPrefix$route') ?? 0;

  List<QuickActionTool> sortByUsage(List<QuickActionTool> tools) {
    final sorted = List<QuickActionTool>.from(tools);
    sorted.sort((a, b) {
      final countCompare = tapCount(b.route).compareTo(tapCount(a.route));
      if (countCompare != 0) return countCompare;
      return lastUsedMillis(b.route).compareTo(lastUsedMillis(a.route));
    });
    return sorted;
  }

  List<QuickActionTool> sortedDailyEssentials() {
    return sortByUsage(DailyEssentialRoutes.catalogTools());
  }
}
