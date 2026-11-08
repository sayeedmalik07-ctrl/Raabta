import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/link_safety/l10n/link_safety_strings.dart';
import 'package:raabta/features/link_safety/link_safety_evaluator.dart';
import 'package:raabta/features/link_safety/link_safety_gating.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/link_safety_sheets.dart';

/// Shared renderer: user text + local link labels (Phase 32).
class UserGeneratedTextWithLinkSafety extends StatelessWidget {
  const UserGeneratedTextWithLinkSafety({
    super.key,
    required this.text,
    required this.locale,
    required this.surface,
    this.style,
    this.onReportPost,
    this.textAlign,
  });

  final String text;
  final String locale;
  final LinkSafetySurface surface;
  final TextStyle? style;
  final VoidCallback? onReportPost;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? AppTypography.body;
    if (!LinkSafetyGating.labelsEnabled(surface)) {
      return Text(text, style: baseStyle, textAlign: textAlign);
    }

    final assessment = LinkSafetyEvaluator.assessText(
      text: text,
      surface: surface,
      locale: locale,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LinkifiedText(
          text: text,
          style: baseStyle,
          textAlign: textAlign,
          labels: assessment.labels,
          locale: locale,
        ),
        if (assessment.labels.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          for (final label in assessment.labels)
            _LinkSafetyChipRow(
              label: label,
              locale: locale,
              onReportPost: onReportPost,
            ),
        ],
      ],
    );
  }
}

LinkSafetyUrlLabel? _labelForUrl(String url, List<LinkSafetyUrlLabel> labels) {
  for (final l in labels) {
    if (l.url == url) return l;
    final a = l.url.replaceFirst(RegExp(r'^https?://'), '');
    final b = url.replaceFirst(RegExp(r'^https?://'), '');
    if (a == b) return l;
  }
  return null;
}

class _LinkifiedText extends StatelessWidget {
  const _LinkifiedText({
    required this.text,
    required this.style,
    required this.labels,
    required this.locale,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final List<LinkSafetyUrlLabel> labels;
  final String locale;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final urlStyle = style.copyWith(
      color: AppColors.cyanGlow,
      decoration: TextDecoration.underline,
    );
    final spans = <InlineSpan>[];
    var index = 0;
    final urlPattern = RegExp(
      r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    for (final match in urlPattern.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }
      var url = match.group(0)!;
      while (url.endsWith('.') || url.endsWith(',') || url.endsWith(')')) {
        url = url.substring(0, url.length - 1);
      }
      final label = _labelForUrl(url, labels);
      spans.add(
        TextSpan(
          text: match.group(0),
          style: urlStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () => LinkSafetySheets.openUrlWithSafety(
                  context: context,
                  locale: locale,
                  url: url,
                  label: label,
                ),
        ),
      );
      index = match.end;
    }
    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }

    if (spans.isEmpty) {
      return Text(text, style: style, textAlign: textAlign);
    }

    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(style: style, children: spans),
    );
  }
}

class _LinkSafetyChipRow extends StatelessWidget {
  const _LinkSafetyChipRow({
    required this.label,
    required this.locale,
    this.onReportPost,
  });

  final LinkSafetyUrlLabel label;
  final String locale;
  final VoidCallback? onReportPost;

  @override
  Widget build(BuildContext context) {
    final org = label.officialOrganisationName ?? '';
    final chipText = switch (label.type) {
      LinkSafetyLabelType.lookalikeOfficial => LinkSafetyStrings.format(
          'ls_label_lookalike',
          locale,
          params: {'org': org},
        ),
      LinkSafetyLabelType.shortenedLink =>
        LinkSafetyStrings.t('ls_label_shortener', locale),
      LinkSafetyLabelType.apkLink =>
        LinkSafetyStrings.t('ls_label_apk', locale),
      LinkSafetyLabelType.paymentLinkInChat =>
        LinkSafetyStrings.t('ls_label_payment_chat', locale),
    };

    final chipColor = label.isConcern ? AppColors.warning : AppColors.info;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: chipColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              chipText,
              style: AppTypography.caption.copyWith(color: chipColor),
            ),
          ),
          TextButton(
            onPressed: () => LinkSafetySheets.showWhy(
              context: context,
              locale: locale,
              label: label,
              onReportPost: onReportPost,
            ),
            child: Text(LinkSafetyStrings.t('ls_why', locale)),
          ),
          if (label.type == LinkSafetyLabelType.shortenedLink)
            TextButton(
              onPressed: () =>
                  LinkSafetySheets.openCheckLink(context, label.url),
              child: Text(LinkSafetyStrings.t('ls_check_link', locale)),
            ),
        ],
      ),
    );
  }
}
