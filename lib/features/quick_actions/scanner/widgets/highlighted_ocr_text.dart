import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Builds OCR preview text with optional search-term highlighting.
class HighlightedOcrText extends StatelessWidget {
  const HighlightedOcrText({
    super.key,
    required this.text,
    this.query = '',
    this.maxLines,
    this.style,
  });

  final String text;
  final String query;
  final int? maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? AppTypography.bodySmall;
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        style: baseStyle,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmedQuery.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + trimmedQuery.length),
          style: baseStyle.copyWith(
            color: AppColors.cyanGlow,
            fontWeight: FontWeight.w700,
            backgroundColor: AppColors.cyanGlow.withValues(alpha: 0.15),
          ),
        ),
      );
      start = index + trimmedQuery.length;
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}
