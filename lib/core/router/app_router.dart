import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/screens/ai_chat/ai_chat_screen.dart';
import 'package:raabta/screens/businesses/businesses_screen.dart';
import 'package:raabta/screens/community/community_screen.dart';
import 'package:raabta/screens/community/news_screen.dart';
import 'package:raabta/screens/doctors/doctors_screen.dart';
import 'package:raabta/screens/expat_score/expat_score_screen.dart';
import 'package:raabta/screens/home_screen.dart';
import 'package:raabta/screens/housing/housing_screen.dart';
import 'package:raabta/screens/jobs/jobs_screen.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:raabta/screens/login_screen.dart';
import 'package:raabta/screens/marketplace/marketplace_screen.dart';
import 'package:raabta/screens/monetization/business_advertise_screen.dart';
import 'package:raabta/screens/monetization/boost_listing_screen.dart';
import 'package:raabta/screens/monetization/premium_subscription_screen.dart';
import 'package:raabta/screens/money/money_screen.dart';
import 'package:raabta/screens/notifications/notification_center_screen.dart';
import 'package:raabta/screens/notifications/notification_settings_screen.dart';
import 'package:raabta/screens/profile/profile_screen.dart';
import 'package:raabta/screens/splash_screen.dart';
import 'package:raabta/screens/visa/visa_screen.dart';
import 'package:raabta/features/quick_actions/landmark_translator_screen.dart';
import 'package:raabta/features/quick_actions/bill_splitter_screen.dart';
import 'package:raabta/features/quick_actions/barcode_scanner_screen.dart';
import 'package:raabta/features/quick_actions/doc_scanner_screen.dart';
import 'package:raabta/features/quick_actions/warranty_shield_screen.dart';
import 'package:raabta/features/quick_actions/climate_navigator_screen.dart';
import 'package:raabta/features/quick_actions/queue_avoidance_screen.dart';
import 'package:raabta/features/quick_actions/bill_tracker_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const JobsScreen(),
    ),
    GoRoute(
      path: '/housing',
      builder: (context, state) => const HousingScreen(),
    ),
    GoRoute(
      path: '/businesses',
      builder: (context, state) => const BusinessesScreen(),
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: '/community/events',
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: '/news',
      builder: (context, state) => const NewsScreen(),
    ),
    GoRoute(
      path: '/visa',
      builder: (context, state) => const VisaScreen(),
    ),
    GoRoute(
      path: '/money',
      builder: (context, state) => const MoneyScreen(),
    ),
    GoRoute(
      path: '/doctors',
      builder: (context, state) => const DoctorsScreen(),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/ai-chat',
      builder: (context, state) {
        final extra = state.extra;
        String? initialMessage;
        if (extra is Map<String, dynamic>) {
          initialMessage = extra['query'] as String?;
        } else if (extra is String) {
          initialMessage = extra;
        }
        return AiChatScreen(initialMessage: initialMessage);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/expat-score',
      builder: (context, state) => const ExpatScoreScreen(),
    ),
    GoRoute(
      path: '/business-advertise',
      builder: (context, state) => const BusinessAdvertiseScreen(),
    ),
    GoRoute(
      path: '/advertise',
      builder: (context, state) => const BusinessAdvertiseScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumSubscriptionScreen(),
    ),
    GoRoute(
      path: '/boost-listing',
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map<String, dynamic> ? extra : const {};
        return BoostListingScreen(
          listingTitle: map['title'] as String? ?? 'Your Listing',
          currentViews: map['views'] as int? ?? 0,
          currentContacts: map['contacts'] as int? ?? 0,
          listingId: map['id'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const DocScannerScreen(),
    ),
    GoRoute(
      path: '/barcode-scanner',
      builder: (context, state) => const BarcodeScannerScreen(),
    ),
    GoRoute(
      path: '/landmark-translator',
      builder: (context, state) => const LandmarkTranslatorScreen(),
    ),
    GoRoute(
      path: '/bill-splitter',
      builder: (context, state) => const BillSplitterScreen(),
    ),
    GoRoute(
      path: '/warranty-shield',
      builder: (context, state) => const WarrantyShieldScreen(),
    ),
    GoRoute(
      path: '/climate-navigator',
      builder: (context, state) => const ClimateNavigatorScreen(),
    ),
    GoRoute(
      path: '/queue-avoidance',
      builder: (context, state) => const QueueAvoidanceScreen(),
    ),
    GoRoute(
      path: '/bill-tracker',
      builder: (context, state) => const BillTrackerScreen(),
    ),
  ],
);
