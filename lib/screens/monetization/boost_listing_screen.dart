import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/config/monetization_config.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/intelligence/sensitive_action_confirm.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/monetization_coming_soon_panel.dart';
import 'package:raabta/models/intelligence/permission_level.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/monetization/l10n/monetization_strings.dart';
import 'package:raabta/services/intelligence/sensitive_action_audit_service.dart';

class BoostListingScreen extends ConsumerStatefulWidget {
  const BoostListingScreen({
    super.key,
    required this.listingTitle,
    required this.currentViews,
    required this.currentContacts,
    required this.listingId,
  });

  final String listingTitle;
  final int currentViews;
  final int currentContacts;
  final String listingId;

  @override
  ConsumerState<BoostListingScreen> createState() =>
      _BoostListingScreenState();
}

class _BoostListingScreenState extends ConsumerState<BoostListingScreen> {
  int? _selectedPackage;
  bool _showPayment = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'index': 0,
      'labelKey': 'boost_package_starter',
      'days': MonetizationConfig.boostStarterDays,
      'price': MonetizationConfig.boostStarterQr,
      'oldPrice': null,
      'popular': false,
      'borderColor': AppColors.cyanGlow,
      'borderWidth': 1.0,
      'gradientColors': null,
      'priceColor': AppColors.cyanGlow,
      'buttonStyle': 'outline',
      'buttonColor': AppColors.cyanGlow,
      'badgeKey': null,
      'benefitKeys': [
        'boost_benefit_3x',
        'boost_benefit_highlighted',
        'boost_benefit_priority_3d',
      ],
    },
    {
      'index': 1,
      'labelKey': 'boost_package_popular',
      'days': MonetizationConfig.boostPopularDays,
      'price': MonetizationConfig.boostPopularQr,
      'oldPrice': MonetizationConfig.boostPopularCompareAtQr,
      'popular': true,
      'borderColor': AppColors.cyanGlow,
      'borderWidth': 2.0,
      'gradientColors': [AppColors.cyanGlow, AppColors.purpleGlow],
      'priceColor': AppColors.cyanGlow,
      'buttonStyle': 'filled',
      'buttonColor': AppColors.cyanGlow,
      'badgeKey': 'badge_most_popular',
      'benefitKeys': [
        'boost_benefit_7x',
        'boost_benefit_featured_badge',
        'boost_benefit_top_7d',
        'boost_benefit_push_500',
      ],
    },
    {
      'index': 2,
      'labelKey': 'boost_package_premium',
      'days': MonetizationConfig.boostPremiumDays,
      'price': MonetizationConfig.boostPremiumQr,
      'oldPrice': null,
      'popular': false,
      'borderColor': AppColors.amberGlow,
      'borderWidth': 2.0,
      'gradientColors': [AppColors.amberGlow, AppColors.warning],
      'priceColor': AppColors.amberGlow,
      'buttonStyle': 'gold',
      'buttonColor': AppColors.amberGlow,
      'badgeKey': null,
      'benefitKeys': [
        'boost_benefit_15x',
        'boost_benefit_premium_badge',
        'boost_benefit_homepage',
        'boost_benefit_ai_recommended',
        'boost_benefit_analytics',
      ],
    },
  ];

  List<Map<String, dynamic>> _packagesFor(String locale) {
    return _packages.map((pkg) {
      return {
        ...pkg,
        'label': MonetizationStrings.t(pkg['labelKey'] as String, locale),
        'benefits': (pkg['benefitKeys'] as List<String>)
            .map((k) => MonetizationStrings.t(k, locale))
            .toList(),
        'badge': pkg['badgeKey'] != null
            ? MonetizationStrings.t(pkg['badgeKey'] as String, locale)
            : null,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final packages = _packagesFor(locale);

    if (MonetizationState.isHold) {
      final plannedPrices =
          '${MonetizationConfig.formatQr(MonetizationConfig.boostStarterQr)} / '
          '${MonetizationConfig.formatQr(MonetizationConfig.boostPopularQr)} / '
          '${MonetizationConfig.formatQr(MonetizationConfig.boostPremiumQr)}';
      return GlassScreenScaffold(
        title: MonetizationStrings.t('boost_screen_title', locale),
        leading: GlassIconButton(
          icon: Icons.close_rounded,
          tooltip: CommonActionStrings.t('action_cancel', locale),
          onPressed: () => Navigator.of(context).pop(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildListingPreview(locale),
              const SizedBox(height: AppSpacing.lg),
              const MonetizationHoldBanner(),
              const SizedBox(height: AppSpacing.md),
              MonetizationComingSoonPanel(
                productName:
                    MonetizationStrings.t('boost_product_name', locale),
                plannedPriceLabel: MonetizationStrings.format(
                  'ad_planned_price',
                  locale,
                  params: {'price': plannedPrices},
                ),
                subtitle: MonetizationStrings.t(
                  'boost_coming_soon_subtitle',
                  locale,
                ),
                accentColor: AppColors.cyanGlow,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                MonetizationStrings.t('boost_planned_benefits', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...packages.map(
                (pkg) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    MonetizationStrings.format(
                      'boost_planned_package_line',
                      locale,
                      params: {
                        'label': pkg['label'] as String,
                        'days': '${pkg['days']}',
                        'price': MonetizationConfig.formatQr(
                          pkg['price'] as int,
                        ),
                      },
                    ),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassScreenScaffold(
      title: MonetizationStrings.t('boost_screen_title', locale),
      leading: GlassIconButton(
        icon: Icons.close_rounded,
        tooltip: CommonActionStrings.t('action_cancel', locale),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showPayment
            ? _buildPaymentSection(locale, packages)
            : _buildPackagesSection(locale, packages),
      ),
    );
  }

  Widget _buildPackagesSection(
    String locale,
    List<Map<String, dynamic>> packages,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('packages'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListingPreview(locale),
          const SizedBox(height: AppSpacing.lg),
          Text(
            MonetizationStrings.t('boost_choose_package', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MonetizationStrings.t('boost_no_hidden_fees', locale),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          ...packages.map((pkg) => _buildPackageCard(locale, pkg)),
          const SizedBox(height: AppSpacing.md),
          if (_selectedPackage != null)
            GlassCard(
              onTap: () => setState(() => _showPayment = true),
              glowColor: AppColors.purpleGlow,
              glowIntensity: 0.25,
              backgroundColor: AppColors.purpleGlow,
              borderRadius: AppSpacing.radiusMd,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                MonetizationStrings.format(
                  'boost_continue_with',
                  locale,
                  params: {
                    'label': packages[_selectedPackage!]['label'] as String,
                    'price': MonetizationConfig.formatQr(
                      packages[_selectedPackage!]['price'] as int,
                    ),
                  },
                ),
                style: AppTypography.button.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildListingPreview(String locale) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GlassContainer(
            width: 48,
            height: 48,
            padding: EdgeInsets.zero,
            borderRadius: AppSpacing.radiusSm,
            glowColor: AppColors.purpleGlow,
            glowIntensity: 0.12,
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.purpleGlow,
              size: AppSpacing.iconLg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listingTitle,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _statChip(
                      Icons.visibility_outlined,
                      MonetizationStrings.format(
                        'boost_stat_views',
                        locale,
                        params: {'count': '${widget.currentViews}'},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _statChip(
                      Icons.phone_outlined,
                      MonetizationStrings.format(
                        'boost_stat_contacts',
                        locale,
                        params: {'count': '${widget.currentContacts}'},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            borderRadius: AppSpacing.radiusXs,
            glowColor: AppColors.warning,
            glowIntensity: 0.12,
            child: Text(
              MonetizationStrings.t('boost_status_active', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconXs, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildPackageCard(String locale, Map<String, dynamic> pkg) {
    final isSelected = _selectedPackage == pkg['index'];
    final borderColor = pkg['borderColor'] as Color;
    final priceColor = pkg['priceColor'] as Color;

    return GlassCard(
      onTap: () => setState(() => _selectedPackage = pkg['index']),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      glowColor: isSelected ? borderColor : null,
      glowIntensity: isSelected ? 0.2 : 0,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    MonetizationStrings.format(
                      'boost_days_label',
                      locale,
                      params: {'days': '${pkg['days']}'},
                    ),
                    style: AppTypography.title,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (pkg['oldPrice'] != null)
                        Text(
                          MonetizationConfig.formatQr(pkg['oldPrice'] as int),
                          style: AppTypography.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        MonetizationConfig.formatQr(pkg['price'] as int),
                        style: AppTypography.headline1.copyWith(
                          color: priceColor,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...(pkg['benefits'] as List<String>).map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: priceColor, size: AppSpacing.iconSm),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(b, style: AppTypography.bodySmall),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildPackageButton(locale, pkg, isSelected, priceColor),
            ],
          ),
          if (pkg['badge'] != null)
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
                  pkg['badge'] as String,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 0,
              left: 0,
              child: GlassContainer(
                width: 22,
                height: 22,
                padding: EdgeInsets.zero,
                borderRadius: AppSpacing.radiusFull,
                backgroundColor: borderColor,
                child: Icon(
                  Icons.check,
                  color: AppColors.textPrimary,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackageButton(
    String locale,
    Map<String, dynamic> pkg,
    bool isSelected,
    Color color,
  ) {
    final style = pkg['buttonStyle'] as String;
    final selectLabel = MonetizationStrings.t('boost_select', locale);
    final selectedLabel = MonetizationStrings.t('boost_selected', locale);
    if (style == 'outline') {
      return GlassCard(
        onTap: () => setState(() => _selectedPackage = pkg['index']),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        borderRadius: AppSpacing.radiusSm,
        glowColor: color,
        glowIntensity: 0.15,
        child: Text(
          selectLabel,
          style: AppTypography.button.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      );
    }
    return GlassCard(
      onTap: () => setState(() => _selectedPackage = pkg['index']),
      glowColor: color,
      glowIntensity: isSelected ? 0.25 : 0.15,
      backgroundColor: isSelected ? color : color.withValues(alpha: 0.8),
      borderRadius: AppSpacing.radiusSm,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        isSelected ? selectedLabel : selectLabel,
        style: AppTypography.button.copyWith(
          color: style == 'gold' ? AppColors.background : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaymentSection(
    String locale,
    List<Map<String, dynamic>> packages,
  ) {
    if (_selectedPackage == null) return const SizedBox();
    final pkg = packages[_selectedPackage!];
    final priceFormatted = MonetizationConfig.formatQr(pkg['price'] as int);
    final daysLabel = MonetizationStrings.format(
      'boost_days_label',
      locale,
      params: {'days': '${pkg['days']}'},
    );

    return SingleChildScrollView(
      key: const ValueKey('payment'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            onTap: () => setState(() => _showPayment = false),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            borderRadius: AppSpacing.radiusFull,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, color: AppColors.cyanGlow, size: AppSpacing.iconSm),
                Text(
                  MonetizationStrings.t('boost_change_package', locale),
                  style: AppTypography.link,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            MonetizationStrings.t('boost_complete_payment', locale),
            style: AppTypography.headline2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _summaryRow(
                  MonetizationStrings.t('boost_summary_package', locale),
                  '${pkg['label']} — $daysLabel',
                ),
                Divider(color: AppColors.glassBorder, height: AppSpacing.lg),
                _summaryRow(
                  MonetizationStrings.t('boost_summary_listing', locale),
                  widget.listingTitle,
                  valueMaxLines: 1,
                ),
                Divider(color: AppColors.glassBorder, height: AppSpacing.lg),
                _summaryRow(
                  MonetizationStrings.t('boost_summary_total', locale),
                  priceFormatted,
                  valueColor: AppColors.amberGlow,
                  valueBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            MonetizationStrings.t('boost_payment_method', locale),
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppSpacing.radiusMd,
            glowColor: AppColors.cyanGlow,
            glowIntensity: 0.15,
            child: Row(
              children: [
                GlassContainer(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.zero,
                  borderRadius: AppSpacing.radiusSm,
                  glowColor: AppColors.cyanGlow,
                  glowIntensity: 0.1,
                  child: Icon(
                    Icons.credit_card,
                    color: AppColors.cyanGlow,
                    size: AppSpacing.iconMd + 2,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MonetizationStrings.t('boost_pay_with_card', locale),
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        MonetizationStrings.t('boost_tap_payments', locale),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: AppColors.cyanGlow, size: AppSpacing.iconMd),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            onTap: () async {
              if (!MonetizationState.canInitiatePayment) return;
              final confirmed = await showSensitiveActionConfirmDialog(
                context,
                title: MonetizationStrings.t(
                  'boost_confirm_payment_title',
                  locale,
                ),
                message: MonetizationStrings.format(
                  'boost_confirm_payment_message',
                  locale,
                  params: {
                    'price': priceFormatted,
                    'listing': widget.listingTitle,
                  },
                ),
                confirmLabel: MonetizationStrings.t(
                  'boost_pay_activate_label',
                  locale,
                ),
                destructive: false,
              );
              if (!confirmed || !mounted) return;

              await SensitiveActionAuditService.log(
                actionId: SensitiveActionIds.boostListingPayment,
                level: PermissionLevel.execute,
                referenceId: widget.listingId,
                metadata: {
                  'packageLabel': pkg['label'],
                  'priceQr': pkg['price'],
                },
              );

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    MonetizationStrings.t('boost_activated_snackbar', locale),
                  ),
                  backgroundColor: AppColors.purpleGlow,
                ),
              );
            },
            glowColor: AppColors.purpleGlow,
            glowIntensity: 0.25,
            backgroundColor: AppColors.purpleGlow,
            borderRadius: AppSpacing.radiusMd,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              MonetizationStrings.format(
                'boost_pay_button',
                locale,
                params: {'price': priceFormatted},
              ),
              style: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: GlassCard(
              onTap: () => Navigator.of(context).pop(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppSpacing.radiusFull,
              child: Text(
                CommonActionStrings.t('action_cancel', locale),
                style: AppTypography.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, color: AppColors.textTertiary, size: AppSpacing.iconXs),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  MonetizationStrings.t('boost_secured_by', locale),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
    int valueMaxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
