import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';

/// Forces full subtree rebuild + RTL when locale changes in-session.
class LocaleSyncScope extends ConsumerWidget {
  const LocaleSyncScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: KeyedSubtree(
        key: ValueKey('app_locale_$locale'),
        child: child,
      ),
    );
  }
}
