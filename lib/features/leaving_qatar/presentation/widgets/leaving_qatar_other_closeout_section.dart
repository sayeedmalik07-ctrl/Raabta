import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/leaving_qatar/data/leaving_qatar_closeout_config.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_eosb_card.dart';
import 'package:raabta/features/leaving_qatar/providers/leaving_qatar_providers.dart';

class LeavingQatarOtherCloseoutSection extends ConsumerWidget {
  const LeavingQatarOtherCloseoutSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionAsync = ref.watch(leavingQatarCloseoutCompletionProvider);
    final completion = completionAsync.valueOrNull ?? const {};

    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: AppColors.textSecondary,
      glowIntensity: 0.08,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          title: Text(
            LeavingQatarStrings.t('lq_closeout_section_title', locale),
            style: AppTypography.subtitle,
          ),
          subtitle: Text(
            LeavingQatarStrings.t('lq_closeout_section_teaser', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LeavingQatarStrings.t('lq_closeout_offline_hint', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _GroupHeading(
                    LeavingQatarStrings.t('lq_closeout_group_vehicle', locale),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_vehicle_transfer_title',
                    bodyKey: 'lq_closeout_vehicle_transfer_body',
                    completed: completion['vehicle_ownership'] == true,
                    onToggle: (v) =>
                        _set(ref, 'vehicle_ownership', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_metrash',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.metrashPortalUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_moi',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.metrashPortalUrl,
                    ),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_traffic_fines_title',
                    bodyKey: 'lq_closeout_traffic_fines_body',
                    completed: completion['traffic_violations'] == true,
                    onToggle: (v) =>
                        _set(ref, 'traffic_violations', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_traffic_inquiry',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.moiTrafficServicesUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_moi',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.moiTrafficServicesUrl,
                    ),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_vehicle_export_title',
                    bodyKey: 'lq_closeout_vehicle_export_body',
                    completed: completion['vehicle_export_signpost'] == true,
                    onToggle: (v) =>
                        _set(ref, 'vehicle_export_signpost', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_traffic_certificates',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.moiTrafficCertificatesUrl,
                        ),
                      ),
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_qna_vehicle_exit',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.qnaVehicleExitPermitUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_moi_traffic',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.moiTrafficCertificatesUrl,
                      sourceDateIso:
                          LeavingQatarCloseoutConfig.qnaVehicleExitPermitSourceDate,
                      secondarySourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_qna',
                        locale,
                      ),
                    ),
                  ),
                  _GroupHeading(
                    LeavingQatarStrings.t('lq_closeout_group_school', locale),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_school_title',
                    bodyKey: 'lq_closeout_school_body',
                    completed: completion['school_records'] == true,
                    onToggle: (v) => _set(ref, 'school_records', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_moehe_portal',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.moeheEduservicesUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_moehe',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.moeheEduservicesUrl,
                    ),
                  ),
                  _GroupHeading(
                    LeavingQatarStrings.t('lq_closeout_group_pets', locale),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_pets_title',
                    bodyKey: 'lq_closeout_pets_body',
                    completed: completion['pets_planning'] == true,
                    onToggle: (v) => _set(ref, 'pets_planning', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_municipality',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.municipalityPublicServicesUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_municipality',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.municipalityPublicServicesUrl,
                    ),
                  ),
                  _GroupHeading(
                    LeavingQatarStrings.t('lq_closeout_group_pcc', locale),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_pcc_title',
                    bodyKey: 'lq_closeout_pcc_body',
                    completed: completion['police_clearance'] == true,
                    onToggle: (v) =>
                        _set(ref, 'police_clearance', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_pcc',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.moiPccDepartmentUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_moi',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.moiConductCertificateUrl,
                    ),
                  ),
                  _GroupHeading(
                    LeavingQatarStrings.t(
                      'lq_closeout_group_certificates',
                      locale,
                    ),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_traffic_certs_title',
                    bodyKey: 'lq_closeout_traffic_certs_body',
                    completed: completion['traffic_certificates'] == true,
                    onToggle: (v) =>
                        _set(ref, 'traffic_certificates', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_traffic_certificates',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.moiTrafficCertificatesUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_moi',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.moiTrafficCertificatesUrl,
                    ),
                  ),
                  _GroupHeading(
                    LeavingQatarStrings.t('lq_closeout_group_home', locale),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_tenancy_title',
                    bodyKey: 'lq_closeout_tenancy_body',
                    completed: completion['tenancy_notice'] == true,
                    onToggle: (v) => _set(ref, 'tenancy_notice', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_tenancy',
                          locale,
                        ),
                        onPressed: () => context.push(
                          LeavingQatarCloseoutConfig.tenancyRoute,
                        ),
                        needsInternet: false,
                      ),
                    ],
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_marketplace_title',
                    bodyKey: 'lq_closeout_marketplace_body',
                    completed: completion['marketplace_belongings'] == true,
                    onToggle: (v) =>
                        _set(ref, 'marketplace_belongings', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_marketplace',
                          locale,
                        ),
                        onPressed: () => context.push(
                          LeavingQatarCloseoutConfig.marketplaceRoute,
                        ),
                        needsInternet: false,
                      ),
                    ],
                  ),
                  _GroupHeading(
                    LeavingQatarStrings.t('lq_closeout_group_airport', locale),
                  ),
                  _CloseoutItemTile(
                    locale: locale,
                    titleKey: 'lq_closeout_qdi_title',
                    bodyKey: 'lq_closeout_qdi_body',
                    completed: completion['qdi_airport'] == true,
                    onToggle: (v) => _set(ref, 'qdi_airport', v ?? false),
                    actions: [
                      _LinkAction(
                        label: LeavingQatarStrings.t(
                          'lq_closeout_action_moi_portal',
                          locale,
                        ),
                        onPressed: () => openLeavingQatarOfficialLink(
                          LeavingQatarCloseoutConfig.moiPortalUrl,
                        ),
                      ),
                    ],
                    trust: _TrustSpec(
                      sourceName: LeavingQatarStrings.t(
                        'lq_closeout_source_moi',
                        locale,
                      ),
                      url: LeavingQatarCloseoutConfig.moiPortalUrl,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    LeavingQatarStrings.tf(
                      'lq_closeout_verified_footer',
                      locale,
                      {'date': LeavingQatarCloseoutConfig.lastVerifiedIso},
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _set(WidgetRef ref, String id, bool value) async {
    await ref
        .read(leavingQatarCloseoutPrefsServiceProvider)
        .setCompleted(id, value);
    ref.invalidate(leavingQatarCloseoutCompletionProvider);
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.cyanGlow,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TrustSpec {
  const _TrustSpec({
    required this.sourceName,
    required this.url,
    this.sourceDateIso,
    this.secondarySourceName,
  });

  final String sourceName;
  final String url;
  final String? sourceDateIso;
  final String? secondarySourceName;
}

class _LinkAction {
  const _LinkAction({
    required this.label,
    required this.onPressed,
    this.needsInternet = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool needsInternet;
}

class _CloseoutItemTile extends StatelessWidget {
  const _CloseoutItemTile({
    required this.locale,
    required this.titleKey,
    required this.bodyKey,
    required this.completed,
    required this.onToggle,
    required this.actions,
    this.trust,
  });

  final String locale;
  final String titleKey;
  final String bodyKey;
  final bool completed;
  final ValueChanged<bool?> onToggle;
  final List<_LinkAction> actions;
  final _TrustSpec? trust;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: LeavingQatarStrings.t(titleKey, locale),
                checked: completed,
                child: Checkbox(
                  value: completed,
                  onChanged: onToggle,
                  activeColor: AppColors.emeraldGlow,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LeavingQatarStrings.t(titleKey, locale),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                        color: completed
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LeavingQatarStrings.t(bodyKey, locale),
                      style: AppTypography.caption.copyWith(
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trust != null) ...[
            const SizedBox(height: AppSpacing.xs),
            TrustLabel(
              type: TrustLabelType.official,
              locale: locale,
              sourceName: trust!.sourceName,
              verifiedDateIso: LeavingQatarCloseoutConfig.lastVerifiedIso,
              sourceUrl: trust!.url,
              showDetail: true,
            ),
            if (trust!.secondarySourceName != null) ...[
              const SizedBox(height: 2),
              Text(
                LeavingQatarStrings.tf(
                  'lq_closeout_secondary_source',
                  locale,
                  {
                    'name': trust!.secondarySourceName!,
                    'date': trust!.sourceDateIso ??
                        LeavingQatarCloseoutConfig.lastVerifiedIso,
                  },
                ),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: action.onPressed,
                  icon: Icon(
                    action.needsInternet
                        ? Icons.open_in_new_rounded
                        : Icons.arrow_forward_rounded,
                    size: 16,
                  ),
                  label: Text(
                    action.needsInternet
                        ? '${action.label} · ${LeavingQatarStrings.t('lq_closeout_needs_internet', locale)}'
                        : action.label,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.cyanGlow,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
