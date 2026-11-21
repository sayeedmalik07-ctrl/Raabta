import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/theme/raabta_date_picker.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

class DocConfirmSheet extends StatefulWidget {
  const DocConfirmSheet({
    super.key,
    required this.result,
    required this.onConfirm,
  });

  final DocClassificationResult result;
  final void Function(DocClassificationResult edited, bool addReminder)
      onConfirm;

  static Future<void> show(
    BuildContext context,
    DocClassificationResult result,
    void Function(DocClassificationResult edited, bool addReminder) onConfirm,
  ) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.isLight
          ? AppColors.surfaceElevated
          : const Color(0xFF1A1035),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DocConfirmSheet(
        result: result,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<DocConfirmSheet> createState() => _DocConfirmSheetState();
}

class _DocConfirmSheetState extends State<DocConfirmSheet> {
  late TextEditingController _numberCtrl;
  late TextEditingController _nameCtrl;
  late DateTime? _expiryDate;
  late DocType _docType;
  bool _addReminder = true;

  final _docTypeLabels = {
    DocType.qid: 'Qatar ID (QID)',
    DocType.passport: 'Passport',
    DocType.visa: 'Visa',
    DocType.labourCard: 'Labour Card',
    DocType.drivingLicense: 'Driving License',
    DocType.receipt: 'Receipt',
    DocType.bill: 'Bill',
    DocType.labReport: 'Lab Report',
    DocType.prescription: 'Prescription',
    DocType.medicalCertificate: 'Medical Certificate',
    DocType.vaccinationRecord: 'Vaccination Record',
    DocType.healthInsurance: 'Health Insurance Card',
    DocType.healthInsuranceClaim: 'Health Insurance Claim Document',
    DocType.imagingReport: 'Imaging Report (X-Ray/MRI/CT/ECG)',
    DocType.unknown: 'Unknown Document',
  };

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController(
      text: widget.result.documentNumber ?? '',
    );
    _nameCtrl = TextEditingController(
      text: widget.result.holderName ?? '',
    );
    _expiryDate = widget.result.expiryDate;
    _docType = widget.result.docType;
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLowConfidence = widget.result.confidence < 0.5;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Confirm Document Details',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Review the AI-detected details before saving',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            if (isLowConfidence) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.accentGold,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low confidence detection. Please verify all fields.',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const _FieldLabel('Document Type'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.isLight
                    ? AppColors.glassSurface
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DocType>(
                  value: _docType,
                  isExpanded: true,
                  dropdownColor: AppColors.isLight
                      ? AppColors.surfaceElevated
                      : const Color(0xFF1A1035),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontSize: 14,
                  ),
                  items: _docTypeLabels.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _docType = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Expiry Date'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  builder: raabtaDatePickerThemeBuilder,
                );
                if (picked != null) {
                  setState(() => _expiryDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.isLight
                      ? AppColors.glassSurface
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.sharePurple,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _expiryDate != null
                          ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                          : 'Tap to select date',
                      style: TextStyle(
                        color: _expiryDate != null
                            ? (AppColors.isLight
                                ? AppColors.textPrimary
                                : Colors.white)
                            : (AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white38),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Document Number'),
            const SizedBox(height: 6),
            TextField(
              controller: _numberCtrl,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
              ),
              decoration: _inputDecoration('e.g. 28912345678'),
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Holder Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
              ),
              decoration: _inputDecoration('Full name on document'),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.successBright.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successBright.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.successBright,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Remind me before expiry',
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Switch(
                    value: _addReminder,
                    activeTrackColor: AppColors.successBright,
                    onChanged: (v) => setState(() => _addReminder = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final edited = DocClassificationResult(
                    docType: _docType,
                    expiryDate: _expiryDate,
                    documentNumber: _numberCtrl.text.trim(),
                    holderName: _nameCtrl.text.trim(),
                    confidence: widget.result.confidence,
                  );
                  Navigator.pop(context);
                  widget.onConfirm(edited, _addReminder);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sharePurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.isLight
            ? AppColors.textOnGlassMuted
            : Colors.white.withValues(alpha: 0.25),
        fontSize: 13,
      ),
      fillColor: AppColors.isLight
          ? AppColors.glassSurface
          : Colors.white.withValues(alpha: 0.06),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.isLight
            ? AppColors.textOnGlassSecondary
            : Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
