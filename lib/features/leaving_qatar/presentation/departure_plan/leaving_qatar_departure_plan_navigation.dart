import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_eosb_card.dart';

/// Executes verified navigation for departure-plan rows.
abstract final class LeavingQatarDeparturePlanNavigation {
  static Future<void> openItem({
    required BuildContext context,
    required DeparturePlanItemDefinition item,
    GlobalKey? timelineSectionKey,
    GlobalKey? closeoutSectionKey,
  }) async {
    switch (item.navigationTarget) {
      case DeparturePlanNavigationTarget.externalRoute:
        final path = item.routePath;
        if (path == null || path.isEmpty) return;
        context.push(path);
      case DeparturePlanNavigationTarget.officialPortal:
        final url = item.officialSourceUrl;
        if (url == null || url.isEmpty) return;
        await openLeavingQatarOfficialLink(url);
      case DeparturePlanNavigationTarget.inScreenTimeline:
        await _scrollToKey(context, timelineSectionKey);
      case DeparturePlanNavigationTarget.inScreenCloseout:
        await _scrollToKey(context, closeoutSectionKey);
    }
  }

  static Future<void> _scrollToKey(
    BuildContext context,
    GlobalKey? key,
  ) async {
    final targetContext = key?.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }
}
