import 'package:raabta/features/quick_actions/quick_actions_hub.dart';

/// Routes surfaced on the Home Daily Essentials section (cluster layout).
abstract final class DailyEssentialRoutes {
  static const smartDocumentRoutes = <String>[
    '/scanner/capture',
    '/barcode-scanner',
  ];

  static const protectionRoutes = <String>[
    '/warranty-shield',
  ];

  static const standaloneRoutes = <String>[
    '/bill-splitter',
    '/bill-tracker',
    '/leaving-qatar',
  ];

  static const routes = <String>[
    ...smartDocumentRoutes,
    ...protectionRoutes,
    ...standaloneRoutes,
  ];

  static const maxVisibleOnHome = 6;

  static List<QuickActionTool> catalogTools() {
    return QuickActionsHub.tools
        .where((tool) => routes.contains(tool.route))
        .toList();
  }

  static List<QuickActionTool> toolsForRoutes(List<String> routeList) {
    return routeList
        .map(
          (route) => QuickActionsHub.tools.firstWhere(
            (tool) => tool.route == route,
          ),
        )
        .toList();
  }
}
