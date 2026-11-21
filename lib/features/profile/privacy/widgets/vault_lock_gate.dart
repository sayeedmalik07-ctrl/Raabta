import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/profile/privacy/providers/privacy_providers.dart';
import 'package:raabta/features/profile/privacy/services/vault_lock_service.dart';

/// Gates Document Vault when the shared PIN lock is enabled.
///
/// Must be placed inside a [Scaffold] body so [TextField] has a Material ancestor.
class VaultLockGate extends ConsumerStatefulWidget {
  const VaultLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<VaultLockGate> createState() => _VaultLockGateState();
}

class _VaultLockGateState extends ConsumerState<VaultLockGate> {
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _tryUnlock(VaultLockService lock) {
    final pin = _pinController.text.trim();
    if (!lock.verifyPin(pin)) {
      setState(() => _error = 'Incorrect PIN');
      return;
    }
    lock.unlockSession(pin);
    setState(() => _error = null);
  }

  Widget _buildLockPanel(VaultLockService lock) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: AppColors.cyanGlow,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Document Vault locked',
                      style: AppTypography.headline2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your PIN or manage lock in Profile → Privacy.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'PIN',
                        labelStyle: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassSecondary
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                        errorText: _error,
                        filled: true,
                        fillColor: AppColors.isLight
                            ? AppColors.glassSurface
                            : Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.isLight
                                ? AppColors.glassBorder
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _tryUnlock(lock),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassPrimaryButton(
                      label: 'Unlock',
                      expand: true,
                      onPressed: () => _tryUnlock(lock),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lockAsync = ref.watch(vaultLockServiceProvider);

    return lockAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => widget.child,
      data: (lock) {
        if (!lock.isEnabled || lock.isSessionUnlocked) {
          return widget.child;
        }
        return _buildLockPanel(lock);
      },
    );
  }
}
