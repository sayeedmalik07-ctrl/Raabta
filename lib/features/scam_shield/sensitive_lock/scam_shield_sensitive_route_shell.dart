import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_gate.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Wraps a Scam Shield route that shows sensitive local data (Phase 34).
class ScamShieldSensitiveRouteShell extends ConsumerWidget {
  const ScamShieldSensitiveRouteShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    return SensitiveSafetyLockGate(locale: locale, child: child);
  }
}
