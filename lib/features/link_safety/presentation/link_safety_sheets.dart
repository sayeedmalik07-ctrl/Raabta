import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/link_safety/l10n/link_safety_strings.dart';
import 'package:raabta/features/link_safety/link_safety_friction_session.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_share_payload.dart';
import 'package:raabta/features/scam_shield/platform/scam_external_link_launcher.dart';

abstract final class LinkSafetySheets {
  static Future<void> showWhy({
    required BuildContext context,
    required String locale,
    required LinkSafetyUrlLabel label,
    VoidCallback? onReportPost,
  }) {
    final org = label.officialOrganisationName ?? '';
    final bodyKey = switch (label.type) {
      LinkSafetyLabelType.lookalikeOfficial => 'ls_why_body_lookalike',
      LinkSafetyLabelType.shortenedLink => 'ls_why_body_shortener',
      LinkSafetyLabelType.apkLink => 'ls_why_body_apk',
      LinkSafetyLabelType.paymentLinkInChat => 'ls_why_body_payment',
    };
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LinkSafetyStrings.t('ls_why_title', locale),
                style: AppTypography.headline2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                LinkSafetyStrings.format(bodyKey, locale, params: {'org': org}),
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/scam-shield/scam-types');
                },
                child: Text(LinkSafetyStrings.t('ls_why_learn', locale)),
              ),
              if (onReportPost != null)
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onReportPost();
                  },
                  child: Text(LinkSafetyStrings.t('ls_report_post', locale)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool> confirmOpenConcernLink({
    required BuildContext context,
    required String locale,
    required LinkSafetyUrlLabel label,
  }) async {
    if (!label.isConcern) return true;
    if (!LinkSafetyFrictionSession.shouldShowFriction(label.url)) {
      return true;
    }

    final title = switch (label.type) {
      LinkSafetyLabelType.lookalikeOfficial => LinkSafetyStrings.format(
          'ls_friction_title',
          locale,
          params: {'org': label.officialOrganisationName ?? '—'},
        ),
      LinkSafetyLabelType.apkLink =>
        LinkSafetyStrings.t('ls_friction_title_apk', locale),
      LinkSafetyLabelType.paymentLinkInChat =>
        LinkSafetyStrings.t('ls_friction_title_payment', locale),
      LinkSafetyLabelType.shortenedLink =>
        LinkSafetyStrings.t('ls_label_shortener', locale),
    };
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: AppTypography.headline2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                LinkSafetyStrings.t('ls_friction_body', locale),
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(LinkSafetyStrings.t('ls_friction_primary', locale)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(LinkSafetyStrings.t('ls_friction_open', locale)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openCheckLink(ctx, label.url);
                },
                child: Text(LinkSafetyStrings.t('ls_check_link', locale)),
              ),
            ],
          ),
        ),
      ),
    );

    LinkSafetyFrictionSession.markFrictionShown(label.url);
    return result == true;
  }

  static void _openCheckLink(BuildContext context, String url) {
    ScamShieldSharePayloadStore.set(
      ScamShieldSharePayload(sharedText: url),
    );
    context.push('/scam-shield/share-review');
  }

  static Future<void> openUrlWithSafety({
    required BuildContext context,
    required String locale,
    required String url,
    LinkSafetyUrlLabel? label,
  }) async {
    if (label != null && label.isConcern) {
      final ok = await confirmOpenConcernLink(
        context: context,
        locale: locale,
        label: label,
      );
      if (!ok) return;
    }
    final withScheme = url.startsWith('http') ? url : 'https://$url';
    await ScamExternalLinkLauncher.openUrl(withScheme);
  }

  static void openCheckLink(BuildContext context, String url) {
    _openCheckLink(context, url);
  }
}
