import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/investment_check/investment_red_flag_tally.dart';
import 'package:raabta/features/scam_shield/investment_check/regulator_register_catalog.dart';
import 'package:raabta/features/scam_shield/platform/scam_external_link_launcher.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldInvestmentCheckScreen extends ConsumerStatefulWidget {
  const ScamShieldInvestmentCheckScreen({super.key});

  @override
  ConsumerState<ScamShieldInvestmentCheckScreen> createState() =>
      _ScamShieldInvestmentCheckScreenState();
}

class _ScamShieldInvestmentCheckScreenState
    extends ConsumerState<ScamShieldInvestmentCheckScreen> {
  final _tally = <String>{};
  RegulatorRegisterCatalog? _catalog;

  @override
  void initState() {
    super.initState();
    RegulatorRegisterCatalog.load().then((c) {
      if (mounted) setState(() => _catalog = c);
    });
  }

  Future<void> _openExternal(BuildContext context, String url) async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ScamShieldStrings.t('ss_inv_leave_app_title', locale)),
        content: Text(ScamShieldStrings.t('ss_inv_leave_app_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ScamShieldStrings.t('ss_inv_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ScamShieldStrings.t('ss_inv_continue', locale)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ScamExternalLinkLauncher.openUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final catalog = _catalog;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_inv_check_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_inv_check_subtitle', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            _tallySection(locale),
            if (InvestmentRedFlagTally.showSummary(_tally)) ...[
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  ScamShieldStrings.t('ss_inv_tally_summary', locale),
                  style: AppTypography.body,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _step(
              locale,
              'ss_inv_step1_title',
              'ss_inv_step1_body',
            ),
            _step(
              locale,
              'ss_inv_step2_title',
              'ss_inv_step2_body',
            ),
            if (catalog != null) ...[
              for (final reg in catalog.regulators) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ScamShieldStrings.t(reg.nameKey, locale),
                  style: AppTypography.subtitle,
                ),
                Text(
                  ScamShieldStrings.t(reg.scopeKey, locale),
                  style: AppTypography.bodySmall,
                ),
                for (final link in reg.visibleLinks)
                  TextButton(
                    onPressed: () => _openExternal(context, link.url),
                    child: Text(ScamShieldStrings.t(link.labelKey, locale)),
                  ),
                if (reg.visibleLinks.isEmpty)
                  Text(
                    ScamShieldStrings.t('ss_inv_links_pending', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
              Text(
                ScamShieldStrings.t('ss_inv_foreign_licence', locale),
                style: AppTypography.bodySmall,
              ),
            ],
            _step(
              locale,
              'ss_inv_step3_title',
              'ss_inv_step3_body',
            ),
            _step(
              locale,
              'ss_inv_step4_title',
              'ss_inv_step4_body',
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                ScamShieldStrings.t('ss_inv_result_disclaimer', locale),
                style: AppTypography.body,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: ScamShieldStrings.t('ss_inv_directory_cta', locale),
              expand: true,
              onPressed: () => context.push('/scam-shield/directory'),
            ),
            if (catalog != null)
              for (final link in catalog.visibleReportLinks)
                TextButton(
                  onPressed: () => _openExternal(context, link.url),
                  child: Text(ScamShieldStrings.t(link.labelKey, locale)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _step(String locale, String titleKey, String bodyKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScamShieldStrings.t(titleKey, locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ScamShieldStrings.t(bodyKey, locale),
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _tallySection(String locale) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ScamShieldStrings.t('ss_inv_tally_title', locale),
              style: AppTypography.subtitle,
            ),
            CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ScamShieldStrings.t('ss_inv_tally_guaranteed', locale),
              style: AppTypography.bodySmall,
            ),
            value: _tally.contains('guaranteed'),
            onChanged: (v) => setState(() {
              v == true ? _tally.add('guaranteed') : _tally.remove('guaranteed');
            }),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ScamShieldStrings.t('ss_pay_prompt_invest_2', locale),
              style: AppTypography.bodySmall,
            ),
            value: _tally.contains('withdraw_fee'),
            onChanged: (v) => setState(() {
              v == true
                  ? _tally.add('withdraw_fee')
                  : _tally.remove('withdraw_fee');
            }),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ScamShieldStrings.t('ss_inv_tally_pressure', locale),
              style: AppTypography.bodySmall,
            ),
            value: _tally.contains('pressure'),
            onChanged: (v) => setState(() {
              v == true ? _tally.add('pressure') : _tally.remove('pressure');
            }),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ScamShieldStrings.t('ss_inv_tally_personal_crypto', locale),
              style: AppTypography.bodySmall,
            ),
            value: _tally.contains('personal_crypto'),
            onChanged: (v) => setState(() {
              v == true
                  ? _tally.add('personal_crypto')
                  : _tally.remove('personal_crypto');
            }),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ScamShieldStrings.t('ss_inv_tally_whatsapp', locale),
              style: AppTypography.bodySmall,
            ),
            value: _tally.contains('whatsapp_telegram'),
            onChanged: (v) => setState(() {
              v == true
                  ? _tally.add('whatsapp_telegram')
                  : _tally.remove('whatsapp_telegram');
            }),
          ),
          ],
        ),
      ),
    );
  }
}
