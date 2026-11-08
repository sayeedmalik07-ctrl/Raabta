import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_context.dart';

class AiContextChipBar extends StatelessWidget {
  const AiContextChipBar({
    super.key,
    required this.context,
    required this.locale,
    this.onDismiss,
  });

  final AiChatContext context;
  final String locale;
  final VoidCallback? onDismiss;

  IconData _iconForSource(AiChatContextSource source) {
    return switch (source) {
      AiChatContextSource.eosb => Icons.account_balance_wallet_outlined,
      AiChatContextSource.visa => Icons.flight_takeoff_outlined,
      AiChatContextSource.vault => Icons.folder_copy_outlined,
      AiChatContextSource.health => Icons.local_hospital_outlined,
      AiChatContextSource.general => Icons.auto_awesome_outlined,
    };
  }

  String? _contextPreview(String? body) {
    final trimmed = body?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final firstLine = trimmed.split('\n').first.trim();
    if (firstLine.isEmpty) return null;
    return firstLine;
  }

  @override
  Widget build(BuildContext context) {
    final chipContext = this.context;
    final preview = _contextPreview(chipContext.body);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.cyanGlow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: AppColors.cyanGlow.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconForSource(chipContext.source),
                    size: 14,
                    color: AppColors.cyanGlow,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      chipContext.label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (preview != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                preview,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AiQuotaBadge extends StatelessWidget {
  const AiQuotaBadge({
    super.key,
    required this.remaining,
    required this.limit,
    required this.locale,
    this.onUpgrade,
  });

  final int remaining;
  final int limit;
  final String locale;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final label = AiChatStrings.t('ai_quota_remaining', locale)
        .replaceAll('{n}', remaining.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.amberGlow,
              ),
            ),
          ),
          if (onUpgrade != null)
            TextButton(
              onPressed: onUpgrade,
              child: Text(
                AiChatStrings.t('ai_quota_upgrade', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.cyanGlow,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
