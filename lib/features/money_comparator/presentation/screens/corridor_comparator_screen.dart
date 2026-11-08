import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/live_rates_link_button.dart';
import 'package:raabta/features/money_comparator/domain/corridor_aggregate_logic.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';
import 'package:raabta/features/money_comparator/data/repository/remittance_truth_repository.dart';
import 'package:raabta/features/money_comparator/presentation/providers/corridor_comparator_providers.dart';
import 'package:raabta/features/money_comparator/presentation/providers/remittance_truth_providers.dart';
import 'package:raabta/features/money_comparator/presentation/widgets/corridor_disclaimer_banner.dart';
import 'package:raabta/features/money_comparator/presentation/widgets/corridor_result_card.dart';
import 'package:raabta/features/money_comparator/presentation/widgets/remittance_mid_market_banner.dart';
import 'package:raabta/features/money_comparator/presentation/widgets/remittance_provider_truth_card.dart';
import 'package:raabta/features/money_comparator/presentation/widgets/remittance_truth_headline.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/family_verification_corridor_link.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/services/exchange_rate_service.dart';

class CorridorComparatorScreen extends ConsumerStatefulWidget {
  const CorridorComparatorScreen({
    super.key,
    this.initialCountryCode,
    this.initialAmount,
  });

  final String? initialCountryCode;
  final double? initialAmount;

  @override
  ConsumerState<CorridorComparatorScreen> createState() =>
      _CorridorComparatorScreenState();
}

