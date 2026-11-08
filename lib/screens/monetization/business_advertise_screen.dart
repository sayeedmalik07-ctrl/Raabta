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
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/monetization_coming_soon_panel.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/monetization/l10n/monetization_strings.dart';

class BusinessAdvertiseScreen extends ConsumerStatefulWidget {
  const BusinessAdvertiseScreen({super.key});

  @override
  ConsumerState<BusinessAdvertiseScreen> createState() =>
      _BusinessAdvertiseScreenState();
}

class _BusinessAdvertiseScreenState
    extends ConsumerState<BusinessAdvertiseScreen> {
  int? _selectedPackage;

  bool get _hold => MonetizationState.isHold;

  final List<Map<String, dynamic>> _adPackages = [
    {
      'index': 0,
      'tierKey': 'ad_tier_basic',
      'price': 0,
      'periodKey': 'ad_period_forever',
      'icon': '📋',
      'borderColor': AppColors.glassBorderBright,
      'accentColor': AppColors.textSecondary,
      'badgeKey': null,
      'featureKeys': [
        'ad_feat_basic_profile',
        'ad_feat_reviews',
        'ad_feat_map_pin',
        'ad_feat_contact',
      ],
      'buttonKey': 'ad_btn_included',
      'buttonEnabled': false,
    },
    {
      'index': 1,
      'tierKey': 'ad_tier_featured',
      'price': MonetizationConfig.businessFeaturedQr,
      'periodKey': 'period_per_month',
      'icon': '⭐',
      'borderColor': AppColors.amberGlow,
      'accentColor': AppColors.amberGlow,
      'badgeKey': 'ad_badge_popular',
      'featureKeys': [
        'ad_feat_featured_badge',
        'ad_feat_top_category',
        'ad_feat_homepage',
        'ad_feat_whatsapp',
        'ad_feat_analytics',
      ],
      'buttonKey': 'ad_btn_featured',
      'buttonEnabled': true,
    },
    {
      'index': 2,
      'tierKey': 'ad_tier_spotlight',
      'price': MonetizationConfig.businessSpotlightQr,
      'periodKey': 'period_per_month',
      'icon': '🔦',
      'borderColor': AppColors.cyanGlow,
      'accentColor': AppColors.cyanGlow,
      'badgeKey': 'ad_badge_best_value',
      'featureKeys': [
        'ad_feat_spotlight_plus',
        'ad_feat_community_banner',
        'ad_feat_ai_sponsored',
        'ad_feat_jobs_spotlight',
        'ad_feat_full_analytics',
        'ad_feat_monthly_report',
      ],
      'buttonKey': 'ad_btn_spotlight',
      'buttonEnabled': true,
    },
    {
      'index': 3,
      'tierKey': 'ad_tier_banner',
      'price': MonetizationConfig.businessBannerQr,
      'periodKey': 'period_per_month',
      'icon': '📢',
      'borderColor': AppColors.purpleGlow,
      'accentColor': AppColors.purpleGlow,
      'badgeKey': 'ad_badge_max_reach',
      'featureKeys': [
        'ad_feat_banner_plus',
        'ad_feat_home_banner',
        'ad_feat_push_10k',
        'ad_feat_targeted',
        'ad_feat_monthly_report',
        'ad_feat_account_manager',
      ],
      'buttonKey': 'ad_btn_banner',
      'buttonEnabled': true,
    },
  ];

  List<Map<String, dynamic>> _adPackagesFor(String locale) {
    return _adPackages.map((pkg) {
      final price = pkg['price'] as int;
      final priceFormatted = price == 0
          ? null
          : MonetizationConfig.formatQrPerMonth(price);
      final buttonKey = pkg['buttonKey'] as String;
      return {
        ...pkg,
        'tier': MonetizationStrings.t(pkg['tierKey'] as String, locale),
        'period': MonetizationStrings.t(pkg['periodKey'] as String, locale),
        'features': (pkg['featureKeys'] as List<String>)
            .map((k) => MonetizationStrings.t(k, locale))
            .toList(),
        'badge': pkg['badgeKey'] != null
            ? MonetizationStrings.t(pkg['badgeKey'] as String, locale)
            : null,
        'buttonLabel': priceFormatted == null
            ? MonetizationStrings.t(buttonKey, locale)
            : MonetizationStrings.format(
                buttonKey,
                locale,
                params: {'price': priceFormatted},
              ),
      };
    }).toList();
  }

  String _statLabel(String key, String locale) {
    return MonetizationStrings.t(key, locale).replaceFirst(' ', '\n');
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final packages = _adPackagesFor(locale);

    return GlassScreenScaffold(
      title: MonetizationStrings.t('ad_screen_title', locale),
      leading: GlassIconButton(
        icon: Icons.close_rounded,
        tooltip: CommonActionStrings.t('action_cancel', locale),
        onPressed: () => Navigator.of(context).pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReachBanner(locale),
            if (_hold) ...[
              const MonetizationHoldBanner(),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              MonetizationStrings.t(
                _hold ? 'ad_planned_options' : 'ad_choose_plan',
                locale,
              ),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              MonetizationStrings.t('ad_reach_subtitle', locale),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            ...packages.map((pkg) => _buildAdCard(locale, pkg)),
            const SizedBox(height: AppSpacing.lg),
            _buildWhySection(locale),
            const SizedBox(height: AppSpacing.lg),
            _buildContactCTA(locale),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildReachBanner(String locale) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MonetizationStrings.t('ad_audience_title', locale),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _reachStat(
                '50K+',
                _statLabel('ad_stat_monthly_users', locale),
                AppColors.amberGlow,
              ),
              _dividerV(),
              _reachStat(
                '8',
                _statLabel('ad_stat_languages', locale),
                AppColors.cyanGlow,
              ),
              _dividerV(),
              _reachStat(
                '12+',
                _statLabel('ad_stat_nationalities', locale),
                AppColors.purpleGlow,
              ),
              _dividerV(),
              _reachStat(
                '4.8★',
                _statLabel('ad_stat_rating', locale),
                AppColors.amberGlow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reachStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headline2.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _dividerV() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.glassBorder,
    );
  }

  Widget _buildAdCard(String locale, Map<String, dynamic> pkg) {
    final isSelected = _selectedPackage == pkg['index'];
    final accent = pkg['accentColor'] as Color;
    final enabled = (pkg['buttonEnabled'] as bool) && !_hold;
    final price = pkg['price'] as int;

    return GlassCard(
      onTap: enabled
          ? () => setState(() => _selectedPackage = pkg['index'])
          : null,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      glowColor: isSelected ? accent : null,
      glowIntensity: isSelected ? 0.2 : 0,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(pkg['icon'] as String, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pkg['tier'] as String, style: AppTypography.title),
                        Text(
                          price == 0
                              ? pkg['period'] as String
                              : _hold
                                  ? MonetizationStrings.format(
                                      'ad_planned_price',
                                      locale,
                                      params: {
                                        'price': MonetizationConfig
                                            .formatQrPerMonthShort(price),
                                      },
                                    )
                                  : MonetizationConfig.formatQrPerMonthShort(
                                      price,
                                    ),
                          style: TextStyle(
                            color: pkg['price'] == 0
                                ? AppColors.textTertiary
                                : accent,
                            fontSize: pkg['price'] == 0 ? 12 : 18,
                            fontWeight: pkg['price'] == 0
                                ? FontWeight.normal
                                : FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...(pkg['features'] as List<String>).map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        f.endsWith(':')
                            ? Icons.arrow_forward
                            : Icons.check_circle,
                        color: f.endsWith(':')
                            ? AppColors.textSecondary
                            : (enabled ? accent : AppColors.textTertiary),
                        size: 15,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          f,
                          style: AppTypography.bodySmall.copyWith(
                            fontStyle: f.endsWith(':')
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_hold && price > 0) ...[
                const SizedBox(height: AppSpacing.md),
                MonetizationComingSoonPanel(
                  productName: pkg['tier'] as String,
                  plannedPriceLabel: MonetizationStrings.format(
                    'ad_planned_price',
                    locale,
                    params: {
                      'price': MonetizationConfig.formatQrPerMonth(price),
                    },
                  ),
                  subtitle: MonetizationStrings.t(
                    'ad_coming_soon_subtitle',
                    locale,
                  ),
                  accentColor: accent,
                ),
              ] else if (enabled) ...[
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  onTap: () {
                    setState(() => _selectedPackage = pkg['index']);
                    _handleAdSubscribe(locale, pkg);
                  },
                  glowColor: accent,
                  glowIntensity: isSelected ? 0.25 : 0.1,
                  backgroundColor: isSelected
                      ? accent
                      : accent.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.radiusSm,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    pkg['buttonLabel'] as String,
                    style: AppTypography.button.copyWith(
                      color: isSelected
                          ? (accent == AppColors.amberGlow
                              ? AppColors.background
                              : AppColors.textPrimary)
                          : accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
          if (pkg['badge'] != null)
            Positioned(
              top: 0,
              right: 0,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                borderRadius: AppSpacing.radiusXs,
                backgroundColor: accent,
                child: Text(
                  pkg['badge'] as String,
                  style: AppTypography.caption.copyWith(
                    color: accent == AppColors.amberGlow
                        ? AppColors.background
                        : AppColors.textPrimary,
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

  Widget _buildWhySection(String locale) {
    final items = [
      (
        '🎯',
        'ad_why_hyper_targeted',
        'ad_why_hyper_desc',
      ),
      (
        '📱',
        'ad_why_mobile_first',
        'ad_why_mobile_desc',
      ),
      (
        '🌍',
        'ad_why_multilingual',
        'ad_why_multilingual_desc',
      ),
      (
        '📊',
        'ad_why_measurable',
        'ad_why_measurable_desc',
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MonetizationStrings.t('ad_why_title', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MonetizationStrings.t(item.$2, locale),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          MonetizationStrings.t(item.$3, locale),
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCTA(String locale) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusMd,
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.15,
      child: Column(
        children: [
          Text(
            MonetizationStrings.t('ad_custom_package', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MonetizationStrings.t('ad_custom_desc', locale),
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    MonetizationStrings.t('ad_enquiry_snackbar', locale),
                  ),
                  backgroundColor: AppColors.purpleGlow,
                ),
              );
            },
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            borderRadius: AppSpacing.radiusSm,
            glowColor: AppColors.amberGlow,
            glowIntensity: 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: AppSpacing.iconSm, color: AppColors.amberGlow),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  MonetizationStrings.t('ad_contact_team', locale),
                  style: AppTypography.link.copyWith(color: AppColors.amberGlow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAdSubscribe(String locale, Map<String, dynamic> pkg) {
    if (!MonetizationState.canInitiatePayment) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          MonetizationStrings.format(
            'ad_selected_snackbar',
            locale,
            params: {
              'tier': pkg['tier'] as String,
              'price': MonetizationConfig.formatQrPerMonth(
                pkg['price'] as int,
              ),
            },
          ),
        ),
        backgroundColor: AppColors.purpleGlow,
      ),
    );
  }
}
