import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/migrant_support_resource_tile.dart';
import 'package:raabta/features/eosb/presentation/widgets/offer_authenticity_section.dart';
import 'package:raabta/features/contract_scam_patterns/presentation/contract_scam_pattern_before_you_sign_block.dart';
import 'package:raabta/features/eosb/providers/home_country_support_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dismissPrefsKey = 'eosb_before_you_sign_dismissed';

class BeforeYouSignSection extends ConsumerStatefulWidget {
  const BeforeYouSignSection({
    super.key,
    required this.locale,
    required this.employerName,
  });

  final String locale;
  final String employerName;

  @override
  ConsumerState<BeforeYouSignSection> createState() =>
      _BeforeYouSignSectionState();
}

class _BeforeYouSignSectionState extends ConsumerState<BeforeYouSignSection> {
  bool _dismissed = false;
  bool _loadedDismiss = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _loadDismissState();
  }

  Future<void> _loadDismissState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dismissed = prefs.getBool(_dismissPrefsKey) ?? false;
      _loadedDismiss = true;
    });
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissPrefsKey, true);
    if (!mounted) return;
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedDismiss || _dismissed) return const SizedBox.shrink();
    if (widget.employerName.trim().isEmpty) return const SizedBox.shrink();

    final viewAsync = ref.watch(beforeYouSignViewProvider);
    return viewAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (view) {
        if (view.status != BeforeYouSignStatus.supported ||
            view.checklist == null) {
          return const SizedBox.shrink();
        }

        final checklist = view.checklist!;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.accentGold,
            glowIntensity: 0.12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fact_check_outlined,
                        color: AppColors.accentGold, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            EosbStrings.t(
                              'eosb_bys_section_title',
                              widget.locale,
                            ),
                            style: AppTypography.title.copyWith(
                              color: AppColors.accentGold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            EosbStrings.t(
                              'eosb_bys_section_subtitle',
                              widget.locale,
                            ),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: EosbStrings.t('eosb_hcs_dismiss', widget.locale),
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: _dismiss,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _expanded
                                ? EosbStrings.t(
                                    'eosb_bys_collapse',
                                    widget.locale,
                                  )
                                : EosbStrings.t(
                                    'eosb_bys_expand',
                                    widget.locale,
                                  ),
                            style: AppTypography.link.copyWith(
                              color: AppColors.purpleGlow,
                            ),
                          ),
                        ),
                        Icon(
                          _expanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: AppColors.purpleGlow,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_expanded) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (view.offerAuthenticityChecklist != null) ...[
                    OfferAuthenticitySection(
                      checklist: view.offerAuthenticityChecklist!,
                      locale: widget.locale,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ContractScamPatternBeforeYouSignBlock(
                      locale: widget.locale,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Divider(color: AppColors.glassBorder.withValues(alpha: 0.5)),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(
                    EosbStrings.t('eosb_bys_fee_heading', widget.locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          EosbStrings.t(
                            checklist.maxFeeRuleKey,
                            widget.locale,
                          ),
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      if (checklist.maxFeeNeedsVerification)
                        VerifyBadge(locale: widget.locale),
                    ],
                  ),
                  if (checklist.staleWarningKey != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            EosbStrings.t(
                              checklist.staleWarningKey!,
                              widget.locale,
                            ),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        if (checklist.staleWarningNeedsVerification)
                          VerifyBadge(locale: widget.locale),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    EosbStrings.t('eosb_bys_flags_heading', widget.locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...checklist.redFlagKeys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.flag_outlined,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              EosbStrings.t(key, widget.locale),
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    EosbStrings.t(
                      'eosb_bys_origin_verify_heading',
                      widget.locale,
                    ),
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.purpleGlow,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    EosbStrings.t('eosb_bys_verify_disclaimer', widget.locale),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...checklist.originVerificationChannels.map(
                    (resource) => MigrantSupportResourceTile(
                      resource: resource,
                      locale: widget.locale,
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    EosbStrings.t('eosb_bys_qatar_verify_heading', widget.locale),
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...view.qatarVerificationChannels.map(
                    (resource) => MigrantSupportResourceTile(
                      resource: resource,
                      locale: widget.locale,
                      compact: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
