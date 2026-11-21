import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/domain/services/insurer_lookup_service.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';

/// Searchable insurer / TPA / plan lookup with manual-review fallback.
class InsurerLookupField extends StatefulWidget {
  const InsurerLookupField({
    super.key,
    required this.locale,
    required this.lookupService,
    required this.cardLabel,
    required this.onChanged,
  });

  final String locale;
  final InsurerLookupService? lookupService;
  final String cardLabel;
  final void Function({
    required String cardLabel,
    required String resolvedInsurerName,
    required bool manualReview,
    InsurerLookupResult? lookup,
  }) onChanged;

  @override
  State<InsurerLookupField> createState() => _InsurerLookupFieldState();
}

class _InsurerLookupFieldState extends State<InsurerLookupField> {
  InsurerLookupResult? _lastLookup;
  bool _showManual = false;
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _applyLookup(InsurerLookupResult lookup, {bool manual = false}) {
    setState(() => _lastLookup = lookup);
    widget.onChanged(
      cardLabel: lookup.cardLabel ?? lookup.query,
      resolvedInsurerName: lookup.resolvedInsurerName ?? '',
      manualReview:
          manual || lookup.matchType == InsurerLookupMatchType.manualReview,
      lookup: lookup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.lookupService;
    if (service == null) {
      return _ManualFallbackOnly(
        locale: widget.locale,
        controller: _manualController,
        onSubmitted: (text) {
          _applyLookup(
            InsurerLookupResult(
              query: text,
              matchType: InsurerLookupMatchType.manualReview,
              cardLabel: text,
            ),
            manual: true,
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<InsurerLookupSuggestion>(
          initialValue: TextEditingValue(text: widget.cardLabel),
          optionsBuilder: (textEditingValue) {
            return service.suggest(textEditingValue.text);
          },
          displayStringForOption: (option) => option.label,
          onSelected: (option) {
            final lookup = service.resolve(option.label);
            _applyLookup(lookup);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: HealthInsuranceStrings.t(
                  'hi_insurer_search_hint',
                  widget.locale,
                ),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.trim().isEmpty) return;
                _applyLookup(service.resolve(value));
              },
              onSubmitted: (_) => onFieldSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240, maxWidth: 400),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        tileColor: AppColors.surface,
                        hoverColor: AppColors.chipHealthInsurance.withValues(alpha: 0.08),
                        title: Text(option.label, style: AppTypography.body),
                        subtitle: option.subtitle != null
                            ? Text(option.subtitle!, style: AppTypography.caption)
                            : null,
                        leading: Icon(
                          _iconForKind(option.kind),
                          size: 20,
                          color: AppColors.chipHealthInsurance,
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (_lastLookup?.userMessage?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _LookupMessageCard(message: _lastLookup!.userMessage!),
          ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () => setState(() => _showManual = !_showManual),
          icon: const Icon(Icons.help_outline, size: 18),
          label: Text(
            HealthInsuranceStrings.t('hi_insurer_not_listed', widget.locale),
            style: AppTypography.link,
          ),
        ),
        if (_showManual) ...[
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _manualController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: HealthInsuranceStrings.t(
                'hi_insurer_manual_label',
                widget.locale,
              ),
              hintText: HealthInsuranceStrings.t(
                'hi_insurer_manual_hint',
                widget.locale,
              ),
            ),
            onSubmitted: (text) {
              if (text.trim().isEmpty) return;
              _applyLookup(service.manualReview(text.trim()), manual: true);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            HealthInsuranceStrings.t('hi_insurer_manual_note', widget.locale),
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  IconData _iconForKind(InsurerSuggestionKind kind) {
    return switch (kind) {
      InsurerSuggestionKind.insurer => Icons.business_outlined,
      InsurerSuggestionKind.alias => Icons.short_text,
      InsurerSuggestionKind.tpa => Icons.hub_outlined,
      InsurerSuggestionKind.brandedPlan => Icons.card_membership_outlined,
    };
  }
}

class _LookupMessageCard extends StatelessWidget {
  const _LookupMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      glowColor: AppColors.chipHealthInsurance,
      glowIntensity: 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.chipHealthInsurance,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _ManualFallbackOnly extends StatelessWidget {
  const _ManualFallbackOnly({
    required this.locale,
    required this.controller,
    required this.onSubmitted,
  });

  final String locale;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HealthInsuranceStrings.t('hi_insurer_load_error', locale),
          style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: HealthInsuranceStrings.t('hi_insurer_manual_label', locale),
          ),
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}
