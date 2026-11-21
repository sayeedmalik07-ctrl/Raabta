import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_models.dart';

abstract final class ScamTypeDeepLink {
  static String routePath(ScamTypeActionLink link) {
    return switch (link) {
      ScamTypeActionLink.officialDirectory => '/scam-shield/official-directory',
      ScamTypeActionLink.paymentCheck => '/scam-shield/payment-check',
      ScamTypeActionLink.incident => '/scam-shield/incident',
      ScamTypeActionLink.familyVerification =>
        '/scam-shield/family-verification',
      ScamTypeActionLink.authorityDirectory => '/scam-shield/directory',
      ScamTypeActionLink.academy => '/scam-shield/academy',
      ScamTypeActionLink.checkup => '/scam-shield/checkup',
      ScamTypeActionLink.simSwap => '/scam-shield/sim-swap',
      ScamTypeActionLink.tenancyHub => '/tenancy',
    };
  }

  static void go(BuildContext context, ScamTypeActionLink link) {
    context.push(routePath(link));
  }
}
