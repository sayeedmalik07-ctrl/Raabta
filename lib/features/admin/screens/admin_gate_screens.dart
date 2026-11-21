import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/admin/services/app_startup_guard.dart';
import 'package:raabta/services/app_update_service.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final message = AppStartupGuard.cachedConfig?.maintenanceMessage ??
        'Raabta is under maintenance. Please check back soon.';

    return GlassScreenScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build_circle_outlined,
                  size: 64, color: AppColors.amberGlow),
              const SizedBox(height: AppSpacing.lg),
              Text('Maintenance', style: AppTypography.headline1),
              const SizedBox(height: AppSpacing.md),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  Future<void> _openStore(BuildContext context) async {
    final outcome = await AppUpdateService.openStoreListing();
    if (!context.mounted) return;
    if (outcome == AppUpdateOutcome.unavailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not open the app store. Please search for Raabta manually.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final minVersion =
        AppStartupGuard.cachedConfig?.minimumVersion ?? '1.0.0';

    return GlassScreenScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update_alt,
                  size: 64, color: AppColors.cyanGlow),
              const SizedBox(height: AppSpacing.lg),
              Text('Update required', style: AppTypography.headline1),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Please update Raabta to version $minVersion or later '
                'to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: GlassPrimaryButton(
                  label: 'Update now',
                  icon: Icons.open_in_new,
                  onPressed: () => _openStore(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuspendedAccountScreen extends StatelessWidget {
  const SuspendedAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScreenScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Account suspended', style: AppTypography.headline1),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Your account has been suspended. Contact support if you '
                'believe this is a mistake.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureDisabledScreen extends StatelessWidget {
  const FeatureDisabledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScreenScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppColors.warning),
              const SizedBox(height: AppSpacing.lg),
              Text('Feature unavailable', style: AppTypography.headline1),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'This feature is temporarily disabled. Please try again later.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
