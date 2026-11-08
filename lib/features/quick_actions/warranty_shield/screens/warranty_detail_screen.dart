import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/qatar_warranty_retailers.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/features/quick_actions/warranty_shield/widgets/retailer_contact_card.dart';
import 'package:raabta/providers/visa_providers.dart';

class WarrantyDetailScreen extends ConsumerWidget {
  const WarrantyDetailScreen({super.key, required this.item});

  final WarrantyItem item;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _openClaimAssistant(BuildContext context, String locale) async {
    if (item.isExpired) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text(WarrantyStrings.t('warr_claim_expired_title', locale)),
          content: Text(
            WarrantyStrings.t('warr_claim_expired_body', locale),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(WarrantyStrings.t('warr_claim_expired_cancel', locale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                WarrantyStrings.t('warr_claim_expired_proceed', locale),
              ),
            ),
          ],
        ),
      );
      if (proceed != true || !context.mounted) return;
      await context.push(
        '/warranty-shield/claim',
        extra: {'item': item, 'expiredAcknowledged': true},
      );
      return;
    }

    await context.push(
      '/warranty-shield/claim',
      extra: {'item': item, 'expiredAcknowledged': false},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final statusColor = item.isExpired
        ? AppColors.errorBright
        : item.expiringsSoon
            ? AppColors.accentGold
            : AppColors.successBright;
    final matchedRetailer = QatarWarrantyRetailerCatalog.matchForItem(item);

    return GlassScreenScaffold(
      title: WarrantyStrings.displayProductName(item.productName, locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: statusColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(
                  WarrantyStrings.t('warr_hint_brand', locale),
                  WarrantyStrings.displayBrand(item.brand, locale),
                ),
                if (item.retailer.isNotEmpty)
                  _row(
                    WarrantyStrings.t('warr_field_retailer', locale),
                    item.retailer,
                  ),
                _row(
                  WarrantyStrings.t('warr_field_category', locale),
                  WarrantyStrings.categoryLabel(item.category, locale),
                ),
                _row(
                  WarrantyStrings.t('warr_label_purchase_date', locale),
                  _fmt(item.purchaseDate),
                ),
                _row(
                  WarrantyStrings.t('warr_label_expiry', locale),
                  _fmt(item.expiryDate),
                ),
                _row(
                  WarrantyStrings.t('warr_hint_price', locale),
                  '${item.purchasePriceQar.toStringAsFixed(0)} ${item.currency}',
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.isExpired
                      ? WarrantyStrings.t('warr_card_expired', locale)
                      : WarrantyStrings.format(
                          'warr_card_days_remaining',
                          locale,
                          params: {'days': item.daysLeft.toString()},
                        ),
                  style: AppTypography.title.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
          if (matchedRetailer != null) ...[
            const SizedBox(height: AppSpacing.lg),
            RetailerContactCard(
              retailer: matchedRetailer,
              item: item,
              locale: locale,
              onFileClaim: () => _openClaimAssistant(context, locale),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: item.isExpired
                ? WarrantyStrings.t('warr_claim_file_expired', locale)
                : WarrantyStrings.t('warr_claim_file', locale),
            icon: Icons.support_agent_outlined,
            expand: true,
            accentColor: item.isExpired
                ? AppColors.accentGold
                : AppColors.successBright,
            onPressed: () => _openClaimAssistant(context, locale),
          ),
          if (item.isExpired) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              WarrantyStrings.t('warr_claim_expired_hint', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: AppTypography.body),
          ),
        ],
      ),
    );
  }
}
