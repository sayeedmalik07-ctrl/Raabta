import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';

class CaseTimelineEntryTile extends StatelessWidget {
  const CaseTimelineEntryTile({
    super.key,
    required this.entry,
    required this.locale,
    this.isLast = false,
  });

  final CaseTimelineEntry entry;
  final String locale;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd().format(entry.entryDate);
    final typeLabel = CaseTimelineStrings.t(
      'ct_entry_type_${entry.entryType.storageValue}',
      locale,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.cyanGlow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cyanGlow, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.glassBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateFmt, style: AppTypography.caption),
                    Text(
                      entry.title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(typeLabel, style: AppTypography.caption),
                    if (entry.description != null &&
                        entry.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(entry.description!, style: AppTypography.bodySmall),
                    ],
                    if (entry.linkedDocumentRef != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: () => context.push(
                          '/document-vault/${entry.linkedDocumentRef}',
                        ),
                        child: Text(
                          '📎 ${CaseTimelineStrings.t('ct_attach_document', locale)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.cyanGlow,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
