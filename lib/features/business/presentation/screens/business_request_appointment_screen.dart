import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/business/presentation/l10n/business_appointment_strings.dart';
import 'package:raabta/features/business/presentation/widgets/business_appointment_slot_picker.dart';
import 'package:raabta/features/business/providers/business_structured_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class BusinessRequestAppointmentScreen extends ConsumerStatefulWidget {
  const BusinessRequestAppointmentScreen({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  final String businessId;
  final String businessName;

  @override
  ConsumerState<BusinessRequestAppointmentScreen> createState() =>
      _BusinessRequestAppointmentScreenState();
}

class _BusinessRequestAppointmentScreenState
    extends ConsumerState<BusinessRequestAppointmentScreen> {
  final _slotController = BusinessAppointmentSlotPickerController();
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
      setState(() => _errorKey = 'biz_appt_invalid_slots');
      return;
    }

    setState(() {
      _busy = true;
      _errorKey = null;
    });

    try {
      final request = await ref
          .read(businessAppointmentRepositoryProvider)
          .createRequest(
            businessId: widget.businessId,
            proposedSlots: slots,
            businessName: widget.businessName,
            note: _noteController.text.trim(),
            locale: locale,
          );

      if (!mounted) return;
      setState(() => _busy = false);

      if (request == null) {
        setState(() => _errorKey = 'biz_appt_open_exists');
        return;
      }
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorKey = 'biz_appt_open_exists';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: BusinessAppointmentStrings.t('biz_appt_request_title', locale),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BusinessAppointmentStrings.t('biz_appt_request_subtitle', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BusinessAppointmentSlotPickerList(
              controller: _slotController,
              locale: locale,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText:
                    BusinessAppointmentStrings.t('biz_appt_note_label', locale),
              ),
              maxLines: 3,
            ),
            if (_errorKey != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                BusinessAppointmentStrings.t(_errorKey!, locale),
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const Spacer(),
            GlassPrimaryButton(
              onPressed: _busy ? null : () => _submit(locale),
              label: BusinessAppointmentStrings.t('biz_appt_submit', locale),
            ),
          ],
        ),
      ),
    );
  }
}
