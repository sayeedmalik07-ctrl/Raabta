import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/features/eosb/domain/models/employer_track_record_lookup.dart';
import 'package:raabta/features/eosb/domain/services/employer_track_record_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_pre_offer_safety_checklist.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_result_card.dart';
import 'package:raabta/features/eosb/providers/employer_track_record_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Proactive pre-offer employer lookup (Part F) — same API + normalization as Parts A–E.
class EmployerTrackRecordLookupScreen extends ConsumerStatefulWidget {
  const EmployerTrackRecordLookupScreen({
    super.key,
    this.initialEmployerName = '',
  });

  final String initialEmployerName;

  static String route({String? employerName}) {
    final trimmed = employerName?.trim() ?? '';
    if (trimmed.isEmpty) return '/employer-track-record/check';
    return '/employer-track-record/check?employer=${Uri.encodeComponent(trimmed)}';
  }

  @override
  ConsumerState<EmployerTrackRecordLookupScreen> createState() =>
      _EmployerTrackRecordLookupScreenState();
}

class _EmployerTrackRecordLookupScreenState
    extends ConsumerState<EmployerTrackRecordLookupScreen> {
  late final TextEditingController _employerController;
  late final EmployerTrackRecordService _trackRecordService;
  EmployerTrackRecordLookup? _lookup;
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _trackRecordService = ref.read(employerTrackRecordServiceProvider);
    _employerController = TextEditingController(text: widget.initialEmployerName);
    if (widget.initialEmployerName.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runLookup());
    }
  }

  @override
  void dispose() {
    _trackRecordService.cancelPendingLookup();
    _employerController.dispose();
    super.dispose();
  }

  Future<void> _runLookup() async {
    final name = _employerController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _hasSearched = false;
    });

    final result = await _trackRecordService.lookup(companyName: name);
    if (!mounted) return;

    setState(() {
      _lookup = result;
      _loading = false;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: EosbStrings.t('employer_track_record_lookup_title', locale),
      titleStyle: HubTypography.hubTitle,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              EosbStrings.t('employer_track_record_lookup_subtitle', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CalculatorTextField(
              controller: _employerController,
              label: EosbStrings.t('employer_track_record_lookup_hint', locale),
              hint: EosbStrings.t(
                'employer_track_record_lookup_example_hint',
                locale,
              ),
              icon: Icons.business_outlined,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: EosbStrings.t('employer_track_record_lookup_action', locale),
              icon: Icons.search_rounded,
              accentColor: AppColors.brandFamilyMain,
              expand: true,
              onPressed: _employerController.text.trim().isEmpty || _loading
                  ? null
                  : _runLookup,
            ),
            if (_loading) ...[
              const SizedBox(height: AppSpacing.md),
              const Center(
                child: HubLoadingPlaceholder(
                  width: 280,
                  height: 120,
                  silhouette: HubLoadingSilhouette.formTool,
                ),
              ),
            ],
            if (_hasSearched && _lookup != null) ...[
              const SizedBox(height: AppSpacing.lg),
              EmployerTrackRecordResultCard(
                lookup: _lookup!,
                locale: locale,
                showInsufficientData: true,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            EmployerPreOfferSafetyChecklist(locale: locale),
          ],
        ),
      ),
    );
  }
}
