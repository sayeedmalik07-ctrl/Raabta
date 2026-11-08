import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_offer_strings.dart';
import 'package:raabta/features/marketplace/providers/marketplace_offer_providers.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/providers/visa_providers.dart';

class MarketplaceMakeOfferScreen extends ConsumerStatefulWidget {
  const MarketplaceMakeOfferScreen({
    super.key,
    required this.listingId,
    required this.sellerId,
    required this.listingTitle,
    this.listedPriceHint,
  });

  final String listingId;
  final String sellerId;
  final String listingTitle;
  final double? listedPriceHint;

  @override
  ConsumerState<MarketplaceMakeOfferScreen> createState() =>
      _MarketplaceMakeOfferScreenState();
}

class _MarketplaceMakeOfferScreenState
    extends ConsumerState<MarketplaceMakeOfferScreen> {
  final _amountController = TextEditingController();
  String? _errorKey;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.listedPriceHint != null && widget.listedPriceHint! > 0) {
      _amountController.text = widget.listedPriceHint!.round().toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit(String locale) async {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorKey = 'mp_offer_invalid_amount');
      return;
    }

    setState(() {
      _busy = true;
      _errorKey = null;
    });

    final offer = await ref.read(marketplaceOfferRepositoryProvider).createOffer(
          listingId: widget.listingId,
          sellerId: widget.sellerId,
          offeredPrice: amount,
          listingTitle: widget.listingTitle,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    if (offer == null) {
      setState(() => _errorKey = 'mp_offer_invalid_amount');
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: MarketplaceOfferStrings.t('mp_make_offer_title', locale),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              MarketplaceOfferStrings.t('mp_make_offer_subtitle', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              MarketplaceOfferStrings.t('mp_offer_amount_label', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: InputDecoration(
                hintText: '0',
                filled: true,
                fillColor: AppColors.surface.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_errorKey != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                MarketplaceOfferStrings.t(_errorKey!, locale),
                style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              MarketplaceOfferStrings.t('mp_offer_expires_note', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            ForewarningSlot(
              momentId: ForewarningMomentId.marketplacePay,
              locale: locale,
            ),
            GlassPrimaryButton(
              label: MarketplaceOfferStrings.t('mp_offer_submit', locale),
              onPressed: _busy ? null : () => _submit(locale),
            ),
          ],
        ),
      ),
    );
  }
}
