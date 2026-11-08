import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/quick_actions/scanner/repositories/scanned_document_repository.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_booking_import_service.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_booking_import_widget.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_visitor_purpose_selector.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

class TripBookingImportScreen extends ConsumerStatefulWidget {
  const TripBookingImportScreen({super.key});

  @override
  ConsumerState<TripBookingImportScreen> createState() =>
      _TripBookingImportScreenState();
}

class _TripBookingImportScreenState extends ConsumerState<TripBookingImportScreen> {
  BookingConfirmationExtractionResult? _extraction;
  bool _processing = false;
  bool _saving = false;
  String? _sourcePath;
  String? _pdfPath;
  String _ocrText = '';

  TripBookingType _bookingType = TripBookingType.hotel;
  final _destinationController = TextEditingController();
  final _countryController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _providerController = TextEditingController();
  final _guestController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TripVisitorPurpose? _visitorPurpose;
  Map<String, double> _fieldConfidence = const {};

  @override
  void dispose() {
    _destinationController.dispose();
    _countryController.dispose();
    _confirmationController.dispose();
    _providerController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  Future<void> _onDocumentCaptured(
    String ocrText, {
    required String sourcePath,
    String? pdfPath,
  }) async {
    final locale = ref.read(tripPlannerProvider).preferences.locale;
    setState(() {
      _processing = true;
      _extraction = null;
      _sourcePath = sourcePath;
      _pdfPath = pdfPath;
      _ocrText = ocrText;
    });

    try {
      final service = ref.read(documentExtractionServiceProvider);
      final result = await service.extractBookingConfirmationData(ocrText);
      if (!mounted) return;
      _applyExtraction(result);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TripStrings.t('booking_import_process_error', locale)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _applyExtraction(BookingConfirmationExtractionResult result) {
    setState(() {
      _extraction = result;
      _bookingType = result.bookingType ?? TripBookingType.hotel;
      _fieldConfidence = result.fieldConfidence;
      if (result.destinationCity != null) {
        _destinationController.text = result.destinationCity!;
      }
      if (result.destinationCountry != null) {
        _countryController.text = result.destinationCountry!;
      }
      if (result.confirmationNumber != null) {
        _confirmationController.text = result.confirmationNumber!;
      }
      if (result.providerName != null) {
        _providerController.text = result.providerName!;
      }
      if (result.guestName != null) {
        _guestController.text = result.guestName!;
      }
      _startDate = result.startDateTime;
      _endDate = result.endDateTime;
    });
  }

  BookingConfirmationExtractionResult _draftFromForm() {
    return BookingConfirmationExtractionResult(
      bookingType: _bookingType,
      destinationCity: _emptyToNull(_destinationController.text),
      destinationCountry: _emptyToNull(_countryController.text),
      startDateTime: _startDate,
      endDateTime: _endDate,
      confirmationNumber: _emptyToNull(_confirmationController.text),
      providerName: _emptyToNull(_providerController.text),
      guestName: _emptyToNull(_guestController.text),
      confidence: _extraction?.confidence ?? 0.5,
      fieldConfidence: _fieldConfidence,
    );
  }

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _confirmSave() async {
    final locale = ref.read(tripPlannerProvider).preferences.locale;
    if (_visitorPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TripStrings.t('visitor_purpose_required', locale)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final draft = _draftFromForm();
    final basePrefs = ref.read(tripPlannerProvider).preferences;
    final updatedPrefs = TripBookingImportService.preferencesFromExtraction(
      extraction: draft,
      base: basePrefs,
    ).copyWith(
      visitorPurpose: _visitorPurpose,
      kidsFriendly: _visitorPurpose == TripVisitorPurpose.familyWithChildren
          ? true
          : basePrefs.kidsFriendly,
    );

    final overlaps = TripBookingImportService.findOverlappingTrips(
      savedTrips: ref.read(tripPlannerProvider).savedTrips,
      candidate: updatedPrefs,
    );

    String? mergeIntoId;
    if (overlaps.isNotEmpty) {
      final choice = await showDialog<_MergeChoice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(TripStrings.t('booking_import_overlap_title', locale)),
          content: Text(TripStrings.t('booking_import_overlap_body', locale)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, _MergeChoice.newTrip),
              child: Text(TripStrings.t('booking_import_create_new', locale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _MergeChoice.merge),
              child: Text(TripStrings.t('booking_import_merge', locale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _MergeChoice.cancelled),
              child: Text(TripStrings.t('booking_import_cancel', locale)),
            ),
          ],
        ),
      );
      if (!mounted || choice == null || choice == _MergeChoice.cancelled) {
        return;
      }
      if (choice == _MergeChoice.merge) {
        TripPlan target;
        if (overlaps.length == 1) {
          target = overlaps.first;
        } else {
          final picked = await showDialog<TripPlan>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: Text(TripStrings.t('booking_import_pick_trip', locale)),
              children: overlaps
                  .map(
                    (t) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, t),
                      child: Text('${t.title} (${t.preferences.destination})'),
                    ),
                  )
                  .toList(),
            ),
          );
          if (!mounted || picked == null) return;
          target = picked;
        }
        mergeIntoId = target.id;
      }
    }

    setState(() => _saving = true);
    try {
      final vaultId = await _saveToVault(draft);
      final segment = TripBookingImportService.segmentFromExtraction(
        extraction: draft,
        vaultDocumentId: vaultId,
      );

      final trip = await ref.read(tripPlannerProvider.notifier).applyBookingImport(
            extraction: draft,
            segment: segment,
            updatedPrefs: updatedPrefs,
            mergeIntoTripId: mergeIntoId,
          );

      if (!mounted) return;
      if (trip != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TripStrings.t('booking_import_saved', locale)),
          ),
        );
        context.go('/trip-planner/itinerary/${trip.id}');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TripStrings.t('booking_import_save_failed', locale)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<String?> _saveToVault(BookingConfirmationExtractionResult draft) async {
    final path = _sourcePath;
    if (path == null || !File(path).existsSync()) return null;

    final repo = ref.read(scannedDocumentRepositoryProvider);
    final classification = DocClassificationResult(
      docType: DocType.bookingConfirmation,
      documentNumber: draft.confirmationNumber,
      holderName: draft.guestName,
      confidence: draft.confidence,
    );

    final isPdf = _pdfPath != null || path.toLowerCase().endsWith('.pdf');
    return repo.save(
      ScannedDocumentSaveRequest(
        classification: classification,
        imagePath: isPdf ? path : path,
        ocrText: _ocrText,
        aiSummary: 'Booking confirmation import',
        category: 'Travel',
        tags: const ['Booking Confirmation'],
        pdfPath: isPdf ? (_pdfPath ?? path) : null,
      ),
    );
  }

  bool _isLowConfidence(String field) {
    final c = _fieldConfidence[field];
    if (c == null) return _extraction != null;
    return c < 0.65;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    _visitorPurpose ??= ref.watch(tripPlannerProvider).preferences.visitorPurpose;
    final showReview = _extraction != null && !_processing;

    return GlassScreenScaffold(
      title: TripStrings.t('booking_import_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            child: Text(
              TripStrings.t('booking_import_disclaimer', locale),
              style: AppTypography.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TripBookingImportWidget(
            locale: locale,
            isProcessing: _processing,
            onOcrText: _onDocumentCaptured,
          ),
          if (showReview) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              TripStrings.t('booking_import_review_title', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              TripStrings.t('booking_import_review_hint', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            TripVisitorPurposeSelector(
              locale: locale,
              selected: _visitorPurpose,
              onSelected: (p) => setState(() => _visitorPurpose = p),
            ),
            const SizedBox(height: AppSpacing.md),
            _ReviewField(
              label: TripStrings.t('booking_import_type', locale),
              lowConfidence: _isLowConfidence('bookingType'),
              child: DropdownButtonFormField<TripBookingType>(
                initialValue: _bookingType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: TripBookingType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_bookingTypeLabel(t, locale)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _bookingType = v);
                },
              ),
            ),
            _ReviewField(
              label: TripStrings.t('booking_import_destination', locale),
              lowConfidence: _isLowConfidence('destinationCity'),
              child: GlassTextField(
                controller: _destinationController,
                hint: TripStrings.t('booking_import_destination_hint', locale),
              ),
            ),
            _ReviewField(
              label: TripStrings.t('booking_import_country', locale),
              lowConfidence: _isLowConfidence('destinationCountry'),
              child: GlassTextField(
                controller: _countryController,
                hint: TripStrings.t('booking_import_country_hint', locale),
              ),
            ),
            _ReviewField(
              label: TripStrings.t('booking_import_start', locale),
              lowConfidence: _isLowConfidence('startDateTime'),
              child: _DateRow(
                date: _startDate,
                locale: locale,
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            _ReviewField(
              label: TripStrings.t('booking_import_end', locale),
              lowConfidence: _isLowConfidence('endDateTime'),
              child: _DateRow(
                date: _endDate,
                locale: locale,
                onTap: () => _pickDate(isStart: false),
              ),
            ),
            _ReviewField(
              label: TripStrings.t('booking_import_confirmation', locale),
              lowConfidence: _isLowConfidence('confirmationNumber'),
              child: GlassTextField(
                controller: _confirmationController,
                hint: TripStrings.t('booking_import_confirmation_hint', locale),
              ),
            ),
            _ReviewField(
              label: TripStrings.t('booking_import_provider', locale),
              lowConfidence: _isLowConfidence('providerName'),
              child: GlassTextField(
                controller: _providerController,
                hint: TripStrings.t('booking_import_provider_hint', locale),
              ),
            ),
            _ReviewField(
              label: TripStrings.t('booking_import_guest', locale),
              lowConfidence: _isLowConfidence('guestName'),
              child: GlassTextField(
                controller: _guestController,
                hint: TripStrings.t('booking_import_guest_hint', locale),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: TripStrings.t('booking_import_confirm', locale),
              icon: Icons.check_circle_outline,
              expand: true,
              accentColor: AppColors.chipTrip,
              onPressed: _saving ? null : _confirmSave,
            ),
          ],
        ],
      ),
    );
  }

  String _bookingTypeLabel(TripBookingType type, String locale) {
    return switch (type) {
      TripBookingType.flight =>
        TripStrings.t('booking_import_type_flight', locale),
      TripBookingType.hotel =>
        TripStrings.t('booking_import_type_hotel', locale),
      TripBookingType.carRental =>
        TripStrings.t('booking_import_type_car', locale),
    };
  }
}

enum _MergeChoice { merge, newTrip, cancelled }

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.label,
    required this.child,
    this.lowConfidence = false,
  });

  final String label;
  final Widget child;
  final bool lowConfidence;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: AppTypography.caption),
              ),
              if (lowConfidence)
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.accentGold,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.date,
    required this.locale,
    required this.onTap,
  });

  final DateTime? date;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = date == null
        ? TripStrings.t('booking_import_date_empty', locale)
        : DateFormat.yMMMd().format(date!);

    return OutlinedButton(
      onPressed: onTap,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label),
      ),
    );
  }
}
