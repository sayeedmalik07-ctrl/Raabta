import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/link_safety/l10n/link_safety_strings.dart';
import 'package:raabta/features/link_safety/link_safety_evaluator.dart';
import 'package:raabta/features/link_safety/link_safety_gating.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';

/// Dismissible author-side note — never blocks posting (Phase 32 Part C).
class LinkSafetyAuthorComposeHint extends StatefulWidget {
  const LinkSafetyAuthorComposeHint({
    super.key,
    required this.text,
    required this.locale,
    required this.surface,
    this.onRemoveLink,
  });

  final String text;
  final String locale;
  final LinkSafetySurface surface;
  final VoidCallback? onRemoveLink;

  @override
  State<LinkSafetyAuthorComposeHint> createState() =>
      _LinkSafetyAuthorComposeHintState();
}

class _LinkSafetyAuthorComposeHintState extends State<LinkSafetyAuthorComposeHint> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed || !LinkSafetyGating.labelsEnabled(widget.surface)) {
      return const SizedBox.shrink();
    }

    final assessment = LinkSafetyEvaluator.assessText(
      text: widget.text,
      surface: widget.surface,
      locale: widget.locale,
    );
    final concern = assessment.labels.where((l) => l.isConcern).firstOrNull;
    if (concern == null) return const SizedBox.shrink();

    final message = switch (concern.type) {
      LinkSafetyLabelType.lookalikeOfficial =>
        LinkSafetyStrings.format(
          'ls_author_note',
          widget.locale,
          params: {'org': concern.officialOrganisationName ?? '—'},
        ),
      LinkSafetyLabelType.apkLink =>
        LinkSafetyStrings.t('ls_author_note_apk', widget.locale),
      LinkSafetyLabelType.paymentLinkInChat =>
        LinkSafetyStrings.t('ls_author_note_payment', widget.locale),
      LinkSafetyLabelType.shortenedLink => null,
    };
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Material(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                style: AppTypography.bodySmall,
              ),
              Row(
                children: [
                  if (widget.onRemoveLink != null)
                    TextButton(
                      onPressed: widget.onRemoveLink,
                      child: Text(
                        LinkSafetyStrings.t('ls_author_remove', widget.locale),
                      ),
                    ),
                  TextButton(
                    onPressed: () => setState(() => _dismissed = true),
                    child: Text(
                      LinkSafetyStrings.t(
                        'ls_author_post_anyway',
                        widget.locale,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
