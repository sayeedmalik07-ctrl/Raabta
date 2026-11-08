import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/health_insurance/data/models/insurance_policy_model.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_share_card.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';

class PolicyExplainerScreen extends ConsumerStatefulWidget {
  const PolicyExplainerScreen({super.key});

  @override
  ConsumerState<PolicyExplainerScreen> createState() =>
      _PolicyExplainerScreenState();
}

class _PolicyExplainerScreenState extends ConsumerState<PolicyExplainerScreen> {
  InsurancePolicyDocument? _selectedDoc;

  Stream<QuerySnapshot<Map<String, dynamic>>> _healthDocsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .where('category', isEqualTo: 'Health Insurance')
        .limit(20)
        .snapshots();
  }

  Future<void> _analyzeSelected() async {
    final doc = _selectedDoc;
    if (doc == null) return;
    await ref.read(healthInsuranceProvider.notifier).explainPolicy(doc);
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);
    final hiState = ref.watch(healthInsuranceProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_policy_explainer_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HealthInsuranceDisclaimerBanner(
                locale: locale,
                strongPolicyDisclaimer: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _healthDocsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return GlassEmptyState(
                        icon: Icons.health_and_safety_outlined,
                        title: HealthInsuranceStrings.t(
                          'hi_policy_empty_title',
                          locale,
                        ),
                        description: HealthInsuranceStrings.t(
                          'hi_policy_empty_desc',
                          locale,
                        ),
                        actionLabel: HealthInsuranceStrings.t(
                          'hi_dashboard_upload_cta',
                          locale,
                        ),
                        onAction: () =>
                            context.push('/health-insurance/upload'),
                      );
                    }

                    return ListView(
                      children: [
                        Text(
                          HealthInsuranceStrings.t('hi_form_insurer_label', locale),
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final d in docs)
                          _DocTile(
                            id: d.id,
                            data: d.data(),
                            selected: _selectedDoc?.documentId == d.id,
                            onTap: () {
                              final data = d.data();
                              setState(() {
                                _selectedDoc = InsurancePolicyDocument(
                                  documentId: d.id,
                                  displayName: data['displayName'] as String? ??
                                      'Health Insurance',
                                  ocrText: data['ocrText'] as String? ?? '',
                                  aiSummary: data['aiSummary'] as String? ?? '',
                                );
                              });
                            },
                          ),
                        if (hiState.policyExplainer != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _ExplainerBody(
                            locale: locale,
                            result: hiState.policyExplainer!,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GlassPrimaryButton(
                            label: HealthInsuranceStrings.t(
                              'hi_share_card',
                              locale,
                            ),
                            icon: Icons.ios_share_rounded,
                            expand: true,
                            accentColor: AppColors.chipHealthInsurance,
                            onPressed: () => showHealthInsurancePolicyShareCard(
                              context,
                              result: hiState.policyExplainer!,
                              documentName: _selectedDoc?.displayName ??
                                  'Health Insurance Policy',
                              locale: locale,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          GlassPrimaryButton(
                            label: HealthInsuranceStrings.t(
                              'hi_denial_entry_cta',
                              locale,
                            ),
                            icon: Icons.gavel_outlined,
                            expand: true,
                            onPressed: () =>
                                context.push('/health-insurance/denial-dispute'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              if (_selectedDoc != null)
                GlassPrimaryButton(
                  label: hiState.isExplaining
                      ? '…'
                      : HealthInsuranceStrings.t('hi_policy_analyze', locale),
                  expand: true,
                  accentColor: AppColors.chipHealthInsurance,
                  onPressed: hiState.isExplaining ? null : _analyzeSelected,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.id,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final Map<String, dynamic> data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = data['displayName'] as String? ?? 'Health Insurance';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onTap,
        glowColor: selected ? AppColors.chipHealthInsurance : null,
        glowIntensity: selected ? 0.14 : 0.04,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? AppColors.chipHealthInsurance
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(name, style: AppTypography.body)),
          ],
        ),
      ),
    );
  }
}

class _ExplainerBody extends StatelessWidget {
  const _ExplainerBody({required this.locale, required this.result});

  final String locale;
  final PolicyExplainerResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.coverageCategories.isNotEmpty)
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.known,
            text: TruthPackageCatalog.healthInsurancePolicyAssumptionDisplay(
              0,
              locale,
            ),
          )
        else
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.possible,
            text: TruthPackageCatalog.healthInsurancePolicyAssumptionDisplay(
              0,
              locale,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        TruthConfidenceBanner(
          locale: locale,
          state: TruthConfidenceState.unknown,
          text: TruthPackageCatalog.healthInsurancePolicyUnknownDisplay(
            0,
            locale,
          ),
        ),
        if (result.ambiguityNotes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            text: result.ambiguityNotes.first,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(result.summary, style: AppTypography.body),
        if (result.coverageCategories.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            HealthInsuranceStrings.t('hi_policy_section_coverage', locale),
            style: AppTypography.title,
          ),
          for (final c in result.coverageCategories)
            Text('• $c', style: AppTypography.bodySmall),
        ],
        if (result.exclusions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            HealthInsuranceStrings.t('hi_policy_section_exclusions', locale),
            style: AppTypography.title,
          ),
          for (final e in result.exclusions)
            Text('• $e', style: AppTypography.bodySmall),
        ],
        if (result.networkNotes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            HealthInsuranceStrings.t('hi_policy_section_network', locale),
            style: AppTypography.title,
          ),
          for (final n in result.networkNotes)
            Text('• $n', style: AppTypography.bodySmall),
        ],
        if (result.ambiguityNotes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            HealthInsuranceStrings.t('hi_policy_section_notes', locale),
            style: AppTypography.title,
          ),
          for (final a in result.ambiguityNotes)
            Text('• $a', style: AppTypography.bodySmall),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          HealthInsuranceStrings.t(result.disclaimerKey, locale),
          style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
        ),
      ],
    );
  }
}
