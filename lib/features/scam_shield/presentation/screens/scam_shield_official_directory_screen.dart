import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_external_link_launcher.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldOfficialDirectoryScreen extends ConsumerStatefulWidget {
  const ScamShieldOfficialDirectoryScreen({super.key});

  @override
  ConsumerState<ScamShieldOfficialDirectoryScreen> createState() =>
      _ScamShieldOfficialDirectoryScreenState();
}

class _ScamShieldOfficialDirectoryScreenState
    extends ConsumerState<ScamShieldOfficialDirectoryScreen> {
  final _searchController = TextEditingController();
  OfficialDirectoryCategory? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final bootstrap = ref.watch(officialDirectoryBootstrapProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_official_dir_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: bootstrap.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _body(locale, verified: const []),
          data: (_) {
            final verified = OfficialDirectory.snapshot.verifiedEntries;
            final filtered = OfficialDirectory.search(
              query: _searchController.text,
              category: _category,
            );
            return _body(locale, verified: verified, filtered: filtered);
          },
        ),
      ),
    );
  }

  Widget _body(
    String locale, {
    required List<OfficialDirectoryEntry> verified,
    List<OfficialDirectoryEntry>? filtered,
  }) {
    final showList = filtered ?? verified;
    return ListView(
      children: [
        Text(
          ScamShieldStrings.t('ss_official_dir_subtitle', locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_official_dir_guidance', locale),
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_official_dir_affiliation_notice', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: ScamShieldStrings.t('ss_official_dir_search_hint', locale),
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        ScamShieldOptionChips<OfficialDirectoryCategory?>(
          options: [null, ...OfficialDirectoryCategory.values],
          selected: _category,
          labelFor: (c) => c == null
              ? ScamShieldStrings.t('ss_official_dir_cat_all', locale)
              : ScamShieldStrings.t(c!.labelKey, locale),
          onSelected: (c) => setState(() => _category = c),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (verified.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              ScamShieldStrings.t('ss_official_dir_growing', locale),
              style: AppTypography.bodySmall,
            ),
          )
        else if (showList.isEmpty)
          Text(
            ScamShieldStrings.t('ss_official_dir_no_results', locale),
            style: AppTypography.bodySmall,
          )
        else
          ...showList.map((entry) => _entryCard(entry, locale)),
      ],
    );
  }

  Widget _entryCard(OfficialDirectoryEntry entry, String locale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.displayName(locale),
              style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w700),
            ),
            if (entry.publisherName.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                ScamShieldStrings.t('ss_official_dir_publisher', locale)
                    .replaceAll('{name}', entry.publisherName),
                style: AppTypography.caption,
              ),
            ],
            if (entry.officialDomains.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                ScamShieldStrings.t('ss_official_dir_domains_label', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                entry.officialDomains.join(', '),
                style: AppTypography.bodySmall,
              ),
            ],
            if (entry.lastVerified != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                entry.isStale
                    ? ScamShieldStrings.t('ss_official_dir_stale', locale)
                    : ScamShieldStrings.t('ss_official_dir_last_verified', locale)
                        .replaceAll(
                          '{date}',
                          entry.lastVerified!.toIso8601String().split('T').first,
                        ),
                style: AppTypography.caption.copyWith(
                  color: entry.isStale
                      ? AppColors.warning
                      : AppColors.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                if (entry.androidStoreUrl.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () =>
                        ScamExternalLinkLauncher.openUrl(entry.androidStoreUrl),
                    icon: const Icon(Icons.android, size: 16),
                    label: Text(
                      ScamShieldStrings.t('ss_official_dir_play_store', locale),
                    ),
                  ),
                if (entry.iosStoreUrl.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () =>
                        ScamExternalLinkLauncher.openUrl(entry.iosStoreUrl),
                    icon: const Icon(Icons.apple, size: 16),
                    label: Text(
                      ScamShieldStrings.t('ss_official_dir_app_store', locale),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
