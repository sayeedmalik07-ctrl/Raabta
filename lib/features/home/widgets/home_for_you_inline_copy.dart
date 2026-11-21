import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Calmer For you rhythm — inline title + body (Batch G). No card chrome.
class HomeForYouInlineCopy extends StatelessWidget {
  const HomeForYouInlineCopy({
    super.key,
    required this.title,
    required this.body,
    this.linkPhrase,
    this.onLinkTap,
    this.onBodyTap,
  });

  final String title;
  final String body;
  final String? linkPhrase;
  final VoidCallback? onLinkTap;
  final VoidCallback? onBodyTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTypography.subtitle.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.textPrimary,
    );
    final bodyStyle = AppTypography.bodySmall.copyWith(
      height: 1.4,
      color: AppColors.textOnGlassMuted,
    );
    final linkStyle = bodyStyle.copyWith(
      color: AppColors.brandFamilyMain,
      fontWeight: FontWeight.w600,
    );

    final bodyWidget = _linkPhraseInBody
        ? _buildLinkedBody(bodyStyle, linkStyle)
        : Text(body, style: bodyStyle);

    Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: AppSpacing.xxs),
        bodyWidget,
      ],
    );

    if (onBodyTap != null && linkPhrase == null) {
      column = GestureDetector(
        onTap: onBodyTap,
        behavior: HitTestBehavior.opaque,
        child: column,
      );
    }

    return column;
  }

  bool get _linkPhraseInBody =>
      linkPhrase != null &&
      linkPhrase!.isNotEmpty &&
      onLinkTap != null &&
      body.contains(linkPhrase!);

  Widget _buildLinkedBody(TextStyle bodyStyle, TextStyle linkStyle) {
    final link = linkPhrase!;
    final index = body.indexOf(link);
    final before = body.substring(0, index);
    final after = body.substring(index + link.length);

    return Text.rich(
      TextSpan(
        style: bodyStyle,
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Semantics(
              link: true,
              button: true,
              label: link,
              child: GestureDetector(
                onTap: onLinkTap,
                child: Text(link, style: linkStyle),
              ),
            ),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }
}