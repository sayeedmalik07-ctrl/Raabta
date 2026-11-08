import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_auth_client.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_controller.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_prefs.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_providers.dart';

/// Gates sensitive local safety data behind OS authentication (Phase 34).
class SensitiveSafetyLockGate extends ConsumerStatefulWidget {
  const SensitiveSafetyLockGate({
    super.key,
    required this.locale,
    required this.child,
    this.obscureInAppSwitcher = true,
  });

  final String locale;
  final Widget child;
  final bool obscureInAppSwitcher;

  @override
  ConsumerState<SensitiveSafetyLockGate> createState() =>
      _SensitiveSafetyLockGateState();
}

class _SensitiveSafetyLockGateState extends ConsumerState<SensitiveSafetyLockGate>
    with WidgetsBindingObserver {
  bool _switcherObscured = false;
  bool _entryPromptScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(sensitiveSafetyLockControllerProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        controller.onAppPaused();
        if (widget.obscureInAppSwitcher) {
          setState(() => _switcherObscured = true);
        }
      case AppLifecycleState.resumed:
        controller.onAppResumed();
        if (mounted) setState(() => _switcherObscured = false);
      default:
        break;
    }
  }

  void _scheduleEntryPrompt() {
    if (_entryPromptScheduled) return;
    _entryPromptScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    final controller = ref.read(sensitiveSafetyLockControllerProvider);
    final reason = ScamShieldStrings.t('ss_sensitive_lock_reason', widget.locale);
    final outcome = await controller.unlock(reason: reason);
    if (!mounted) return;
    switch (outcome) {
      case SensitiveSafetyAuthOutcome.success:
        setState(() {});
      case SensitiveSafetyAuthOutcome.notAvailable:
        await SensitiveSafetyLockPrefs.setEnabled(false);
        ref.invalidate(sensitiveSafetyLockEnabledProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ScamShieldStrings.t('ss_sensitive_lock_unavailable', widget.locale),
              ),
            ),
          );
          context.pop();
        }
      case SensitiveSafetyAuthOutcome.cancelled:
      case SensitiveSafetyAuthOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ScamShieldStrings.t('ss_sensitive_lock_cancelled', widget.locale),
            ),
          ),
        );
        context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabledAsync = ref.watch(sensitiveSafetyLockEnabledProvider);
    return enabledAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => widget.child,
      data: (enabled) {
        if (!enabled) return widget.child;

        final session = ref.watch(sensitiveSafetyLockSessionProvider);
        if (!session.isUnlocked) {
          _scheduleEntryPrompt();
          return _LockPlaceholder(locale: widget.locale, onUnlock: _unlock);
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (_switcherObscured) const _AppSwitcherPrivacyOverlay(),
          ],
        );
      },
    );
  }
}

class _LockPlaceholder extends StatelessWidget {
  const _LockPlaceholder({
    required this.locale,
    required this.onUnlock,
  });

  final String locale;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.cyanGlow),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_sensitive_lock_gate_title', locale),
              style: AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t('ss_sensitive_lock_privacy_line', locale),
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: ScamShieldStrings.t('ss_sensitive_lock_unlock_cta', locale),
              expand: true,
              onPressed: onUnlock,
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(ScamShieldStrings.t('ss_sensitive_lock_go_back', locale)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppSwitcherPrivacyOverlay extends StatelessWidget {
  const _AppSwitcherPrivacyOverlay();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: AppColors.surface.withValues(alpha: 0.92),
            alignment: Alignment.center,
            child: Icon(
              Icons.shield_outlined,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
