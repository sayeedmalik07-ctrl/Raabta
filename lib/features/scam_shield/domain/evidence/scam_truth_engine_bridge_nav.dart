import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_truth_engine_bridges.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';

/// Route-only navigation for truth-engine bridges — no message text in extras.
abstract final class ScamTruthEngineBridgeNav {
  static Object? routeExtraFor(ScamTruthEngineBridgeAction action) {
    final ctx = action.paymentContext;
    if (ctx != null) {
      return PaymentCheckPrefill(context: ctx);
    }
    return null;
  }

  static void go(BuildContext context, ScamTruthEngineBridgeAction action) {
    final extra = routeExtraFor(action);
    if (extra != null) {
      context.push(action.routePath, extra: extra);
    } else {
      context.push(action.routePath);
    }
  }
}
