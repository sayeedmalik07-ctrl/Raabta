import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_flow.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_status_models.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_status_providers.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/sensitive_safety_lock_settings_tile.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldShieldStatusScreen extends ConsumerWidget {
  const ScamShieldShieldStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final snapshotAsync = ref.watch(shieldStatusSnapshotProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_shield_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            ScamShieldStrings.t('ss_shield_load_error', locale),
            style: AppTypography.body,
          ),
          data: (snapshot) => ListView(
            children: [
              Text(
                ScamShieldStrings.format('ss_shield_header_count', locale, {
                  'on': '${snapshot.protectionsOn}',
                  'total': '${snapshot.protectionsTotal}',
                }),
                style: AppTypography.headline2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ScamShieldStrings.t('ss_shield_limitation_line', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _section(
                locale,
                'ss_shield_section_phone',
                snapshot.rowsInSection(ShieldStatusSectionId.onYourPhone),
                snapshot,
                context,
              ),
              _section(
                locale,
                'ss_shield_section_alerts',
                snapshot.rowsInSection(ShieldStatusSectionId.alerts),
                snapshot,
                context,
              ),
              _section(
                locale,
                'ss_shield_section_habits',
                snapshot.rowsInSection(ShieldStatusSectionId.habits),
                snapshot,
                context,
              ),
              _section(
                locale,
                'ss_shield_section_freshness',
                snapshot.rowsInSection(ShieldStatusSectionId.dataFreshness),
                snapshot,
                context,
              ),
              _section(
                locale,
                'ss_shield_section_always',
                snapshot.rowsInSection(ShieldStatusSectionId.alwaysAvailable),
                snapshot,
                context,
              ),
              SensitiveSafetyLockSettingsTile(locale: locale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    String locale,
    String titleKey,
    Iterable<ShieldStatusRow> rows,
    ShieldStatusSnapshot snapshot,
    BuildContext context,
  ) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeSectionHeader(
            title: ScamShieldStrings.t(titleKey, locale),
            leadingIcon: Icons.shield_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final row in rows) ...[
                  _ShieldStatusTile(
                    locale: locale,
                    row: row,
                    snapshot: snapshot,
                    onAction: () => _openAction(context, locale, row),
                  ),
                  if (row != rows.last)
                    Divider(
                      height: 1,
                      color: AppColors.glassBorder.withValues(alpha: 0.5),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAction(
    BuildContext context,
    String locale,
    ShieldStatusRow row,
  ) async {
    switch (row.id) {
      case ShieldRowId.callScreening:
        final ok = await PermissionRationaleFlow.showThenContinue(
          context,
          kind: PermissionRationaleKind.androidCallScreening,
          locale: locale,
        );
        if (ok && context.mounted) {
          context.push('/scam-shield/call-screening');
        }
      case ShieldRowId.smsFilterGuide:
        final ok = await PermissionRationaleFlow.showThenContinue(
          context,
          kind: PermissionRationaleKind.iosSmsFilterSettings,
          locale: locale,
        );
        if (ok && context.mounted) {
          context.push('/scam-shield/sms-filter-guide');
        }
      case ShieldRowId.scamAdvisoryAlert:
      case ShieldRowId.securityTip:
      case ShieldRowId.todayCards:
      case ShieldRowId.osNotifications:
        if (row.id == ShieldRowId.osNotifications) {
          final ok = await PermissionRationaleFlow.showThenContinue(
            context,
            kind: PermissionRationaleKind.localNotifications,
            locale: locale,
          );
          if (ok) await openAppSettings();
        }
        if (context.mounted) context.push('/notification-preferences');
      case ShieldRowId.checkup:
        if (context.mounted) context.push('/scam-shield/checkup');
      case ShieldRowId.familyKit:
        if (context.mounted) context.push('/scam-shield/family-verification');
      case ShieldRowId.myBank:
        if (context.mounted) context.push('/scam-shield/report-ready');
      case ShieldRowId.directoryFreshness:
        if (context.mounted) context.push('/scam-shield/official-directory');
      case ShieldRowId.advisoryFreshness:
        if (context.mounted) context.push('/scam-shield/advisories');
      case ShieldRowId.legalFreshness:
        break;
      case ShieldRowId.offlineCoreChecks:
        if (context.mounted) context.go('/scam-shield');
      case ShieldRowId.inCallAssistant:
        if (context.mounted) context.push('/scam-shield/in-call-assistant');
      case ShieldRowId.shareToCheck:
        if (context.mounted) context.push('/scam-shield/share-review');
    }
  }
}

class _ShieldStatusTile extends StatelessWidget {
  const _ShieldStatusTile({
    required this.locale,
    required this.row,
    required this.snapshot,
    required this.onAction,
  });

  final String locale;
  final ShieldStatusRow row;
  final ShieldStatusSnapshot snapshot;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final stateLabel = _stateLabel(locale, row.state);
    final title = ScamShieldStrings.t(_titleKey(row.id), locale);
    final why = ScamShieldStrings.t(_whyKey(row.id), locale);
    final action = ScamShieldStrings.t(_actionKey(row.id), locale);
    final detail = row.detailKey != null
        ? ScamShieldStrings.format(row.detailKey!, locale, row.detailArgs ?? {})
        : _freshnessLine(locale, row.id, snapshot);

    return InkWell(
      onTap: _hasAction(row.id) ? onAction : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTypography.title),
                ),
                _StateChip(label: stateLabel, state: row.state),
              ],
            ),
            if (detail != null && detail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                detail,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              why,
              style: AppTypography.bodySmall,
            ),
            if (_hasAction(row.id)) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(onPressed: onAction, child: Text(action)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _freshnessLine(
    String locale,
    ShieldRowId id,
    ShieldStatusSnapshot snapshot,
  ) {
    final f = snapshot.freshness;
    return switch (id) {
      ShieldRowId.directoryFreshness => _dateLine(
          locale,
          'ss_shield_fresh_directory',
          f.directoryOldestVerified,
          f.directoryMayBeStale,
        ),
      ShieldRowId.advisoryFreshness => _dateLine(
          locale,
          'ss_shield_fresh_advisory',
          f.latestAdvisoryPublished,
          f.advisoryMayBeStale,
        ),
      ShieldRowId.legalFreshness => _dateLine(
          locale,
          'ss_shield_fresh_legal',
          f.legalSourcesUpdated,
          f.legalMayBeStale,
        ),
      _ => null,
    };
  }

  String? _dateLine(
    String locale,
    String key,
    DateTime? date,
    bool stale,
  ) {
    if (date == null) {
      return ScamShieldStrings.t('ss_shield_fresh_unknown', locale);
    }
    final local = date.toLocal();
    final base = ScamShieldStrings.format(key, locale, {
      'date':
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}',
    });
    if (stale) {
      return '$base ${ScamShieldStrings.t('ss_shield_may_be_out_of_date', locale)}';
    }
    return base;
  }

  bool _hasAction(ShieldRowId id) => id != ShieldRowId.legalFreshness;

  String _stateLabel(String locale, ShieldRowState state) {
    return ScamShieldStrings.t(
      switch (state) {
        ShieldRowState.on => 'ss_shield_state_on',
        ShieldRowState.off => 'ss_shield_state_off',
        ShieldRowState.notAvailable => 'ss_shield_state_na_device',
        ShieldRowState.needsAttention => 'ss_shield_state_needs_attention',
        ShieldRowState.selfReported => 'ss_shield_state_self_reported',
        ShieldRowState.informational => 'ss_shield_state_available',
      },
      locale,
    );
  }

  String _titleKey(ShieldRowId id) => 'ss_shield_row_${id.name}_title';

  String _whyKey(ShieldRowId id) => 'ss_shield_row_${id.name}_why';

  String _actionKey(ShieldRowId id) => 'ss_shield_row_${id.name}_action';
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label, required this.state});

  final String label;
  final ShieldRowState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      ShieldRowState.on => AppColors.success,
      ShieldRowState.off => AppColors.textTertiary,
      ShieldRowState.needsAttention => AppColors.warning,
      ShieldRowState.selfReported => AppColors.info,
      ShieldRowState.notAvailable => AppColors.textTertiary,
      ShieldRowState.informational => AppColors.cyanGlow,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
