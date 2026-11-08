import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/router/app_router.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

/// Shows a calm explanation when Firebase ends a session unexpectedly.
class AuthSessionListener extends ConsumerStatefulWidget {
  const AuthSessionListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthSessionListener> createState() =>
      _AuthSessionListenerState();
}

class _AuthSessionListenerState extends ConsumerState<AuthSessionListener> {
  bool _dialogVisible = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      final prevUser = previous?.valueOrNull;
      final nextUser = next.valueOrNull;

      if (prevUser != null && nextUser == null) {
        if (AuthSessionService.instance.consumeSuppressSessionEndedNotice()) {
          return;
        }
        _showSessionEndedNotice();
      }
    });

    return widget.child;
  }

  void _showSessionEndedNotice() {
    if (_dialogVisible) return;
    _dialogVisible = true;

    final reason = AuthSessionService.instance.lastSessionEndedReason ??
        'Your session ended. Please sign in again to continue.';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navContext = rootNavigatorKey.currentContext;
      if (navContext == null || !navContext.mounted) {
        _dialogVisible = false;
        return;
      }

      showDialog<void>(
        context: navContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Sign in required'),
            content: Text(reason),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _dialogVisible = false;
                  navContext.go('/login');
                },
                child: const Text('Sign in again'),
              ),
            ],
          );
        },
      ).whenComplete(() => _dialogVisible = false);
    });
  }
}
