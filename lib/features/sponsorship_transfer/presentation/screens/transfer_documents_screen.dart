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
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_widgets.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_providers.dart';
import 'package:raabta/features/sponsorship_transfer/services/sponsorship_transfer_analytics_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/features/sponsorship_transfer/services/sponsorship_transfer_pdf_service.dart';

class TransferDocumentsScreen extends ConsumerStatefulWidget {
  const TransferDocumentsScreen({super.key});

  @override
  ConsumerState<TransferDocumentsScreen> createState() =>
      _TransferDocumentsScreenState();
}

class _TransferDocumentsScreenState extends ConsumerState<TransferDocumentsScreen> {
  bool _generating = false;

  Future<void> _generateAndShare(String locale) async {
    final transfer = ref.read(sponsorshipTransferProvider);
    final result = transfer.result;
    if (result == null) return;

    final confirmed = await showSensitiveActionConfirmDialog(
      context,
      title: SponsorshipTransferStrings.t('st_documents_title', locale),
      message:
          'Share your sponsorship transfer preparation packet externally? '
          'It may contain personal employment details.',
      confirmLabel: 'Generate & share',
    );
    if (!confirmed || !mounted) return;

    await SensitiveActionAuditService.log(
      actionId: SensitiveActionIds.sponsorshipPacketShare,
      level: PermissionLevel.confirm,
    );

    setState(() => _generating = true);
    try {
      final pdf = ref.read(sponsorshipTransferPdfServiceProvider);
      final uid = ref.read(currentUserProvider)?.uid ?? '';
      final caseId = CaseTimelineNavigation.sponsorshipCaseIdFromCheckedAt(
        result.checkedAt,
      );
      final timelineEntries = uid.isEmpty
          ? const <CaseTimelineEntry>[]
          : await ref.read(caseTimelineServiceProvider).listForCase(
                userId: uid,
                engineType: CaseTimelineEngineType.sponsorshipTransfer,
                caseId: caseId,
              );
      final file = await pdf.generatePreparationPacket(
        input: transfer.input,
        result: result,
        collectedItemIds: transfer.checklistCollected,
        locale: locale,
        timelineEntries: timelineEntries,
      );

      SponsorshipTransferAnalyticsService.packetGenerated(
        collectedCount: transfer.checklistCollected.length,
      );

      await pdf.sharePacket(file, locale: locale);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(sponsorshipTransferLocaleProvider);
    final result = ref.watch(sponsorshipTransferProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (result == null) {
          return GlassScreenScaffold(
            title: SponsorshipTransferStrings.t('st_documents_title', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.picture_as_pdf_outlined,
              title: SponsorshipTransferStrings.t('st_documents_title', locale),
              description:
                  SponsorshipTransferStrings.t('st_documents_need_check', locale),
              actionLabel:
                  SponsorshipTransferStrings.t('st_dashboard_cta', locale),
              onAction: () => context.push('/sponsorship-transfer/readiness'),
            ),
          );
        }

        return GlassScreenScaffold(
          title: SponsorshipTransferStrings.t('st_documents_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              SponsorshipTransferDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              Text(
                SponsorshipTransferStrings.t('st_packet_not_filing_form', locale),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassPrimaryButton(
                label: _generating
                    ? '…'
                    : SponsorshipTransferStrings.t('st_documents_cta', locale),
                expand: true,
                accentColor: AppColors.chipSponsorshipTransfer,
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
