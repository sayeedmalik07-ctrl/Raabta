import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/intelligence/sensitive_action_confirm.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/models/intelligence/permission_level.dart';
import 'package:raabta/services/intelligence/sensitive_action_audit_service.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_providers.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_claim_basis_builder.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/features/tenancy/services/tenancy_pdf_service.dart';

class TenancyDocumentsScreen extends ConsumerStatefulWidget {
  const TenancyDocumentsScreen({super.key});

  @override
  ConsumerState<TenancyDocumentsScreen> createState() =>
      _TenancyDocumentsScreenState();
}

class _TenancyDocumentsScreenState extends ConsumerState<TenancyDocumentsScreen> {
  bool _generating = false;

  Future<void> _generateAndShare(String locale) async {
    final tenancy = ref.read(tenancyProvider);
    final result = tenancy.result;
    if (result == null) return;

    final confirmed = await showSensitiveActionConfirmDialog(
      context,
      title: TenancyStrings.t('tenancy_documents_title', locale),
      message:
          'Share your tenancy dispute packet externally? '
          'It may contain personal lease and claim details.',
      confirmLabel: 'Generate & share',
    );
    if (!confirmed || !mounted) return;

    await SensitiveActionAuditService.log(
      actionId: SensitiveActionIds.tenancyDisputeShare,
      level: PermissionLevel.confirm,
    );

    setState(() => _generating = true);
    try {
      final pdf = ref.read(tenancyPdfServiceProvider);
      final uid = ref.read(currentUserProvider)?.uid ?? '';
      final caseId = CaseTimelineNavigation.tenancyCaseIdFromCheckedAt(
        result.checkedAt,
      );
      final timelineEntries = uid.isEmpty
          ? const <CaseTimelineEntry>[]
          : await ref.read(caseTimelineServiceProvider).listForCase(
                userId: uid,
                engineType: CaseTimelineEngineType.tenancy,
                caseId: caseId,
              );
      final file = await pdf.generateDisputePacket(
        input: tenancy.input,
        result: result,
        collectedItemIds: tenancy.checklistCollected,
        locale: locale,
        timelineEntries: timelineEntries,
      );

      final claimKeys = TenancyClaimBasisBuilder.basisKeys(
        result: result,
        input: tenancy.input,
      );
      await ref.read(tenancyProvider.notifier).savePacketMetadata(
            claimBasisKeys: claimKeys,
          );

      await pdf.sharePacket(file, locale: locale);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final result = ref.watch(tenancyProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (result == null) {
          return GlassScreenScaffold(
            title: TenancyStrings.t('tenancy_documents_title', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.picture_as_pdf_outlined,
              title: TenancyStrings.t('tenancy_documents_title', locale),
              description: TenancyStrings.t('tenancy_documents_need_check', locale),
              actionLabel: TenancyStrings.t('tenancy_dashboard_cta', locale),
              onAction: () => context.push('/tenancy/lease-entry'),
            ),
          );
        }

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_documents_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              Text(
                TenancyStrings.t('tenancy_packet_not_claim_form', locale),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassPrimaryButton(
                label: _generating
                    ? '…'
                    : TenancyStrings.t('tenancy_documents_cta', locale),
                expand: true,
                accentColor: AppColors.chipLease,
                icon: Icons.ios_share_rounded,
                onPressed: _generating ? null : () => _generateAndShare(locale),
              ),
            ],
          ),
        );
      },
    );
  }
}
