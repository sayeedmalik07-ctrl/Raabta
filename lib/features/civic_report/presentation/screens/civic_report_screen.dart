import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/raabta_platform_notices_panel.dart';
import 'package:raabta/features/civic_report/domain/civic_channel_registry.dart';
import 'package:raabta/features/civic_report/domain/civic_issue_taxonomy.dart';
import 'package:raabta/features/civic_report/domain/civic_report_manual_template.dart';
import 'package:raabta/features/civic_report/domain/civic_report_route_decision.dart';
import 'package:raabta/features/civic_report/domain/civic_report_router.dart';
import 'package:raabta/features/civic_report/presentation/l10n/civic_report_strings.dart';
import 'package:raabta/features/civic_report/presentation/widgets/civic_report_channel_actions.dart';
import 'package:raabta/providers/visa_providers.dart';

class CivicReportScreen extends ConsumerStatefulWidget {
  const CivicReportScreen({super.key});

  static const route = '/civic-report';

  @override
  ConsumerState<CivicReportScreen> createState() => _CivicReportScreenState();
}

class _CivicReportScreenState extends ConsumerState<CivicReportScreen> {
  CivicIssueTypeId? _selected;
  final _templateController = TextEditingController();

  @override
  void dispose() {
    _templateController.dispose();
    super.dispose();
  }

  CivicReportRouteDecision? get _decision =>
      _selected == null ? null : CivicReportRouter.decide(_selected!);

  String _issueLabel(String locale, CivicIssueTypeId issue) =>
      CivicReportStrings.t(issue.labelKey(), locale);

  void _onSelectIssue(CivicIssueTypeId issue) {
    setState(() {
      _selected = issue;
      final locale = ref.read(userLanguageProvider);
      if (issue == CivicIssueTypeId.otherUnsure) {
        _templateController.text = CivicReportManualTemplate.build(
          locale: locale,
          issueLabel: _issueLabel(locale, issue),
        );
        return;
      }
      final decision = CivicReportRouter.decide(issue);
      if (decision.kind == CivicReportOutcomeKind.manualTemplate ||
          decision.kind == CivicReportOutcomeKind.registryChannels) {
        _templateController.text = CivicReportManualTemplate.build(
          locale: locale,
          issueLabel: _issueLabel(locale, issue),
        );
      } else {
        _templateController.clear();
      }
    });
  }

  Future<void> _refreshTemplateForRegistry(String locale) async {
    final issue = _selected;
    if (issue == null) return;
    final enabled = await CivicChannelRegistry.enabledForIssue(issue);
    if (!mounted) return;
    if (enabled.isEmpty) {
      _templateController.text = CivicReportManualTemplate.build(
        locale: locale,
        issueLabel: _issueLabel(locale, issue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final decision = _decision;

    return GlassScreenScaffold(
      title: CivicReportStrings.t('civic_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            CivicReportStrings.t('civic_screen_intro', locale),
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RaabtaPlatformNoticesPanel(locale: locale, dense: true),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CivicReportStrings.t('civic_screen_short_notice', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            CivicReportStrings.t('civic_section_choose_issue', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...CivicIssueTypeId.selectableCategories().map((issue) {
            final selected = _selected == issue;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: GlassCard(
                onTap: () => _onSelectIssue(issue),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? AppColors.cyanGlow
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _issueLabel(locale, issue),
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (decision != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _OutcomePanel(
              locale: locale,
              decision: decision,
              templateController: _templateController,
              onRegistryLoaded: () => _refreshTemplateForRegistry(locale),
            ),
          ],
        ],
      ),
    );
  }
}

class _OutcomePanel extends StatelessWidget {
  const _OutcomePanel({
    required this.locale,
    required this.decision,
    required this.templateController,
    required this.onRegistryLoaded,
  });

  final String locale;
  final CivicReportRouteDecision decision;
  final TextEditingController templateController;
  final VoidCallback onRegistryLoaded;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            CivicReportStrings.t(decision.explanationKey, locale),
            style: AppTypography.body.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          switch (decision.kind) {
            CivicReportOutcomeKind.delegateExistingRoute =>
              GlassPrimaryButton(
                label: CivicReportStrings.t('civic_action_continue', locale),
                onPressed: () => context.push(decision.routePath!),
              ),
            CivicReportOutcomeKind.chooseCategory => _ManualTemplateSection(
                locale: locale,
                templateController: templateController,
                introKey: 'civic_outcome_other_unsure_manual_intro',
              ),
            CivicReportOutcomeKind.registryChannels =>
              _RegistryOutcome(
                locale: locale,
                issue: decision.issue,
                templateController: templateController,
                onLoaded: onRegistryLoaded,
              ),
            CivicReportOutcomeKind.manualTemplate => _ManualTemplateSection(
                locale: locale,
                templateController: templateController,
              ),
          },
        ],
      ),
    );
  }
}

class _RegistryOutcome extends StatefulWidget {
  const _RegistryOutcome({
    required this.locale,
    required this.issue,
    required this.templateController,
    required this.onLoaded,
  });

  final String locale;
  final CivicIssueTypeId issue;
  final TextEditingController templateController;
  final VoidCallback onLoaded;

  @override
  State<_RegistryOutcome> createState() => _RegistryOutcomeState();
}

class _RegistryOutcomeState extends State<_RegistryOutcome> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  @override
  void didUpdateWidget(covariant _RegistryOutcome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issue != widget.issue) {
      _loadFuture = _load();
    }
  }

  Future<void> _load() async {
    await CivicChannelRegistry.enabledForIssue(widget.issue);
    widget.onLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return FutureBuilder(
          future: CivicChannelRegistry.enabledForIssue(widget.issue),
          builder: (context, enabledSnap) {
            final enabled = enabledSnap.data ?? [];
            if (enabled.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    CivicReportStrings.t(
                      'civic_outcome_verifying_contacts',
                      widget.locale,
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ManualTemplateSection(
                    locale: widget.locale,
                    templateController: widget.templateController,
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final channel in enabled) ...[
                  Text(
                    CivicReportStrings.t(channel.displayNameKey, widget.locale),
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CivicReportStrings.t(
                      channel.authorityNameKey,
                      widget.locale,
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (channel.sourceLabel.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${CivicReportStrings.t('civic_channel_source_label', widget.locale)}: ${channel.sourceLabel}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  CivicReportChannelActions(
                    channel: channel,
                    locale: widget.locale,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _ManualTemplateSection extends StatelessWidget {
  const _ManualTemplateSection({
    required this.locale,
    required this.templateController,
    this.introKey = 'civic_outcome_manual_intro',
  });

  final String locale;
  final TextEditingController templateController;
  final String introKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          CivicReportStrings.t(introKey, locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: templateController,
          maxLines: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassPrimaryButton(
          label: CivicReportStrings.t('civic_action_copy_template', locale),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: templateController.text),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    CivicReportStrings.t('civic_action_copy_template', locale),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
