import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/router/app_router.dart';
import 'package:raabta/features/admin/admin_access.dart';
import 'package:raabta/features/admin/services/user_suspension.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/signed_in_user_profile_provider.dart';

/// Redirects to [/suspended] when the live user doc shows suspension mid-session.
class AccountSuspensionListener extends ConsumerWidget {
  const AccountSuspensionListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Map<String, dynamic>?>>(
      signedInUserFirestoreProfileProvider,
      (previous, next) {
        final user = ref.read(currentUserProvider);
        if (user == null || AdminAccess.isAdminUser(user)) return;

        final data = next.valueOrNull;
        if (data == null) return;
        if (!UserSuspension.isSuspendedMap(data)) return;

        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null || !navContext.mounted) return;

        if (appRouter.state.uri.path == '/suspended') return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!navContext.mounted) return;
          appRouter.go('/suspended');
        });
      },
    );

    return child;
  }
}
