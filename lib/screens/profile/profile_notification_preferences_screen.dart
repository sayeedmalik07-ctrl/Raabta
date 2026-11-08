import 'package:raabta/features/notification_preferences/presentation/screens/notification_preferences_screen.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';
import 'package:flutter/material.dart';

/// Wraps notification preferences with Profile bottom nav (screen lives outside profile/).
class ProfileNotificationPreferencesScreen extends StatelessWidget {
  const ProfileNotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileTabScaffold(
      child: NotificationPreferencesScreen(),
    );
  }
}
