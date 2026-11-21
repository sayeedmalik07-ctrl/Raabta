import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/connectivity/connectivity_banner.dart';
import 'package:raabta/core/connectivity/connectivity_provider.dart';
import 'package:raabta/core/l10n/locale_sync_scope.dart';
import 'package:raabta/core/router/app_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/theme/app_theme.dart';
import 'package:raabta/core/theme/theme_notifier.dart';
import 'package:raabta/firebase_options.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_date_formatter.dart';
import 'package:raabta/services/notifications/notification_service.dart';
import 'package:raabta/services/drafts/draft_form_registry.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:raabta/features/admin/services/app_startup_guard.dart';
import 'package:raabta/features/eosb/services/reengagement_session.dart';
import 'package:raabta/features/onboarding/services/onboarding_analytics_service.dart';
import 'package:raabta/features/auth/widgets/account_suspension_listener.dart';
import 'package:raabta/features/auth/widgets/auth_session_listener.dart';
import 'package:raabta/features/auth/widgets/local_data_isolation_listener.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/services/referral/referral_link_handler.dart';
import 'package:raabta/features/scam_shield/platform/scam_shield_entry_route_platform.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_helpers.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_share_handler.dart';
import 'package:raabta/services/life_intelligence/life_intelligence_push_ack_repository.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await BillTrackerDateFormatter.warmUp();

  runApp(
    const ProviderScope(
      child: RaabtaApp(),
    ),
  );

  unawaited(_bootstrapAppServices());
}

Future<void> _bootstrapAppServices() async {
  try {
    await FirebaseService.initialize();
    await AuthSessionService.instance.initialize();
    await NotificationService.initialize();
    await DraftService.instance.init();
    registerAllDraftableForms();
    await RaabtaNotificationService.instance.initialize(
      onTap: (route, data) async {
        final trigger = data['reengagementTrigger'] as String?;
        if (trigger != null && trigger.isNotEmpty) {
          OnboardingAnalyticsService.reengagementOpened(trigger);
          ReengagementSession.markOpened(trigger);
        }
        final liAckToken = data['lifeIntelligenceAckToken'] as String?;
        if (liAckToken != null && liAckToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await LifeIntelligencePushAckRepository(prefs).recordOpened(liAckToken);
        }
        appRouter.go(ComplianceFlagsGate.resolveNotificationRoute(route));
      },
    );
    await ReferralLinkHandler.instance.initialize();
    await ScamShieldShareHandler.instance.initialize();
    await ScamAnonymousSignalHelpers.bootstrapUploadIfOptedIn();
    await ScamShieldEntryRoutePlatform.consumePendingEntryRoute();
    LastActiveTracker.instance.register();
  } catch (e, stack) {
    debugPrint('App bootstrap failed: $e\n$stack');
  }
}

class RaabtaApp extends ConsumerWidget {
  const RaabtaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    ref.watch(connectivityStatusProvider);
    ref.watch(complianceFlagsSyncProvider);

    return MaterialApp.router(
      title: 'Raabta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: AppSpacing.contentAnimation,
      themeAnimationCurve: Curves.easeOutCubic,
      routerConfig: appRouter,
      builder: (context, child) => LocalDataIsolationListener(
        child: AuthSessionListener(
          child: AccountSuspensionListener(
            child: LocaleSyncScope(
              child: ThemeSyncScope(
                child: ColoredBox(
                  color: AppColors.background,
                  child: ConnectivityScope(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
