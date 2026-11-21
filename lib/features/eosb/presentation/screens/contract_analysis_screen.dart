import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_hub_primary_button.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/shared/eosb_locale_load_error_scaffold.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_salary_claude_consent_feedback.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/eosb/services/eosb_document_import_service.dart';
import 'package:raabta/features/eosb/services/eosb_contract_analysis_service.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_engine.dart';
import 'package:raabta/features/contract_scam_patterns/presentation/contract_scam_pattern_checks_section.dart';

class ContractAnalysisScreen extends ConsumerStatefulWidget {
  const ContractAnalysisScreen({super.key});

  @override
  ConsumerState<ContractAnalysisScreen> createState() =>
      _ContractAnalysisScreenState();
}

class _ContractAnalysisScreenState
    extends ConsumerState<ContractAnalysisScreen> {
  final _textController = TextEditingController();
  String _documentKind = EosbDocumentImportService.supportedDocumentKinds.first;
  bool _loading = false;
  double? _ocrConfidence;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDocumentKind(String locale) async {
    final picked = await showCalculatorPickerSheet<String>(
      context: context,
      title: EosbStrings.t('eosb_document_type', locale),
      selected: _documentKind,
      options: EosbDocumentImportService.supportedDocumentKinds
          .map(
            (k) => CalculatorPickerOption(
              value: k,
              label: EosbDocumentImportService.documentKindLabel(k, locale),
            ),
          )
          .toList(),
    );
    if (picked != null) setState(() => _documentKind = picked);
  }

  Future<void> _analyze(String locale) async {
    final text = _textController.text.trim();
    if (text.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(EosbStrings.t('eosb_contract_text_short', locale)),
        ),
      );
      return;
    }

    final consent = await ref.read(eosbSalaryConsentProvider.future);
    if (!consent) {
      if (mounted) showEosbSalaryClaudeConsentSnackBar(context, locale);
      return;
    }

    setState(() => _loading = true);
    try {
      final import = ref.read(eosbDocumentImportServiceProvider);
      final analysis = await import.importFromText(
        ocrText: text,
        documentKind: _documentKind,
        language: locale,
        ocrConfidence: _ocrConfidence,
      );

      if (_isQualityRejection(analysis)) {
        final reasonKey = analysis.warnings.first;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(EosbStrings.t(reasonKey, locale)),
              action: SnackBarAction(
                label: EosbStrings.t('eosb_scan_document', locale),
                onPressed: () => context.push('/scanner/capture'),
              ),
            ),
          );
        }
        return;
      }

      ref.read(eosbContractAnalysisProvider.notifier).state = analysis;

      final updated = ref
          .read(eosbContractAnalysisServiceProvider)
          .applyAnalysisToInput(ref.read(eosbProvider).input, analysis);
      ref.read(eosbProvider.notifier).updateInput(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(EosbStrings.t('eosb_contract_applied', locale)),
            backgroundColor: AppColors.successBright,
          ),
        );
      }
    } on EosbSalaryClaudeConsentRequired {
      if (mounted) showEosbSalaryClaudeConsentSnackBar(context, locale);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isQualityRejection(EosbContractAnalysis analysis) {
    if (analysis.warnings.isEmpty || analysis.rawSummary != null) return false;
    const qualityKeys = {
      'eosb_contract_quality_short',
      'eosb_contract_quality_words',
      'eosb_contract_quality_garbled',
      'eosb_contract_quality_ocr',
    };
    return qualityKeys.contains(analysis.warnings.first);
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);

    final presentationLocale = ref.watch(eosbPresentationLocaleProvider);
    final analysis = ref.watch(eosbContractAnalysisProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => EosbLocaleLoadErrorScaffold(
        scaffoldTitle: EosbStrings.t(
          'eosb_contract_analysis',
          presentationLocale,
        ),
        titleStyle: HubTypography.hubTitle,
      ),
      data: (locale) => GlassScreenScaffold(
        title: EosbStrings.t('eosb_contract_analysis', locale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            EosbDisclaimerBanner(locale: locale),
            const SizedBox(height: AppSpacing.lg),
            Text(
              EosbStrings.t('eosb_contract_analysis_desc', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            CalculatorSectionHeader(
              title: EosbStrings.t('eosb_contract_input_title', locale),
              subtitle: EosbStrings.t('eosb_contract_input_sub', locale),
              icon: Icons.description_outlined,
              accentColor: AppColors.cyanGlow,
            ),
            CalculatorFormSection(
              glowColor: AppColors.cyanGlow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CalculatorPickerField(
                    label: EosbStrings.t('eosb_document_type', locale),
                    valueLabel: EosbDocumentImportService.documentKindLabel(
                      _documentKind,
                      locale,
                    ),
                    onTap: () => _pickDocumentKind(locale),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    EosbStrings.t('eosb_contract_paste_label', locale),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: EosbStrings.t(
                        'eosb_contract_paste_hint',
                        locale,
                      ),
                      filled: true,
                      fillColor: AppColors.glassSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        borderSide: BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: CalculatorFeatureAction(
                    title: EosbStrings.t('eosb_scan_document', locale),
                    subtitle: EosbStrings.t('eosb_scan_document_sub', locale),
                    icon: Icons.document_scanner_outlined,
                    accentColor: AppColors.purpleGlow,
                    onTap: () => context.push('/scanner/capture'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: CalculatorFeatureAction(
                    title: EosbStrings.t('eosb_import_vault', locale),
                    subtitle: EosbStrings.t('eosb_import_vault_sub', locale),
                    icon: Icons.folder_outlined,
                    accentColor: AppColors.accentGold,
                    onTap: () => context.push('/document-vault'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            EosbHubPrimaryButton(
              label: _loading
                  ? EosbStrings.t('eosb_analyzing', locale)
                  : EosbStrings.t('eosb_analyze_contract', locale),
              expand: true,
              icon: Icons.fact_check_outlined,
              onPressed: _loading ? null : () => _analyze(locale),
            ),
            if (_textController.text.trim().length >= 20) ...[
              const SizedBox(height: AppSpacing.xl),
              ContractScamPatternChecksSection(
                locale: locale,
                result: ContractScamPatternEngine.scan(
                  text: _textController.text,
                ),
              ),
            ],
            if (analysis != null) ...[
              const SizedBox(height: AppSpacing.xl),
              TruthConfidenceBanner(
                locale: locale,
                state:
                    analysis.confidence >= 0.7 &&
                        (analysis.basicSalary != null ||
                            analysis.joiningDate != null)
                    ? TruthConfidenceState.known
                    : TruthConfidenceState.possible,
                text:
                    analysis.confidence >= 0.7 &&
                        (analysis.basicSalary != null ||
                            analysis.joiningDate != null)
                    ? TruthPackageCatalog.eosbAssumptionDisplay(1, locale)
                    : TruthPackageCatalog.eosbAssumptionDisplay(0, locale),
              ),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.unknown,
                text: TruthPackageCatalog.eosbUnknownDisplay(0, locale),
              ),
              const SizedBox(height: AppSpacing.md),
              if (analysis.warnings.contains(
                eosbContractAiParseWarningKey,
              )) ...[
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  glowColor: AppColors.warning,
                  child: Text(
                    EosbStrings.t(eosbContractAiParseWarningKey, locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (analysis.rawSummary != null)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  glowColor: AppColors.info,
                  child: Text(analysis.rawSummary!, style: AppTypography.body),
                ),
              if (analysis.illegalClauses.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  EosbStrings.t('eosb_illegal_clauses', locale),
                  style: AppTypography.title,
                ),
                ...analysis.illegalClauses.map(
                  (c) => _ResultCard(
                    icon: Icons.gavel,
                    color: AppColors.errorBright,
                    text: c,
                  ),
                ),
              ],
              if (analysis.missingBenefits.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  EosbStrings.t('eosb_missing_benefits', locale),
                  style: AppTypography.title,
                ),
                ...analysis.missingBenefits.map(
                  (c) => _ResultCard(
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.accentGold,
                    text: c,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              EosbHubPrimaryButton(
                label: EosbStrings.t('eosb_continue_employee_info', locale),
                expand: true,
                icon: Icons.arrow_forward,
                onPressed: () => context.push('/eosb/employee-info'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: color,
      glowIntensity: 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
