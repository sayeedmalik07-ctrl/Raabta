import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_moment_models.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:url_launcher/url_launcher.dart';

class KnowQatarMomentItemTile extends StatelessWidget {
  const KnowQatarMomentItemTile({
    super.key,
    required this.item,
    required this.locale,
    required this.onOpened,
  });

  final KnowQatarMomentResolvedItem item;
  final String locale;
  final VoidCallback onOpened;

  Future<void> _openExternal() async {
    final url = item.externalUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = item.isExternal
        ? KnowQatarStrings.t('kq_moment_label_official', locale)
        : item.isSection
            ? KnowQatarStrings.t('kq_moment_label_read', locale)
            : KnowQatarStrings.t('kq_moment_label_tool', locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () {
            onOpened();
            if (item.isExternal) {
              _openExternal();
            } else if (item.isSection) {
              context.push(item.route);
            } else {
              QuickActionsHub.navigateTo(context, item.route);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      KnowQatarStrings.t(item.titleKey, locale),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      KnowQatarStrings.t(item.summaryKey, locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (item.isExternal &&
                        item.trustSourceNameKey != null &&
                        item.externalUrl != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TrustLabel(
                        type: TrustLabelType.official,
                        locale: locale,
                        sourceName: KnowQatarStrings.t(
                          item.trustSourceNameKey!,
                          locale,
                        ),
                        verifiedDateIso: item.urlVerifiedIso,
                        sourceUrl: item.externalUrl,
                        showDetail: true,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                item.isSection
                    ? Icons.menu_book_outlined
                    : Icons.open_in_new,
                color: AppColors.cyanGlow,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
