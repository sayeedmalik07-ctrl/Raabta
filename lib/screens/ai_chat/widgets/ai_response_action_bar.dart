import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/services/ai/ai_chat_response_parser.dart';
import 'package:raabta/services/ai/ai_chat_route_validator.dart';

class AiResponseActionBar extends StatelessWidget {
  const AiResponseActionBar({
    super.key,
    required this.actions,
    required this.citations,
  });

  final List<AiChatAction> actions;
  final List<AiChatCitation> citations;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty && citations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, left: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (citations.isNotEmpty)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: citations
                  .map(
                    (c) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.amberGlow.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(
                          color: AppColors.amberGlow.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 12,
                            color: AppColors.amberGlow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            c.label,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (actions.isNotEmpty) ...[
            if (citations.isNotEmpty) const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: actions
                  .map(
                    (action) => ActionChip(
                      label: Text(
                        action.label,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.cyanGlow,
                        ),
                      ),
                      backgroundColor:
                          AppColors.cyanGlow.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: AppColors.cyanGlow.withValues(alpha: 0.35),
                      ),
                      onPressed: () {
                        final route = AiChatRouteValidator.validate(
                          action.route,
                        );
                        if (route == null) return;
                        context.push(route);
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
