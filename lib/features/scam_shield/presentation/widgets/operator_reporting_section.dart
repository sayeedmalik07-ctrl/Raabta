import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/check_number/operator_reporting_catalog.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_spam_report_hint.dart';
import 'package:url_launcher/url_launcher.dart';

final operatorReportingVerifiedProvider =
    FutureProvider((ref) => OperatorReportingCatalog.loadVerified());

/// Verified operator/regulator reporting entries (Phase 25 / Phase 21 picker source).
class OperatorReportingSection extends ConsumerWidget {
  const OperatorReportingSection({
    super.key,
    required this.locale,
    this.headingKey = 'ss_cn_report_heading',
  });

  final String locale;
  final String headingKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operators = ref.watch(operatorReportingVerifiedProvider);
    return operators.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ScamShieldStrings.t(headingKey, locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamSpamReportHint(locale: locale),
            for (final op in entries) ...[
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScamShieldStrings.t(op.nameKey, locale),
                      style: AppTypography.subtitle,
                    ),
                    Text(
                      ScamShieldStrings.t(op.bodyKey, locale),
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      op.sourceLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (op.dialNumber != null)
                      OutlinedButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse('tel:${op.dialNumber}'),
                        ),
                        icon: const Icon(Icons.phone_outlined),
                        label: Text(
                          ScamShieldStrings.t('ss_cn_report_dial', locale),
                        ),
                      ),
                    TextButton(
                      onPressed: () => launchUrl(
                        Uri.parse(op.verifyUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        ScamShieldStrings.t('ss_cn_report_verify', locale),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