class _CorridorComparatorScreenState
    extends ConsumerState<CorridorComparatorScreen> {
  late final TextEditingController _amountController;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: (widget.initialAmount ?? 1000).toStringAsFixed(0),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCountryCode != null) {
        ref.read(corridorSelectedCountryProvider.notifier).state =
            widget.initialCountryCode!;
      }
      if (widget.initialAmount != null) {
        ref.read(corridorSendAmountProvider.notifier).state =
            widget.initialAmount!;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final code = ref.read(corridorSelectedCountryProvider);
    ref.invalidate(remittanceMidMarketProvider);
    ref.invalidate(remittanceProviderRatesProvider(code));
    ref.invalidate(corridorAggregatesProvider(code));
    try {
      await Future.wait([
        ref.read(remittanceMidMarketProvider.future),
        ref.read(remittanceProviderRatesProvider(code).future),
        ref.read(corridorAggregatesProvider(code).future),
      ]);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _onAmountChanged(String value) {
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed != null && parsed > 0) {
      ref.read(corridorSendAmountProvider.notifier).state = parsed;
    }
  }

  /// Same vertical footprint as [MoneyHubScreenLoading] (card heights + [AppSpacing.md] gaps).
  Widget _corridorHubLoadingStack({
    required int cardCount,
    required double cardHeight,
    required HubLoadingSilhouette silhouette,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cardCount; i++) ...[
              SizedBox(
                height: cardHeight,
                child: HubLoadingPlaceholder(
                  width: w,
                  height: cardHeight,
                  silhouette: silhouette,
                ),
              ),
              if (i < cardCount - 1) const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }

  static Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.subtitle.copyWith(
        color: moneyHubAccent,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static InputDecoration _corridorAmountDecoration({
    required String locale,
  }) {
    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(color: AppColors.glassBorder),
    );
    return InputDecoration(
      labelText: MoneyComparatorStrings.t('mc_amount_label', locale),
      prefixText: MoneyComparatorStrings.t('mc_amount_prefix', locale),
      hintText: MoneyComparatorStrings.t('mc_amount_hint', locale),
      labelStyle: AppTypography.caption,
      hintStyle:
          AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      filled: true,
      fillColor:
          AppColors.isLight ? AppColors.surface : AppColors.glassSurface,
      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(
          color: AppColors.goldFamilyMain.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final countryCode = ref.watch(corridorSelectedCountryProvider);
    final amount = ref.watch(corridorSendAmountProvider);
    final sortMode = ref.watch(corridorSortModeProvider);
    final midMarketAsync = ref.watch(remittanceMidMarketProvider);
    final providersAsync = ref.watch(remittanceProviderRatesProvider(countryCode));
    final aggregatesAsync = ref.watch(corridorAggregatesProvider(countryCode));
    final currency = currencyInfoForCode(countryCode);

    final midResult = midMarketAsync.valueOrNull;
    final midSnapshot = midResult?.snapshot;
    final corridorRate = midSnapshot?.rateFor(countryCode);
    final providerResult = providersAsync.valueOrNull;
    final providers = providerResult?.providers ?? const [];
    final hasUsableMidMarket = RemittanceTruthRepository.hasUsableCorridorRate(
      midSnapshot,
      countryCode,
    );
    final hasUsableProviders = providers.isNotEmpty;
    final rteFromCache = (midResult?.fromCache ?? false) ||
        (providerResult?.fromCache ?? false);
    final rteStale =
        (midResult?.isStale ?? false) || (providerResult?.isStale ?? false);
    final hasPairedRteComparison = hasUsableMidMarket && hasUsableProviders;

    final comparisonRows = ref.watch(
      remittanceComparisonRowsProvider(
        RemittanceComparisonInput(
          amountSentQar: amount,
          providers: providers,
          midMarketRate: corridorRate?.rate,
        ),
      ),
    );

    return MoneyToolScreenScaffold(
      title: MoneyComparatorStrings.t('mc_title', locale),
      subtitle: MoneyComparatorStrings.t('mc_tool_subtitle', locale),
      onBack: () => context.pop(),
      hero: MoneyToolHeroSendAmount(
        amount: amount,
        caption: MoneyComparatorStrings.t('mc_amount_sent', locale),
        semanticsLabel: MoneyComparatorStrings.t('mc_amount_sent', locale),
      ),
      disclaimer: CorridorDisclaimerBanner(locale: locale),
      statusRow: MoneyToolStatusRow(
        label: MoneyComparatorStrings.t('mc_tool_indicative_line', locale),
      ),
      headerTrailing: IconButton(
        tooltip: MoneyComparatorStrings.t('mc_report_transfer_tooltip', locale),
        icon: Icon(Icons.post_add_outlined, color: AppColors.goldFamilyMain),
        onPressed: () => context.push(
          '/money-services/corridor-comparator/submit?country=$countryCode',
        ),
      ),
      onRefresh: _refresh,
      isRefreshing: _refreshing,
      children: [
        ForewarningSlot(
          momentId: ForewarningMomentId.remittanceFamilyEmergency,
          locale: locale,
        ),
        FamilyVerificationCorridorLink(locale: locale),
        const SizedBox(height: AppSpacing.sm),
        const LiveRatesLinkButton(compact: true),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: moneyHubAccent,
          glowIntensity: 0.05,
          borderRadius: AppSpacing.radiusMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                MoneyComparatorStrings.t('mc_send_to', locale),
                style: AppTypography.caption.copyWith(
                  color: moneyHubAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _CountryPicker(
                selectedCode: countryCode,
                onChanged: (code) {
                  ref.read(corridorSelectedCountryProvider.notifier).state =
                      code;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _corridorAmountDecoration(locale: locale),
                  onChanged: _onAmountChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader(
              MoneyComparatorStrings.t('rte_mid_market', locale),
            ),
            const SizedBox(height: AppSpacing.sm),
            midMarketAsync.when(
              loading: () => _corridorHubLoadingStack(
                cardCount: 1,
                cardHeight: 100,
                silhouette: HubLoadingSilhouette.formTool,
              ),
              error: (error, stackTrace) => GlassEmptyState(
                icon: Icons.trending_flat,
                title: MoneyComparatorStrings.t('rte_no_mid_market', locale),
                description: MoneyComparatorStrings.t('mc_retry', locale),
                actionLabel: MoneyComparatorStrings.t('mc_retry', locale),
                onAction: _refresh,
              ),
              data: (result) {
                if (!hasUsableMidMarket) {
                  return GlassEmptyState(
                    icon: Icons.trending_flat,
                    title: MoneyComparatorStrings.t('rte_no_mid_market', locale),
                    description: rteFromCache || rteStale
                        ? MoneyComparatorStrings.t(
                            'mc_cached_pull_refresh',
                            locale,
                          )
                        : MoneyComparatorStrings.t('mc_retry', locale),
                    actionLabel: MoneyComparatorStrings.t('mc_retry', locale),
                    onAction: _refresh,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (rteFromCache || rteStale) ...[
                      MoneyLiveChip(
                        label:
                            MoneyComparatorStrings.t('rte_mid_market', locale),
                        isLive: false,
                        accentColor: AppColors.warning,
                        warningLabel: MoneyComparatorStrings.t(
                          'mc_cached_pull_refresh',
                          locale,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    RemittanceMidMarketBanner(
                      locale: locale,
                      corridorRate: corridorRate!,
                      currencyCode: countryCode,
                      frankfurterDate: midSnapshot?.frankfurterDate,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        if (comparisonRows.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          RemittanceTruthHeadline(
            locale: locale,
            rows: comparisonRows,
            amountSentQar: amount,
            currencyCode: countryCode,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader(
              MoneyComparatorStrings.t('rte_ranked_providers', locale),
            ),
            const SizedBox(height: AppSpacing.sm),
            providersAsync.when(
              loading: () => _corridorHubLoadingStack(
                cardCount: 3,
                cardHeight: 140,
                silhouette: HubLoadingSilhouette.serviceCard,
              ),
              error: (e, _) => GlassEmptyState(
                icon: Icons.cloud_off_outlined,
                title: MoneyComparatorStrings.t('mc_error_load_title', locale),
                description: MoneyComparatorStrings.t('mc_retry', locale),
                actionLabel: MoneyComparatorStrings.t('mc_retry', locale),
                onAction: _refresh,
              ),
              data: (_) {
                if (!hasPairedRteComparison) {
                  return GlassEmptyState(
                    icon: Icons.compare_arrows,
                    title: MoneyComparatorStrings.t('rte_no_providers', locale),
                    description: rteFromCache || rteStale
                        ? MoneyComparatorStrings.t(
                            'mc_cached_pull_refresh',
                            locale,
                          )
                        : MoneyComparatorStrings.t('mc_retry', locale),
                    actionLabel: MoneyComparatorStrings.t('mc_retry', locale),
                    onAction: _refresh,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < comparisonRows.length; i++) ...[
                      RemittanceProviderTruthCard(
                        row: comparisonRows[i],
                        currencyCode: countryCode,
                        rank: i + 1,
                        locale: locale,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Divider(color: AppColors.textSecondary.withValues(alpha: 0.2)),
        const SizedBox(height: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader(
              MoneyComparatorStrings.t('rte_community_section', locale),
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 360;
                final bestLabel =
                    MoneyComparatorStrings.t('mc_sort_best_value', locale);
                final fastLabel =
                    MoneyComparatorStrings.t('mc_sort_fastest', locale);
                return SegmentedButton<CorridorSortMode>(
                  segments: [
                    ButtonSegment<CorridorSortMode>(
                      value: CorridorSortMode.bestValue,
                      tooltip: bestLabel,
                      icon: const Icon(Icons.savings_outlined, size: 18),
                      label: Text(narrow ? '' : bestLabel),
                    ),
                    ButtonSegment<CorridorSortMode>(
                      value: CorridorSortMode.fastest,
                      tooltip: fastLabel,
                      icon: const Icon(Icons.schedule, size: 18),
                      label: Text(narrow ? '' : fastLabel),
                    ),
                  ],
                  showSelectedIcon: false,
                  selected: {sortMode},
                  onSelectionChanged: (s) {
                    ref.read(corridorSortModeProvider.notifier).state =
                        s.first;
                  },
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              MoneyComparatorStrings.t('mc_community_sort_scope_hint', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (aggregatesAsync.valueOrNull?.isStale == true) ...[
              const SizedBox(height: AppSpacing.sm),
              MoneyLiveChip(
                label: MoneyComparatorStrings.t(
                  'mc_community_transfer_data',
                  locale,
                ),
                isLive: false,
                accentColor: AppColors.warning,
                warningLabel:
                    MoneyComparatorStrings.t('mc_cached_pull_refresh', locale),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            aggregatesAsync.when(
              loading: () => _corridorHubLoadingStack(
                cardCount: 2,
                cardHeight: 120,
                silhouette: HubLoadingSilhouette.serviceCard,
              ),
              error: (e, _) => GlassEmptyState(
                icon: Icons.cloud_off_outlined,
                title: MoneyComparatorStrings.t('mc_error_load_title', locale),
                description: MoneyComparatorStrings.t('mc_retry', locale),
                actionLabel: MoneyComparatorStrings.t('mc_retry', locale),
                onAction: _refresh,
              ),
              data: (result) {
                final rows = buildComparisonRows(
                  aggregates: result.aggregates,
                  amountSentQar: amount,
                  sortMode: sortMode,
                );

                if (rows.isEmpty) {
                  return GlassEmptyState(
                    icon: Icons.groups_outlined,
                    title: MoneyComparatorStrings.t(
                      'mc_not_enough_data_title',
                      locale,
                    ),
                    description: MoneyComparatorStrings.format(
                      'mc_not_enough_data_body',
                      locale,
                      params: {
                        'minReports':
                            CorridorAggregateLogic.minReportsForRanking
                                .toString(),
                        'country': currency?.country ?? countryCode,
                      },
                    ),
                    actionLabel:
                        MoneyComparatorStrings.t('mc_submit_report', locale),
                    onAction: () => context.push(
                      '/money-services/corridor-comparator/submit?country=$countryCode',
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      sortMode == CorridorSortMode.fastest
                          ? MoneyComparatorStrings.t(
                              'mc_ranked_by_speed',
                              locale,
                            )
                          : MoneyComparatorStrings.t(
                              'mc_ranked_by_recipient',
                              locale,
                            ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (var i = 0; i < rows.length; i++) ...[
                      CorridorResultCard(
                        row: rows[i],
                        currencyCode: countryCode,
                        rank: i + 1,
                        locale: locale,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        HubFeedFooterNotice(locale: locale),
      ],
    );
  }
}

class _CountryPicker extends StatelessWidget {
  const _CountryPicker({
    required this.selectedCode,
    required this.onChanged,
  });

  final String selectedCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedCode,
        isExpanded: true,
        dropdownColor: AppColors.surfaceElevated,
        items: [
          for (final c in raabtaCurrencies)
            DropdownMenuItem(
              value: c.code,
              child: Text('${c.flag} ${c.country} (${c.code})'),
            ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
