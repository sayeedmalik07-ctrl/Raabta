import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';

/// Routes users to PDF Studio — reuses existing scanner pipeline.
class PolicyUploadScreen extends ConsumerWidget {
  const PolicyUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_dashboard_upload_cta', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HealthInsuranceDisclaimerBanner(
                locale: locale,
                strongPolicyDisclaimer: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                HealthInsuranceStrings.t('hi_upload_hint', locale),
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                HealthInsuranceStrings.t('hi_policy_empty_desc', locale),
                style: AppTypography.bodySmall,
              ),
              const Spacer(),
              GlassPrimaryButton(
                label: HealthInsuranceStrings.t('hi_dashboard_upload_cta', locale),
                expand: true,
                accentColor: AppColors.chipScanner,
                icon: Icons.document_scanner_outlined,
                onPressed: () => context.push('/scanner/capture'),
              ),
            ],
          ),
        );
      },
    );
  }
}
