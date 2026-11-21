import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';

/// One-time-per-session hint after leaving a post flow with a saved draft.
abstract final class PostDraftRelocatedSnackbar {
  static var _shownThisSession = false;
  static var _pending = false;

  static void markPending() {
    if (!_shownThisSession) _pending = true;
  }

  static void maybeShow(BuildContext context, String locale) {
    if (!_pending || _shownThisSession || !context.mounted) return;
    _pending = false;
    _shownThisSession = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppShellStrings.t('draft_saved_profile_snackbar', locale)),
        action: SnackBarAction(
          label: AppShellStrings.t('draft_saved_profile_snackbar_action', locale),
          onPressed: () => context.push('/profile/my-activity'),
        ),
      ),
    );
  }

  @visibleForTesting
  static void resetSessionForTests() {
    _shownThisSession = false;
    _pending = false;
  }
}
