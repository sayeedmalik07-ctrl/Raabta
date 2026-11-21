import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';

/// Rebuilds [child] whenever the global app locale changes.
///
/// Use on pushed sub-screens that don't already watch [appLocaleProvider].
class LocaleBoundScope extends ConsumerWidget {
  const LocaleBoundScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return KeyedSubtree(
      key: ValueKey('locale_bound_$locale'),
      child: child,
    );
  }
}

/// Wraps a GoRouter route builder child for locale-aware rebuilds.
Widget localeRoute(Widget child) => LocaleBoundScope(child: child);
