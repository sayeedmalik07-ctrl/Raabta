import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/tenancy/data/tenancy_condition_room_suggestions.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_condition_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

/// Room-by-room move-in / move-out photo capture.
class TenancyConditionCaptureScreen extends ConsumerStatefulWidget {
  const TenancyConditionCaptureScreen({
    super.key,
    required this.recordType,
  });

  final TenancyConditionRecordType recordType;

  @override
  ConsumerState<TenancyConditionCaptureScreen> createState() =>
      _TenancyConditionCaptureScreenState();
}

class _TenancyConditionCaptureScreenState
    extends ConsumerState<TenancyConditionCaptureScreen> {
  final _roomLabelController = TextEditingController();

  @override
  void dispose() {
    _roomLabelController.dispose();
    super.dispose();
  }

  Future<({DateTime capturedAt, TenancyConditionTimestampSource source})>
      _resolveVaultTimestamp(String vaultDocId) async {
    final snap = await FirebaseFirestore.instance
        .collection('scanned_documents')
        .doc(vaultDocId)
        .get();
    final scanDate = snap.data()?['scanDate'];
    if (scanDate is Timestamp) {
      return TenancyConditionPhotoTimestamp.resolve(
        vaultScanDate: scanDate.toDate(),
      );
    }
    return TenancyConditionPhotoTimestamp.resolve(
      deviceFallback: DateTime.now(),
    );
  }

  Future<void> _attachVaultDoc(String vaultDocId) async {
    final resolved = await _resolveVaultTimestamp(vaultDocId);
    if (!mounted) return;
    await ref.read(tenancyConditionCaptureProvider.notifier).attachPendingPhoto(
          vaultDocId,
          resolved.capturedAt,
          timestampSource: resolved.source,
        );
  }

  Future<void> _scanForRoom(int roomIndex) async {
    ref.read(tenancyConditionCaptureProvider.notifier).setPendingPhoto(roomIndex);
    final result = await context.push<Map<String, dynamic>>(
      '/scanner/capture?source=tenancy_condition',
    );
    if (!mounted) return;

    final docId = result?['vaultDocId'] as String?;
    if (docId != null && docId.isNotEmpty) {
      await _attachVaultDoc(docId);
      return;
    }

    await _fallbackAttachLatestVaultDoc();
  }

  Future<void> _fallbackAttachLatestVaultDoc() async {
    final pending = ref.read(tenancyConditionCaptureProvider).pendingRoomIndex;
    if (pending == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .where('category', isEqualTo: 'Property Condition')
        .limit(5)
        .get();
    if (snap.docs.isEmpty || !mounted) return;

    final sorted = snap.docs.toList()
      ..sort((a, b) {
        final aDate = a.data()['scanDate'];
        final bDate = b.data()['scanDate'];
        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }
        return 0;
      });

    await _attachVaultDoc(sorted.first.id);
  }

  Future<void> _save(String locale) async {
    final saved = await ref
        .read(tenancyConditionCaptureProvider.notifier)
        .saveSession(recordType: widget.recordType);
    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TenancyStrings.t('tenancy_condition_saved', locale),
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final capture = ref.watch(tenancyConditionCaptureProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: TenancyStrings.t(widget.recordType.labelKey, locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Text(
                TenancyStrings.t('tenancy_condition_capture_hint', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _roomLabelController,
                decoration: InputDecoration(
                  labelText: TenancyStrings.t(
                    'tenancy_condition_room_label',
                    locale,
                  ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => ref
                    .read(tenancyConditionCaptureProvider.notifier)
                    .setRoomLabel(v),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: TenancyConditionRoomSuggestions.ids.map((id) {
                  final canonical =
                      TenancyConditionRoomSuggestions.canonicalLabel(id);
                  return ActionChip(
                    label: Text(
                      TenancyConditionRoomSuggestions.displayLabel(id, locale),
                    ),
                    onPressed: () {
                      _roomLabelController.text = canonical;
                      ref
                          .read(tenancyConditionCaptureProvider.notifier)
                          .setRoomLabel(canonical);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(tenancyConditionCaptureProvider.notifier).addRoom();
                  _roomLabelController.clear();
                },
                icon: const Icon(Icons.add),
                label: Text(
                  TenancyStrings.t('tenancy_condition_add_room', locale),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  TenancyStrings.t('tenancy_condition_add_timeline', locale),
                ),
                subtitle: Text(
                  TenancyStrings.t('tenancy_condition_add_timeline_sub', locale),
                  style: AppTypography.caption,
                ),
                value: capture.addToTimeline,
                onChanged: ref
                    .read(tenancyConditionCaptureProvider.notifier)
                    .setAddToTimeline,
              ),
              if (capture.error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  capture.error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.errorBright,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < capture.rooms.length; i++)
                _RoomCard(
                  locale: locale,
                  room: capture.rooms[i],
                  roomIndex: i,
                  onScan: () => _scanForRoom(i),
                  onRemove: () => ref
                      .read(tenancyConditionCaptureProvider.notifier)
                      .removeRoom(i),
                  onPhotoNoteChanged: (photoIndex, note) => ref
                      .read(tenancyConditionCaptureProvider.notifier)
                      .updatePhotoNote(i, photoIndex, note),
                ),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: TenancyStrings.t('tenancy_condition_save_session', locale),
                icon: Icons.check_rounded,
                expand: true,
                accentColor: AppColors.chipLease,
                onPressed: capture.isSaving || capture.rooms.isEmpty
                    ? null
                    : () => _save(locale),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.locale,
    required this.room,
    required this.roomIndex,
    required this.onScan,
    required this.onRemove,
    required this.onPhotoNoteChanged,
  });

  final String locale;
  final TenancyConditionRoom room;
  final int roomIndex;
  final VoidCallback onScan;
  final VoidCallback onRemove;
  final void Function(int photoIndex, String note) onPhotoNoteChanged;

  @override
  Widget build(BuildContext context) {
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
                  room.roomLabel,
                  style: AppTypography.title,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
              ),
            ],
          ),
          for (var pi = 0; pi < room.photos.length; pi++) ...[
            const SizedBox(height: AppSpacing.sm),
            _PhotoRow(
              locale: locale,
              photo: room.photos[pi],
              onNoteChanged: (note) => onPhotoNoteChanged(pi, note),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.document_scanner_outlined, size: 18),
            label: Text(
              TenancyStrings.t('tenancy_condition_scan_photo', locale),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.locale,
    required this.photo,
    required this.onNoteChanged,
  });

  final String locale;
  final TenancyConditionPhoto photo;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final captured = photo.capturedAt.toLocal();
    final timeLabel =
        '${captured.year}-${captured.month.toString().padLeft(2, '0')}-'
        '${captured.day.toString().padLeft(2, '0')} '
        '${captured.hour.toString().padLeft(2, '0')}:'
        '${captured.minute.toString().padLeft(2, '0')}';
    final sourceLabel = photo.timestampSource ==
            TenancyConditionTimestampSource.vaultScanDate
        ? TenancyStrings.t('tenancy_condition_photo_time_vault', locale)
        : TenancyStrings.t('tenancy_condition_photo_time_linked', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo, size: 18, color: AppColors.cyanGlow),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                TenancyStrings.format('tenancy_condition_photo_time', locale, {
                  'time': timeLabel,
                }),
                style: AppTypography.caption.copyWith(
                  color: AppColors.cyanGlow,
                ),
              ),
            ),
          ],
        ),
        Text(
          sourceLabel,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: TenancyStrings.t('tenancy_condition_photo_note', locale),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: onNoteChanged,
        ),
      ],
    );
  }
}
