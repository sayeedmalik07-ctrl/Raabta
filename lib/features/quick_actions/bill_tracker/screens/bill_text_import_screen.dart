import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_tracker_share_payload.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_text_import_section.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Paste or share-in utility bill SMS text → same review flow as photo/PDF.
class BillTextImportScreen extends ConsumerStatefulWidget {
  const BillTextImportScreen({super.key, this.initialText});

  final String? initialText;

  @override
  ConsumerState<BillTextImportScreen> createState() =>
      _BillTextImportScreenState();
}

class _BillTextImportScreenState extends ConsumerState<BillTextImportScreen> {
  String? _sharedText;

  @override
  void initState() {
    super.initState();
    _sharedText =
        widget.initialText ?? BillTrackerSharePayloadStore.consumeText();
  }

  Future<void> _onPipelineComplete(BillScanPipelineResult result) async {
    if (!mounted) return;
    await context.push('/bill-tracker/scan/review', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: BillTrackerStrings.t('import_text_screen_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: BillTextImportSection(
            locale: locale,
            initialText: _sharedText,
            onPipelineComplete: _onPipelineComplete,
          ),
        ),
      ),
    );
  }
}
