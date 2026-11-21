import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';
import 'package:raabta/screens/profile/support_ticket_service.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _service = SupportTicketService();
  final _picker = ImagePicker();

  String _category = SupportTicketService.issueCategories.first;
  File? _screenshot;
  bool _submitting = false;
  bool _submitted = false;
  String? _ticketId;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _screenshot = File(file.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final locale = ref.read(userLanguageProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ProfileStrings.t('report_issue_sign_in', locale)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final id = await _service.submit(
        userId: user.uid,
        category: _category,
        description: _descriptionCtrl.text,
        screenshot: _screenshot,
        locale: locale,
      );
      if (!mounted) return;
      setState(() {
        _submitted = true;
        _ticketId = id;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProfileStrings.format(
              'report_issue_submit_failed',
              locale,
              params: {'error': '$e'},
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    return ProfileTabScaffold(
      child: GlassScreenScaffold(
        title: ProfileStrings.t('settings_report_issue', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: _submitted ? _buildConfirmation(locale) : _buildForm(locale),
      ),
    );
  }

  Widget _buildConfirmation(String locale) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.emeraldGlow, size: 56),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ProfileStrings.t('report_issue_thank_you', locale),
              style: AppTypography.headline2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ProfileStrings.t('report_issue_confirmation_body', locale),
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            if (_ticketId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                ProfileStrings.format(
                  'report_issue_reference',
                  locale,
                  params: {'id': _ticketId!.substring(0, 8)},
                ),
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            GlassPrimaryButton(
              label: ProfileStrings.t('report_issue_done', locale),
              onPressed: () => context.pop(),
              expand: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(String locale) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Text(
            ProfileStrings.t('report_issue_intro', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ProfileStrings.t('report_issue_category', locale),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  items: SupportTicketService.issueCategories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            SupportTicketService.categoryLabel(c, locale),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  ProfileStrings.t('report_issue_description', locale),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 6,
                  validator: (v) =>
                      (v == null || v.trim().length < 10)
                          ? ProfileStrings.t(
                              'report_issue_validation_min_chars',
                              locale,
                            )
                          : null,
                  decoration: InputDecoration(
                    hintText: ProfileStrings.t('report_issue_hint', locale),
                    filled: true,
                    fillColor: AppColors.surface.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  ProfileStrings.t('report_issue_screenshot_optional', locale),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _pickScreenshot,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _screenshot == null
                        ? ProfileStrings.t('report_issue_attach_screenshot', locale)
                        : ProfileStrings.t('report_issue_change_screenshot', locale),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyanGlow,
                    side: BorderSide(color: AppColors.cyanGlow),
                  ),
                ),
                if (_screenshot != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Image.file(
                      _screenshot!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassPrimaryButton(
            label: _submitting
                ? ProfileStrings.t('report_issue_submitting', locale)
                : ProfileStrings.t('report_issue_submit', locale),
            onPressed: _submitting ? null : _submit,
            expand: true,
            icon: Icons.send_outlined,
          ),
        ],
      ),
    );
  }
}
