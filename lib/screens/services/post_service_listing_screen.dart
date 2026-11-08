import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/data/service_taxonomy.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/firebase_service.dart';

class PostServiceListingScreen extends ConsumerStatefulWidget {
  const PostServiceListingScreen({
    super.key,
    this.categoryId,
    this.serviceName,
  });

  final String? categoryId;
  final String? serviceName;

  @override
  ConsumerState<PostServiceListingScreen> createState() =>
      _PostServiceListingScreenState();
}

class _PostServiceListingScreenState extends ConsumerState<PostServiceListingScreen>
    with DraftPersistenceMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _picker = ImagePicker();

  late String _categoryId;
  late String _serviceName;
  File? _photoFile;
  bool _submitting = false;
  bool _posted = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId ?? kServiceCategories.first.id;
    _serviceName = widget.serviceName ??
        kServiceCategories.first.subServices.first;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _prefillFromProfile();
      await setupDraftPersistence(
        formId: DraftBoxKeys.serviceListingPost,
        controllers: [
          _titleController,
          _descriptionController,
          _nameController,
          _phoneController,
          _areaController,
        ],
        serialize: _serializeDraft,
        applyDraft: _applyDraft,
      );
    });
  }

  Map<String, dynamic> _serializeDraft() => {
        'categoryId': _categoryId,
        'serviceName': _serviceName,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'area': _areaController.text,
      };

  void _applyDraft(Map<String, dynamic> data) {
    setState(() {
      _categoryId = data['categoryId']?.toString() ?? _categoryId;
      _serviceName = data['serviceName']?.toString() ?? _serviceName;
    });
    _titleController.text = data['title']?.toString() ?? '';
    _descriptionController.text = data['description']?.toString() ?? '';
    _nameController.text = data['name']?.toString() ?? '';
    _phoneController.text = data['phone']?.toString() ?? '';
    _areaController.text = data['area']?.toString() ?? '';
  }

  Future<void> _prefillFromProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _nameController.text = user.displayName?.trim() ?? '';

    UserAIProfile? profile = ref.read(userAIProfileProvider);
    if (UserProfileOwnership.needsInit(profile, user.uid)) {
      await ref.read(userAIProfileProvider.notifier).initProfile(user.uid);
      profile = ref.read(userAIProfileProvider);
    }
    if (profile != null && profile.uid != user.uid) {
      profile = null;
    }
    if (profile != null && profile.preferredArea.trim().isNotEmpty) {
      _areaController.text = profile.preferredArea.trim();
    }

    if (FirebaseService.isReady) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final phone = snap.data()?['phone']?.toString().trim();
        if (phone != null && phone.isNotEmpty) {
          _phoneController.text = phone;
        }
      } catch (_) {}
    }
    _phoneController.text =
        _phoneController.text.isEmpty ? (user.phoneNumber ?? '') : _phoneController.text;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _photoFile = File(picked.path));
    notifyDraftChanged();
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(userLanguageProvider);
          return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(ServicesStrings.t('photo_camera', locale)),
              onTap: () {
                Navigator.pop(context);
                unawaited(_pickPhoto(ImageSource.camera));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(ServicesStrings.t('photo_gallery', locale)),
              onTap: () {
                Navigator.pop(context);
                unawaited(_pickPhoto(ImageSource.gallery));
              },
            ),
          ],
        ),
      );
        },
      ),
    );
  }

  Future<void> _submit() async {
    // Snapshot at submit tap — validation/submit feedback matches locale when posted.
    final locale = ref.read(userLanguageProvider);
    if (!_formKey.currentState!.validate()) return;

    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ServicesStrings.t('validation_photo', locale))),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ServicesStrings.t('sign_in_required', locale))),
      );
      return;
    }

    final category = findServiceCategoryById(_categoryId);
    if (category == null) return;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(serviceListingsRepositoryProvider);
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrl = await repo.uploadListingPhoto(
        file: _photoFile!,
        uid: user.uid,
        listingId: tempId,
      );

      final submission = ServiceListingSubmission(
        userId: user.uid,
        serviceCategoryId: category.id,
        serviceCategory: category.name,
        serviceName: _serviceName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        providerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        area: _areaController.text.trim(),
        imageUrl: imageUrl,
      );

      await repo.createListing(submission);
      await clearFormDraft();
      ref.invalidate(userServiceListingsProvider(user.uid));
      ref.invalidate(recentServiceListingsProvider);

      if (mounted) {
        setState(() {
          _submitting = false;
          _posted = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ServicesStrings.t('submit_error', locale))),
        );
      }
    }
  }

  @override
  void dispose() {
    disposeDraftMixin();
    _titleController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final category = findServiceCategoryById(_categoryId);

    if (_posted) {
      return GlassScreenScaffold(
        title: ServicesStrings.t('post_success_title', locale),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 72),
              const SizedBox(height: AppSpacing.xl),
              Text(
                ServicesStrings.t('post_success_title', locale),
                style: AppTypography.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ServicesStrings.t('post_success_body', locale),
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              GlassPrimaryButton(
                label: ServicesStrings.t('my_listings', locale),
                expand: true,
                onPressed: () => context.go('/services/my-listings'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.go('/services'),
                child: Text(ServicesStrings.t('back_to_services', locale)),
              ),
            ],
          ),
        ),
      );
    }

    if (category == null) {
      return GlassScreenScaffold(
        title: ServicesStrings.t('post_listing', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(child: Text(ServicesStrings.t('no_results', locale))),
      );
    }

    return GlassScreenScaffold(
      title: ServicesStrings.t('post_listing', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back,
        onPressed: () => Navigator.of(context).pop(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            if (draftRestoreBanner != null) ...[
              draftRestoreBanner!,
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              ServicesStrings.t('photo_hint', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _showPhotoOptions,
              child: GlassCard(
                borderRadius: AppSpacing.radiusLg,
                padding: EdgeInsets.zero,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _photoFile != null
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          child: Image.file(_photoFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              size: 40,
                              color: AppColors.cyanGlow,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              ServicesStrings.t('add_photo', locale),
                              style: AppTypography.subtitle.copyWith(
                                color: AppColors.cyanGlow,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DropdownField<String>(
              label: ServicesStrings.t('field_category', locale),
              value: _categoryId,
              items: kServiceCategories
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _categoryId = value;
                  final cat = findServiceCategoryById(value)!;
                  if (!cat.subServices.contains(_serviceName)) {
                    _serviceName = cat.subServices.first;
                  }
                });
                notifyDraftChanged();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _DropdownField<String>(
              label: ServicesStrings.t('field_service_type', locale),
              value: _serviceName,
              items: category.subServices
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _serviceName = value);
                notifyDraftChanged();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _FormField(
              label: ServicesStrings.t('field_title', locale),
              controller: _titleController,
              hint: _serviceName,
            ),
            const SizedBox(height: AppSpacing.md),
            _FormField(
              label: ServicesStrings.t('field_description', locale),
              controller: _descriptionController,
              maxLines: 4,
              validator: (v) => v == null || v.trim().length < 10
                  ? ServicesStrings.t('validation_description', locale)
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _FormField(
              label: ServicesStrings.t('field_name', locale),
              controller: _nameController,
              validator: (v) => v == null || v.trim().isEmpty
                  ? ServicesStrings.t('validation_name', locale)
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _FormField(
              label: ServicesStrings.t('field_phone', locale),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().length < 7
                  ? ServicesStrings.t('validation_phone', locale)
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _FormField(
              label: ServicesStrings.t('field_area', locale),
              controller: _areaController,
              validator: (v) => v == null || v.trim().isEmpty
                  ? ServicesStrings.t('validation_area', locale)
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            GlassPrimaryButton(
              label: _submitting
                  ? '${ServicesStrings.t('publish_listing', locale)}…'
                  : ServicesStrings.t('publish_listing', locale),
              expand: true,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          borderRadius: AppSpacing.radiusMd,
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          borderRadius: AppSpacing.radiusMd,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
