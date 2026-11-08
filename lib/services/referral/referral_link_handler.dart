import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/core/router/app_router.dart';
import 'package:raabta/services/referral/pending_referral_store.dart';
import 'package:raabta/services/referral/referral_analytics_service.dart';
import 'package:raabta/services/referral/referral_deep_links.dart';

/// Listens for cold-start and warm universal/custom-scheme invite links.
class ReferralLinkHandler {
  ReferralLinkHandler._();

  static final instance = ReferralLinkHandler._();
  static final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> initialize() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleUri(initial);
      }
    } catch (e) {
      debugPrint('ReferralLinkHandler initial link: $e');
    }

    await _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handleUri(uri)),
      onError: (e) => debugPrint('ReferralLinkHandler stream: $e'),
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handleUri(Uri uri) async {
    final code = ReferralDeepLinks.parseCodeFromUri(uri);
    if (code == null) return;

    await PendingReferralStore.save(code);
    await ReferralAnalyticsService.referralLinkOpened(code);

    appRouter.go('/invite/$code');
  }
}
