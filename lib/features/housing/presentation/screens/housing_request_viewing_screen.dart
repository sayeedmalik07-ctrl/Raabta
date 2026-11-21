import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/features/housing/presentation/widgets/housing_viewing_slot_picker.dart';
import 'package:raabta/features/housing/providers/housing_viewing_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class HousingRequestViewingScreen extends ConsumerStatefulWidget {
  const HousingRequestViewingScreen({
    super.key,
    required this.listingId,
    required this.ownerId,
    required this.listingTitle,
  });

  final String listingId;
  final String ownerId;
  final String listingTitle;

  @override
  ConsumerState<HousingRequestViewingScreen> createState() =>
      _HousingRequestViewingScreenState();
}

class _HousingRequestViewingScreenState
    extends ConsumerState<HousingRequestViewingScreen> {
  final _slotController = HousingViewingSlotPickerController();
  final _noteController = TextEditingController();
  String? _errorKey;
  bool _busy = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(String locale) async {
    final slots = _slotController.collectFutureSlots();
    if (slots.isEmpty) {
      setState(() => _errorKey = 'hv_invalid_slots');
      return;
    }

    setState(() {
      _busy = true;
      _errorKey = null;
    });

    final request =
        await ref.read(housingViewingRepositoryProvider).createRequest(
              listingId: widget.listingId,
              ownerId: widget.ownerId,
              proposedSlots: slots,
              listingTitle: widget.listingTitle,
              locale: locale,
              note: _noteController.text.trim(),
            );

    if (!mounted) return;
    setState(() => _busy = false);

    if (request == null) {
      setState(() => _errorKey = 'hv_invalid_slots');
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: HousingViewingStrings.t('hv_request_viewing_title', locale),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              HousingViewingStrings.t('hv_request_viewing_subtitle', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            HousingViewingSlotPickerList(
              controller: _slotController,
              locale: locale,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              HousingViewingStrings.t('hv_note_label', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: HousingViewingStrings.t('hv_note_hint', locale),
                filled: true,
                fillColor: AppColors.surface.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_errorKey != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                HousingViewingStrings.t(_errorKey!, locale),
                style: AppTypography.caption.copyWith(color: AppColors.error),
              ),
            ],
            const Spacer(),
            GlassPrimaryButton(
              label: HousingViewingStrings.t('hv_submit_request', locale),
              onPressed: _busy ? null : () => _submit(locale),
            ),
          ],
        ),
      ),
    );
  }
}
