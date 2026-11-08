import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/features/eosb/data/models/return_support_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/welcome_home/domain/welcome_home_fly_checklist_service.dart';
import 'package:raabta/features/welcome_home/presentation/l10n/welcome_home_strings.dart';
import 'package:raabta/features/welcome_home/providers/welcome_home_providers.dart';
import 'package:raabta/features/welcome_home/services/welcome_home_analytics.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeHomeScreen extends ConsumerStatefulWidget {
  const WelcomeHomeScreen({super.key});

  static const route = '/welcome-home';

  @override
  ConsumerState<WelcomeHomeScreen> createState() => _WelcomeHomeScreenState();
}

class _WelcomeHomeScreenState extends ConsumerState<WelcomeHomeScreen> {
  String? _sessionCountryId;

  @override
  void initState() {
    super.initState();
    WelcomeHomeAnalytics.screenOpened();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final viewAsync =
        ref.watch(welcomeHomeReturnSupportViewProvider(_sessionCountryId));
    final checklistAsync = ref.watch(welcomeHomeFlyChecklistProvider);

    return GlassScreenScaffold(
      title: WelcomeHomeStrings.t('wh_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: viewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Text(WelcomeHomeStrings.t('wh_screen_intro', locale)),
        data: (view) => ListView(
          children: [
            Text(
              WelcomeHomeStrings.t('wh_screen_intro', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              WelcomeHomeStrings.t('wh_country_picker_heading', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              WelcomeHomeStrings.t('wh_country_picker_hint', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...MigrantSupportCatalog.countries.map((country) {
              final selected = _sessionCountryId == country.countryId;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  onTap: () =>
                      setState(() => _sessionCountryId = country.countryId),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  glowColor:
                      selected ? AppColors.info : AppColors.glassBorder,
                  glowIntensity: selected ? 0.16 : 0.05,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          EosbStrings.t(country.displayNameKey, locale),
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle, color: AppColors.info),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            _ProgrammeSection(
              view: view,
              locale: locale,
              onOpenUrl: (url, id) {
                WelcomeHomeAnalytics.programmeLinkTapped(id);
                _openUrl(url);
              },
              onOpenFallback: (link) {
                WelcomeHomeAnalytics.fallbackLinkTapped(link.id);
                if (link.url != null) _openUrl(link.url!);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              WelcomeHomeStrings.t('wh_checklist_heading', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              WelcomeHomeStrings.t('wh_checklist_note', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...WelcomeHomeFlyChecklistService.itemIds.map((id) {
              final done = checklistAsync.valueOrNull?[id] == true;
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: done,
                onChanged: (v) async {
                  await ref
                      .read(welcomeHomeFlyChecklistServiceProvider)
                      .setItem(itemId: id, completed: v ?? false);
                  ref.invalidate(welcomeHomeFlyChecklistProvider);
                },
                title: Text(
                  WelcomeHomeStrings.checklistLabel(id, locale),
                  style: AppTypography.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            _ChecklistActions(locale: locale),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.push('/scam-shield'),
              child: Text(
                '${WelcomeHomeStrings.t('wh_scam_caution', locale)} · ${WelcomeHomeStrings.t('wh_scam_link', locale)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeSection extends StatelessWidget {
  const _ProgrammeSection({
    required this.view,
    required this.locale,
    required this.onOpenUrl,
    required this.onOpenFallback,
  });

  final WelcomeHomeReturnSupportView view;
  final String locale;
  final void Function(String url, String programmeId) onOpenUrl;
  final void Function(ReturnSupportFallbackLinkDef link) onOpenFallback;

  @override
  Widget build(BuildContext context) {
    final bundle = view.bundle;
    final available = bundle.state == ReturnSupportState.available;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: available ? AppColors.info : AppColors.textSecondary,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WelcomeHomeStrings.t(bundle.authorityNameKey, locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.info),
          ),
          if (view.regionId == 'kerala') ...[
            const SizedBox(height: 4),
            Text(
              WelcomeHomeStrings.t('wh_kl_authority', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            WelcomeHomeStrings.tf(
              'wh_last_verified',
              locale,
              {'date': bundle.lastVerifiedIso},
            ),
            style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!available) ...[
            Text(
              WelcomeHomeStrings.t('wh_unavailable_title', locale),
              style: AppTypography.subtitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              WelcomeHomeStrings.t('wh_unavailable_body', locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ] else ...[
            if (bundle.preReturnPortalNoteKey != null) ...[
              Text(
                WelcomeHomeStrings.t(bundle.preReturnPortalNoteKey!, locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            ...bundle.programs.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WelcomeHomeStrings.t(p.nameKey, locale),
                      style: AppTypography.subtitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      WelcomeHomeStrings.t(p.summaryKey, locale),
                      style: AppTypography.bodySmall.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onOpenUrl(p.officialUrl, p.id),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(
                          '${WelcomeHomeStrings.t('wh_open_official_site', locale)} · ${WelcomeHomeStrings.t('wh_needs_internet', locale)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Text(
            WelcomeHomeStrings.t(bundle.requirementsNoteKey, locale),
            style: AppTypography.caption.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            WelcomeHomeStrings.t(bundle.recheckNoteKey, locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (bundle.hotlines.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...bundle.hotlines.map(
              (h) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined, size: 20),
                title: Text(WelcomeHomeStrings.t(h.labelKey, locale)),
                subtitle: Text(h.number),
                onTap: h.dialUri != null
                    ? () => onOpenUrl(h.dialUri!, h.labelKey)
                    : null,
              ),
            ),
          ],
          if (view.fallbackLinks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              WelcomeHomeStrings.t('wh_consular_resources_heading', locale),
              style: AppTypography.subtitle.copyWith(fontSize: 14),
            ),
            ...view.fallbackLinks.map(
              (link) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  link.titleKey.startsWith('eosb_')
                      ? EosbStrings.t(link.titleKey, locale)
                      : WelcomeHomeStrings.t(link.titleKey, locale),
                ),
                subtitle: Text(
                  WelcomeHomeStrings.t(link.descriptionKey, locale),
                ),
                trailing: link.url != null
                    ? IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => onOpenFallback(link),
                      )
                    : link.phone != null
                        ? IconButton(
                            icon: const Icon(Icons.phone),
                            onPressed: () => onOpenUrl('tel:${link.phone}', link.id),
                          )
                        : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChecklistActions extends StatelessWidget {
  const _ChecklistActions({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        TextButton(
          onPressed: () => context.push('/document-vault'),
          child: Text(WelcomeHomeStrings.t('wh_check_vault', locale)),
        ),
        TextButton(
          onPressed: () => context.push('/eosb/result'),
          child: Text(WelcomeHomeStrings.t('wh_check_eosb', locale)),
        ),
        TextButton(
          onPressed: () => context.push('/leaving-qatar'),
          child: Text(WelcomeHomeStrings.t('wh_check_health', locale)),
        ),
      ],
    );
  }
}
