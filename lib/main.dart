import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/router/app_router.dart';
import 'package:raabta/core/theme/app_theme.dart';
import 'package:raabta/core/theme/theme_notifier.dart';
import 'package:raabta/firebase_options.dart';
import 'package:raabta/services/deadline_notification_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/raabta_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseService.initialize();
  await DeadlineNotificationService.instance.initialize();
  await RaabtaNotificationService.instance.initialize(
    onTap: (route, _) => appRouter.go(route),
  );
  runApp(
    const ProviderScope(
      child: RaabtaApp(),
    ),
  );
}

class RaabtaApp extends ConsumerWidget {
  const RaabtaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Raabta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) => ThemeRebuildScope(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
