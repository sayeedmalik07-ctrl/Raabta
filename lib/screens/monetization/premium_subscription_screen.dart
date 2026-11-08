import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/config/monetization_config.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/intelligence/sensitive_action_confirm.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/monetization/l10n/monetization_strings.dart';
import 'package:raabta/core/widgets/monetization_coming_soon_panel.dart';
import 'package:raabta/models/intelligence/permission_level.dart';
import 'package:raabta/services/intelligence/sensitive_action_audit_service.dart';

class PremiumSubscriptionScreen extends ConsumerStatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  ConsumerState<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState
    extends ConsumerState<PremiumSubscriptionScreen> {
  bool _isYearly = false;

  bool get _hold => MonetizationState.isHold;

  List<Map<String, dynamic>> _featuresFor(String locale) {
    final unlimited = MonetizationStrings.t('val_unlimited', locale);
    final basic = MonetizationStrings.t('val_basic', locale);
    final full = MonetizationStrings.t('val_full', locale);
    return [
      {
        'feature': MonetizationStrings.t('feat_price', locale),
        'free': MonetizationConfig.formatQr(0),
        'premium': MonetizationConfig.formatQrPerMonth(
          MonetizationConfig.premiumMonthlyQr,
        ),
        'pro': MonetizationConfig.formatQrPerMonth(
          MonetizationConfig.proMonthlyQr,
        ),
      },
      {
        'feature': MonetizationStrings.t('feat_ai_questions', locale),
        'free': '10',
        'premium': unlimited,
        'pro': unlimited,
      },
      {
        'feature': MonetizationStrings.t('feat_document_scans', locale),
        'free': '5/month',
        'premium': unlimited,
        'pro': unlimited,
      },
      {
        'feature': MonetizationStrings.t('feat_job_applications', locale),
        'free': '3/day',
        'premium': unlimited,
        'pro': unlimited,
      },
      {
        'feature': MonetizationStrings.t('feat_ad_free', locale),
        'free': false,
        'premium': true,
        'pro': true,
      },
      {
        'feature': MonetizationStrings.t('feat_priority_listings', locale),
        'free': false,
        'premium': true,
        'pro': true,
      },
      {
        'feature': MonetizationStrings.t('feat_advanced_filters', locale),
        'free': false,
        'premium': true,
        'pro': true,
      },
      {
        'feature': MonetizationStrings.t('feat_direct_employer', locale),
        'free': false,
        'premium': true,
        'pro': true,
      },
      {
        'feature': MonetizationStrings.t('feat_labour_law_ai', locale),
        'free': basic,
        'premium': full,
        'pro': full,
      },
      {
        'feature': MonetizationStrings.t('feat_monthly_consultation', locale),
        'free': false,
        'premium': false,
        'pro': MonetizationStrings.t('val_30_min', locale),
      },
      {
        'feature': MonetizationStrings.t('feat_featured_listing', locale),
        'free': false,
        'premium': false,
        'pro': true,
      },
      {
        'feature': MonetizationStrings.t('feat_business_listing', locale),
        'free': false,
        'premium': false,
        'pro': MonetizationStrings.t('val_1_free', locale),
      },
      {
        'feature': MonetizationStrings.t('feat_priority_support', locale),
        'free': false,
        'premium': false,
        'pro': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    return GlassScreenScaffold(
      leading: GlassIconButton(
        icon: Icons.close_rounded,
        tooltip: CommonActionStrings.t('action_cancel', locale),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(locale),
            if (_hold) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: MonetizationHoldBanner(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (!_hold) _buildBillingToggle(locale),
            if (_hold)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  MonetizationStrings.t('planned_pricing_preview', locale),
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  _buildFreeCard(locale),
                  const SizedBox(height: AppSpacing.md),
                  _buildPremiumCard(locale),
                  const SizedBox(height: AppSpacing.md),
                  _buildProCard(locale),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildComparisonTable(locale),
            const SizedBox(height: AppSpacing.lg),
            _buildTrustSection(locale),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(String locale) {
    return GlassContainer(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.12,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.amberGlow, AppColors.purpleGlow],
            ).createShader(bounds),
            child: Text(
              MonetizationStrings.t('premium_hero_title', locale),
              style: AppTypography.headline2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            MonetizationStrings.t('premium_hero_subtitle', locale),
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _proofChip('👥', MonetizationStrings.t('proof_expats', locale)),
              const SizedBox(width: AppSpacing.md),
              _proofChip('⭐', MonetizationStrings.t('proof_rated', locale)),
              if (!_hold) ...[
                const SizedBox(width: AppSpacing.md),
                _proofChip(
                  '🔒',
                  MonetizationStrings.t('proof_cancel_anytime', locale),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _proofChip(String icon, String label) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppSpacing.radiusFull,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildBillingToggle(String locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            MonetizationStrings.t('billing_monthly', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () => setState(() => _isYearly = !_isYearly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _isYearly
                    ? AppColors.amberGlow
                    : AppColors.surfaceElevated,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: _isYearly
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Row(
            children: [
              Text(
                MonetizationStrings.t('billing_yearly', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(width: AppSpacing.xs),
              GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                borderRadius: AppSpacing.radiusXs,
                glowColor: AppColors.success,
                glowIntensity: 0.15,
                child: Text(
                  MonetizationStrings.format(
                    'billing_save_percent',
                    locale,
                    params: {
                      'percent':
                          '${(MonetizationConfig.yearlyDiscountFraction * 100).round()}',
                    },
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreeCard(String locale) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                MonetizationStrings.t('plan_free', locale),
                style: AppTypography.title,
              ),
              const Spacer(),
              Text(
                MonetizationConfig.formatQr(0),
                style: AppTypography.headline2.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          Text(
            MonetizationStrings.t('plan_forever_free', locale),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          ...[
            MonetizationStrings.t('free_feat_ai', locale),
            MonetizationStrings.t('free_feat_scans', locale),
            MonetizationStrings.t('free_feat_jobs', locale),
            MonetizationStrings.t('free_feat_listings', locale),
            MonetizationStrings.t('free_feat_community', locale),
          ].map((f) => _featureRow(f, true, AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            onTap: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            borderRadius: AppSpacing.radiusSm,
            child: Text(
              MonetizationStrings.t('plan_current', locale),
              style: AppTypography.button.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(String locale) {
    if (_hold) {
      return MonetizationComingSoonPanel(
        productName: MonetizationStrings.t('table_premium', locale),
        plannedPriceLabel:
            'Planned price: ${MonetizationConfig.premiumMonthlyQr} QR/month',
        subtitle: MonetizationStrings.t('premium_coming_soon_subtitle', locale),
        accentColor: AppColors.amberGlow,
      );
    }

    final price = MonetizationConfig.premiumPrice(yearly: _isYearly);
    final period = _isYearly
        ? MonetizationStrings.t('period_per_year', locale)
        : MonetizationStrings.t('period_per_month', locale);

    return GlassCard(
      glowColor: AppColors.amberGlow,
      glowIntensity: 0.2,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    MonetizationStrings.t('plan_premium', locale),
                    style: AppTypography.title,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$price',
                            style: AppTypography.headline1.copyWith(
                              color: AppColors.amberGlow,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            ' ${MonetizationConfig.currencyLabel}$period',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      if (_isYearly)
                        Text(
                          '= ${MonetizationConfig.formatQrPerMonth((price / 12).round())}',
                          style: AppTypography.caption,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...[
                MonetizationStrings.t('premium_feat_ai', locale),
                MonetizationStrings.t('premium_feat_scans', locale),
                MonetizationStrings.t('premium_feat_jobs', locale),
                MonetizationStrings.t('premium_feat_ad_free', locale),
                MonetizationStrings.t('premium_feat_priority', locale),
                MonetizationStrings.t('premium_feat_filters', locale),
                MonetizationStrings.t('premium_feat_employer', locale),
                MonetizationStrings.t('premium_feat_labour', locale),
              ].map(
                (f) => _featureRow(f, true, AppColors.amberGlow),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                onTap: () => _handleSubscribe(
                  MonetizationStrings.t('table_premium', locale),
                  price,
                  locale,
                ),
                glowColor: AppColors.amberGlow,
                glowIntensity: 0.3,
                backgroundColor: AppColors.amberGlow,
                borderRadius: AppSpacing.radiusSm,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  MonetizationStrings.t('plan_subscribe_now', locale),
                  style: AppTypography.button.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              borderRadius: AppSpacing.radiusXs,
              backgroundColor: AppColors.amberGlow,
              child: Text(
                MonetizationStrings.t('badge_most_popular', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProCard(String locale) {
    if (_hold) {
      return MonetizationComingSoonPanel(
        productName: MonetizationStrings.t('table_pro', locale),
        plannedPriceLabel:
            'Planned price: ${MonetizationConfig.proMonthlyQr} QR/month',
        subtitle: MonetizationStrings.t('pro_coming_soon_subtitle', locale),
        accentColor: AppColors.purpleGlow,
      );
    }

    final price = MonetizationConfig.proPrice(yearly: _isYearly);
    final period = _isYearly
        ? MonetizationStrings.t('period_per_year', locale)
        : MonetizationStrings.t('period_per_month', locale);

    return GlassCard(
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.2,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                MonetizationStrings.t('plan_pro', locale),
                style: AppTypography.title,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$price',
                        style: AppTypography.headline1.copyWith(
                          color: AppColors.purpleGlow,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        ' ${MonetizationConfig.currencyLabel}$period',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  if (_isYearly)
                    Text(
                      '= ${MonetizationConfig.formatQrPerMonth((price / 12).round())}',
                      style: AppTypography.caption,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MonetizationStrings.t('pro_includes_premium', locale),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          ...[
            MonetizationStrings.t('pro_feat_consultation', locale),
            MonetizationStrings.t('pro_feat_featured', locale),
            MonetizationStrings.t('pro_feat_business', locale),
            MonetizationStrings.t('pro_feat_support', locale),
            MonetizationStrings.t('pro_feat_badge', locale),
          ].map((f) => _featureRow(f, true, AppColors.purpleGlow)),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            onTap: () => _handleSubscribe(
              MonetizationStrings.t('table_pro', locale),
              price,
              locale,
            ),
            glowColor: AppColors.purpleGlow,
            glowIntensity: 0.3,
            backgroundColor: AppColors.purpleGlow,
            borderRadius: AppSpacing.radiusSm,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              MonetizationStrings.t('plan_get_pro', locale),
              style: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(String text, bool included, Color checkColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.remove_circle,
            color: included ? checkColor : AppColors.textTertiary,
            size: AppSpacing.iconSm,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: included
                    ? AppColors.textSecondary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(String locale) {
    final features = _featuresFor(locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MonetizationStrings.t('compare_features', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tableHeader(locale),
                Divider(color: AppColors.glassBorder, height: 1),
                ...features.asMap().entries.map((entry) {
                  final isLast = entry.key == features.length - 1;
                  return Column(
                    children: [
                      _tableRow(entry.value),
                      if (!isLast)
                        Divider(
                          color: AppColors.glassBorder,
                          height: 1,
                          indent: AppSpacing.md,
                          endIndent: AppSpacing.md,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              MonetizationStrings.t('table_feature', locale),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _headerCell(MonetizationStrings.t('table_free', locale)),
          _headerCell(
            MonetizationStrings.t('table_premium', locale),
            color: AppColors.amberGlow,
          ),
          _headerCell(
            MonetizationStrings.t('table_pro', locale),
            color: AppColors.purpleGlow,
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {Color? color}) {
    return Expanded(
      flex: 2,
      child: Center(
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: color ?? AppColors.textTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(row['feature'], style: AppTypography.bodySmall),
          ),
          _tableCell(row['free']),
          _tableCell(row['premium'], color: AppColors.amberGlow),
          _tableCell(row['pro'], color: AppColors.purpleGlow),
        ],
      ),
    );
  }

  Widget _tableCell(dynamic value, {Color? color}) {
    Widget child;
    if (value is bool) {
      child = Icon(
        value ? Icons.check : Icons.close,
        size: AppSpacing.iconSm,
        color: value ? (color ?? AppColors.textSecondary) : AppColors.textTertiary,
      );
    } else {
      child = Text(
        value.toString(),
        textAlign: TextAlign.center,
        style: AppTypography.caption.copyWith(
          color: color ?? AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Expanded(flex: 2, child: Center(child: child));
  }

  Widget _buildTrustSection(String locale) {
    if (_hold) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _trustItem(
              '🆓',
              MonetizationStrings.t('trust_currently_free', locale),
            ),
            _trustItem(
              '🔒',
              MonetizationStrings.t('trust_privacy_first', locale),
            ),
            _trustItem(
              '📞',
              MonetizationStrings.t('trust_support_247', locale),
            ),
            _trustItem(
              '🌍',
              MonetizationStrings.t('trust_qatar_based', locale),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _trustItem(
            '🔒',
            MonetizationStrings.t('trust_secure_payment', locale),
          ),
          _trustItem(
            '↩️',
            MonetizationStrings.t('trust_cancel_anytime', locale),
          ),
          _trustItem(
            '📞',
            MonetizationStrings.t('trust_support_247', locale),
          ),
          _trustItem(
            '🌍',
            MonetizationStrings.t('trust_qatar_based', locale),
          ),
        ],
      ),
    );
  }

  Widget _trustItem(String icon, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Future<void> _handleSubscribe(
    String plan,
    int price,
    String locale,
  ) async {
    if (!MonetizationState.canInitiatePayment) return;
    final priceLabel = MonetizationConfig.formatQr(price);
    final confirmed = await showSensitiveActionConfirmDialog(
      context,
      title: MonetizationStrings.t('confirm_subscription_title', locale),
      message: MonetizationStrings.format(
        'confirm_subscription_message',
        locale,
        params: {'plan': plan, 'price': priceLabel},
      ),
      confirmLabel: MonetizationStrings.t('confirm_payment_continue', locale),
    );
    if (!confirmed || !mounted) return;

    await SensitiveActionAuditService.log(
      actionId: SensitiveActionIds.premiumSubscriptionPayment,
      level: PermissionLevel.execute,
      metadata: {'plan': plan, 'priceQr': price},
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          MonetizationStrings.format(
            'subscription_selected_snackbar',
            locale,
            params: {'plan': plan, 'price': priceLabel},
          ),
        ),
        backgroundColor: AppColors.purpleGlow,
      ),
    );
  }
}
