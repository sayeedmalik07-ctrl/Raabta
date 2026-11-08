import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_type_library_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_already_lost_money_button.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_catalog.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_deep_link.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_models.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamTypeLibraryListScreen extends ConsumerWidget {
  const ScamTypeLibraryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final verifiedAsync = ref.watch(scamTypeVerifiedProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        enableBackgroundAnimation: false,
        title: ScamShieldStrings.t('ss_scam_types_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: verifiedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(ScamShieldStrings.t('ss_scam_types_load_error', locale)),
          ),
          data: (verified) {
            if (verified.isEmpty) {
              return ListView(
                children: [
                  Text(
                    ScamShieldStrings.t('ss_scam_types_subtitle', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ScamShieldStrings.t('ss_scam_types_pending_verify', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.push('/scam-shield/academy'),
                    child: Text(
                      ScamShieldStrings.t('ss_scam_types_academy_link', locale),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              children: [
                Text(
                  ScamShieldStrings.t('ss_scam_types_subtitle', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final type in verified)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GlassCard(
                      child: ListTile(
                        title: Text(
                          ScamTypeLibraryStrings.t(type.titleKey, locale),
                          style: AppTypography.body,
                        ),
                        subtitle: Text(
                          ScamTypeLibraryStrings.t(type.howItWorksKey, locale),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption,
                        ),
                        trailing: Icon(
                          isRtl ? Icons.chevron_left : Icons.chevron_right,
                        ),
                        onTap: () =>
                            context.push('/scam-shield/scam-types/${type.id}'),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => context.push('/scam-shield/academy'),
                  child: Text(
                    ScamShieldStrings.t('ss_scam_types_academy_link', locale),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ScamTypeLibraryDetailScreen extends ConsumerWidget {
  const ScamTypeLibraryDetailScreen({super.key, required this.typeId});

  final String typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final catalogAsync = ref.watch(scamTypeCatalogProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        enableBackgroundAnimation: false,
        title: ScamShieldStrings.t('ss_scam_types_detail_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: catalogAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (all) {
            final type = ScamTypeCatalog.byId(all, typeId);
            if (type == null || !type.verified) {
              return Center(
                child: Text(
                  ScamShieldStrings.t('ss_scam_types_not_found', locale),
                ),
              );
            }
            return ListView(
              children: [
                Text(
                  ScamTypeLibraryStrings.t(type.titleKey, locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ScamTypeLibraryStrings.t(type.howItWorksKey, locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ScamShieldStrings.t('ss_scam_types_red_flags', locale),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final key in type.redFlagKeys)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '• ${ScamTypeLibraryStrings.t(key, locale)}',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ScamShieldStrings.t('ss_scam_types_what_to_do', locale),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (var i = 0; i < type.whatToDo.length; i++)
                  _whatToDoRow(context, locale, i + 1, type.whatToDo[i]),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ScamShieldStrings.t('ss_scam_types_example', locale),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamTypeLibraryStrings.t(type.exampleKey, locale),
                  style: AppTypography.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final src in type.sourceLabelKeys)
                  Text(
                    '${ScamTypeLibraryStrings.t(src, locale)} · '
                    '${ScamShieldStrings.t('ss_scam_types_pattern_check', locale)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                Text(
                  ScamShieldStrings.format(
                    'ss_scam_types_last_reviewed',
                    locale,
                    {
                      'date': DateFormat.yMMMd(locale).format(type.lastReviewed),
                    },
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                ScamAlreadyLostMoneyTextButton(locale: locale),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _whatToDoRow(
    BuildContext context,
    String locale,
    int index,
    ScamTypeWhatToDoStep step,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: InkWell(
        onTap: () => ScamTypeDeepLink.go(context, step.link),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index.', style: AppTypography.bodySmall),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                ScamTypeLibraryStrings.t(step.labelKey, locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cyanGlow,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
