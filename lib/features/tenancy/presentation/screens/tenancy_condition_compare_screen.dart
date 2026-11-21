import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_condition_room_matcher.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_condition_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

/// Side-by-side move-in vs move-out comparison — human review only, no AI.
class TenancyConditionCompareScreen extends ConsumerStatefulWidget {
  const TenancyConditionCompareScreen({super.key});

  @override
  ConsumerState<TenancyConditionCompareScreen> createState() =>
      _TenancyConditionCompareScreenState();
}

class _TenancyConditionCompareScreenState
    extends ConsumerState<TenancyConditionCompareScreen> {
  final _noteControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key, String initial) {
    return _noteControllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  Future<void> _saveNotes(
    TenancyConditionRecord moveOut,
    Map<String, String> notes,
  ) async {
    final repo = await ref.read(tenancyConditionRepositoryProvider.future);
    await repo.updateComparisonNotes(
      moveOutRecord: moveOut,
      notes: notes,
    );
    ref.invalidate(tenancyConditionRecordsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TenancyStrings.t(
              'tenancy_condition_notes_saved',
              ref.read(tenancyLocaleProvider).valueOrNull ?? 'English',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final recordsAsync = ref.watch(tenancyConditionRecordsProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_condition_compare_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => GlassEmptyState(
              icon: Icons.compare_outlined,
              title: TenancyStrings.t('tenancy_condition_compare_need_both', locale),
              description: TenancyStrings.t('tenancy_condition_compare_hint', locale),
            ),
            data: (records) {
              final moveIn = _latestOfType(
                records,
                TenancyConditionRecordType.moveIn,
              );
              final moveOut = _latestOfType(
                records,
                TenancyConditionRecordType.moveOut,
              );

              if (moveIn == null || moveOut == null) {
                return GlassEmptyState(
                  icon: Icons.compare_outlined,
                  title: TenancyStrings.t(
                    'tenancy_condition_compare_need_both',
                    locale,
                  ),
                  description: TenancyStrings.t(
                    'tenancy_condition_compare_hint',
                    locale,
                  ),
                );
              }

              final comparisons = TenancyConditionRoomMatcher.compare(
                moveInRooms: moveIn.rooms,
                moveOutRooms: moveOut.rooms,
              );

              return ListView(
                children: [
                  TenancyDisclaimerBanner(locale: locale),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    TenancyStrings.t('tenancy_condition_compare_hint', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final cmp in comparisons)
                    _ComparisonCard(
                      locale: locale,
                      comparison: cmp,
                      noteController: _controllerFor(
                        cmp.displayLabel,
                        moveOut.roomComparisonNotes[cmp.displayLabel] ?? '',
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      final notes = <String, String>{};
                      for (final cmp in comparisons) {
                        final text =
                            _controllerFor(cmp.displayLabel, '').text.trim();
                        if (text.isNotEmpty) {
                          notes[cmp.displayLabel] = text;
                        }
                      }
                      _saveNotes(moveOut, notes);
                    },
                    child: Text(
                      TenancyStrings.t('tenancy_condition_save_notes', locale),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.locale,
    required this.comparison,
    required this.noteController,
  });

  final String locale;
  final TenancyConditionRoomComparison comparison;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 500;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comparison.displayLabel,
                  style: AppTypography.title,
                ),
              ),
              if (comparison.unmatchedMoveOut)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    TenancyStrings.t('tenancy_condition_unmatched', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (narrow)
            Column(
              children: [
                _PhotoColumn(
                  locale: locale,
                  title: TenancyStrings.t('tenancy_condition_move_in', locale),
                  room: comparison.moveInRoom,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PhotoColumn(
                  locale: locale,
                  title: TenancyStrings.t('tenancy_condition_move_out', locale),
                  room: comparison.moveOutRoom,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PhotoColumn(
                    locale: locale,
                    title:
                        TenancyStrings.t('tenancy_condition_move_in', locale),
                    room: comparison.moveInRoom,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PhotoColumn(
                    locale: locale,
                    title:
                        TenancyStrings.t('tenancy_condition_move_out', locale),
                    room: comparison.moveOutRoom,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: TenancyStrings.t(
                'tenancy_condition_comparison_note',
                locale,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoColumn extends StatelessWidget {
  const _PhotoColumn({
    required this.locale,
    required this.title,
    required this.room,
  });

  final String locale;
  final String title;
  final TenancyConditionRoom? room;

  @override
  Widget build(BuildContext context) {
    if (room == null || room!.photos.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.bodySmall),
          Text(
            TenancyStrings.t('tenancy_condition_no_photos', locale),
            style: AppTypography.caption,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.bodySmall),
        for (final photo in room!.photos) ...[
          const SizedBox(height: 4),
          Text(
            _formatTime(photo.capturedAt),
            style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
          ),
          if (photo.note.isNotEmpty)
            Text(photo.note, style: AppTypography.caption),
          Text(
            TenancyStrings.format('tenancy_condition_vault_ref', locale, {
              'id': photo.photoRef.length > 8
                  ? photo.photoRef.substring(0, 8)
                  : photo.photoRef,
            }),
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

TenancyConditionRecord? _latestOfType(
  List<TenancyConditionRecord> records,
  TenancyConditionRecordType type,
) {
  final matches = records.where((r) => r.recordType == type).toList();
  return matches.isNotEmpty ? matches.last : null;
}
