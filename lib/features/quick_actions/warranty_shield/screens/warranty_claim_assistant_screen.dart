import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/qatar_warranty_retailers.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/widgets/retailer_contact_card.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/features/quick_actions/warranty_shield/services/warranty_claim_ai_service.dart';
import 'package:raabta/features/quick_actions/warranty_shield/services/warranty_claim_pdf_service.dart';
import 'package:raabta/features/quick_actions/warranty_shield/widgets/warranty_disclaimer_banner.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:share_plus/share_plus.dart';

class WarrantyClaimAssistantScreen extends ConsumerStatefulWidget {
  const WarrantyClaimAssistantScreen({
    super.key,
    required this.item,
    this.expiredAcknowledged = false,
  });

  final WarrantyItem item;
  final bool expiredAcknowledged;

  @override
  ConsumerState<WarrantyClaimAssistantScreen> createState() =>
      _WarrantyClaimAssistantScreenState();
}

class _WarrantyClaimAssistantScreenState
    extends ConsumerState<WarrantyClaimAssistantScreen> {
  final _issueController = TextEditingController();
  final _draftController = TextEditingController();
  final _picker = ImagePicker();
  String? _faultPhotoPath;
  bool _isDrafting = false;
  bool _isExporting = false;
  bool _hasDraft = false;

  @override
  void dispose() {
    _issueController.dispose();
    _draftController.dispose();
    super.dispose();
  }

  Future<void> _attachFaultPhoto(String locale) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _faultPhotoPath = picked.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            WarrantyStrings.format(
              'warr_snack_picker_failed',
              locale,
              params: {'error': e.toString()},
            ),
          ),
        ),
      );
    }
  }

  Future<void> _generateDraft(String locale) async {
    if (_issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            WarrantyStrings.t('warr_claim_issue_required', locale),
          ),
        ),
      );
      return;
    }

    setState(() => _isDrafting = true);
    try {
      final ai = ref.read(warrantyClaimAiServiceProvider);
      final letter = await ai.draftClaimLetter(
        item: widget.item,
        issueDescription: _issueController.text.trim(),
        locale: locale,
        hasFaultPhoto: _faultPhotoPath != null,
        warrantyExpired:
            widget.item.isExpired || widget.expiredAcknowledged,
      );
      if (!mounted) return;
      setState(() {
        _draftController.text = letter;
        _hasDraft = letter.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            WarrantyStrings.format(
              'warr_claim_draft_failed',
              locale,
              params: {'error': e.toString()},
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDrafting = false);
    }
  }

  Future<void> _shareDraft(String locale) async {
    final text = _draftController.text.trim();
    if (text.isEmpty) return;
    await Share.share(
      text,
      subject: WarrantyStrings.format(
        'warr_claim_share_subject',
        locale,
        params: {
          'product': WarrantyStrings.displayProductName(
            widget.item.productName,
            locale,
          ),
        },
      ),
    );
  }

  Future<void> _exportPdf(String locale) async {
    final text = _draftController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isExporting = true);
    try {
      final pdf = ref.read(warrantyClaimPdfServiceProvider);
      final file = await pdf.generateLetter(
        item: widget.item,
        draftLetter: text,
        locale: locale,
      );
      await pdf.sharePdf(file, locale);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final showExpiredBanner =
        widget.item.isExpired || widget.expiredAcknowledged;
    final matchedRetailer =
        QatarWarrantyRetailerCatalog.matchForItem(widget.item);

    return GlassScreenScaffold(
      title: WarrantyStrings.t('warr_claim_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _isDrafting ? null : () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          WarrantyDisclaimerBanner(locale: locale),
          const SizedBox(height: AppSpacing.sm),
          Text(
            WarrantyStrings.t('warr_claim_ai_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (showExpiredBanner) ...[
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: AppColors.errorBright,
              backgroundColor: AppColors.errorBright.withValues(alpha: 0.08),
              child: Text(
                WarrantyStrings.t('warr_claim_expired_banner', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.errorBright,
                ),
              ),
            ),
          ],
          if (matchedRetailer != null) ...[
            const SizedBox(height: AppSpacing.md),
            RetailerContactCard(
              retailer: matchedRetailer,
              item: widget.item,
              locale: locale,
              onFileClaim: () {},
              showClaimCta: false,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            WarrantyStrings.format(
              'warr_claim_product_heading',
              locale,
              params: {
                'product': WarrantyStrings.displayProductName(
                  widget.item.productName,
                  locale,
                ),
              },
            ),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _issueController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: WarrantyStrings.t('warr_claim_issue_hint', locale),
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _isDrafting
                ? null
                : () => _attachFaultPhoto(locale),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(
              _faultPhotoPath == null
                  ? WarrantyStrings.t('warr_claim_attach_photo', locale)
                  : WarrantyStrings.t('warr_claim_photo_attached', locale),
            ),
          ),
          if (_faultPhotoPath != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_faultPhotoPath!),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: WarrantyStrings.t('warr_claim_generate', locale),
            icon: Icons.auto_awesome,
            expand: true,
            accentColor: AppColors.successBright,
            onPressed: _isDrafting ? null : () => _generateDraft(locale),
          ),
          if (_isDrafting) ...[
            const SizedBox(height: AppSpacing.md),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_hasDraft) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              WarrantyStrings.t('warr_claim_draft_label', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _draftController,
              maxLines: 14,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: WarrantyStrings.t('warr_claim_share', locale),
              icon: Icons.ios_share_rounded,
              expand: true,
              onPressed: () => _shareDraft(locale),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassPrimaryButton(
              label: WarrantyStrings.t('warr_claim_export_pdf', locale),
              icon: Icons.picture_as_pdf_outlined,
              expand: true,
              accentColor: AppColors.accentGold,
              onPressed: _isExporting ? null : () => _exportPdf(locale),
            ),
          ],
        ],
      ),
    );
  }
}
