import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_flow.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:permission_handler/permission_handler.dart';

class ScamCallScreeningOptInScreen extends ConsumerWidget {
  const ScamCallScreeningOptInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));

    return HubSubscreenScaffold(
      title: ScamShieldStrings.t('ss_call_screening_title', locale),
      subtitle: ScamShieldStrings.t('ss_protection_guide_subtitle', locale),
      onBack: () => context.pop(),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ScamShieldStrings.t('ss_call_screening_body', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ScamShieldStrings.t('ss_call_screening_optional', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassPrimaryButton(
                    label: ScamShieldStrings.t('ss_call_screening_cta', locale),
                    expand: true,
                    accentColor: AppColors.brandFamilyMain,
                    onPressed: () async {
                      final ok = await PermissionRationaleFlow.showThenContinue(
                        context,
                        kind: PermissionRationaleKind.androidCallScreening,
                        locale: locale,
                      );
                      if (!ok) return;
                      await ref
                          .read(scamProactiveProtectionPlatformProvider)
                          .requestCallScreeningRole();
                      ref.invalidate(scamProactiveProtectionStatusProvider);
                      if (context.mounted) context.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HubFeedFooterNotice(locale: locale),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }
}

class ScamSmsFilterGuideScreen extends ConsumerWidget {
  const ScamSmsFilterGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));

    return HubSubscreenScaffold(
      title: ScamShieldStrings.t('ss_sms_filter_title', locale),
      subtitle: ScamShieldStrings.t('ss_protection_guide_subtitle', locale),
      onBack: () => context.pop(),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ScamShieldStrings.t('ss_sms_filter_body', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final key in [
                    'ss_sms_filter_step_1',
                    'ss_sms_filter_step_2',
                    'ss_sms_filter_step_3',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        '• ${ScamShieldStrings.t(key, locale)}',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  if (Platform.isIOS)
                    GlassPrimaryButton(
                      label: ScamShieldStrings.t(
                        'ss_sms_filter_open_settings',
                        locale,
                      ),
                      expand: true,
                      accentColor: AppColors.brandFamilyMain,
                      onPressed: () async {
                        final ok =
                            await PermissionRationaleFlow.showThenContinue(
                          context,
                          kind: PermissionRationaleKind.iosSmsFilterSettings,
                          locale: locale,
                        );
                        if (!ok) return;
                        await openAppSettings();
                      },
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(scamProactiveProtectionPlatformProvider)
                          .confirmSmsFilterEnabled();
                      ref.invalidate(scamProactiveProtectionStatusProvider);
                      if (context.mounted) context.pop();
                    },
                    child: Text(
                      ScamShieldStrings.t('ss_sms_filter_confirm', locale),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HubFeedFooterNotice(locale: locale),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }
}
