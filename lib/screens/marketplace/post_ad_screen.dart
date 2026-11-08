import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/utils/community_group_tagging.dart';
import 'package:raabta/features/community/widgets/community_group_tag_selector.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/marketplace_firestore_service.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';

class PostAdScreen extends ConsumerStatefulWidget {
  const PostAdScreen({super.key});

  @override
  ConsumerState<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends ConsumerState<PostAdScreen>
    with DraftPersistenceMixin {
  static final List<String> _categories =
      marketplaceCategories.map((c) => c.name).toList(growable: false);

  static const List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
  ];

  static const List<String> _areas = [
    'Al Khor',
    'Doha',
    'Lusail',
    'Al Wakrah',
    'Mesaieed',
    'Al Rayyan',
  ];

  String _selectedCategory = _categories[0];
  String _selectedCondition = _conditions[0];
  String _selectedArea = _areas[0];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _photoFile;
  bool _submitting = false;
  Set<String> _selectedGroupTags = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await setupDraftPersistence(
        formId: DraftBoxKeys.marketplacePostAd,
        controllers: [
          _titleController,
          _priceController,
          _descriptionController,
        ],
        serialize: () => {
          'title': _titleController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'condition': _selectedCondition,
          'area': _selectedArea,
        },
        applyDraft: (data) {
          _titleController.text = data['title']?.toString() ?? '';
          _priceController.text = data['price']?.toString() ?? '';
          _descriptionController.text = data['description']?.toString() ?? '';
          setState(() {
            _selectedCategory =
                data['category']?.toString() ?? _categories.first;
            _selectedCondition =
                data['condition']?.toString() ?? _conditions.first;
            _selectedArea = data['area']?.toString() ?? _areas.first;
          });
        },
      );
    });
  }

  @override
  void dispose() {
    disposeDraftMixin();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;
    setState(() => _photoFile = File(picked.path));
    notifyDraftChanged();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    );
  }

  Future<void> _onPostAd() async {
    if (_submitting) return;

    final locale = ref.read(userLanguageProvider);
    final title = _titleController.text.trim();
    final priceRaw = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showSnack(MarketplaceStrings.t('mp_err_title_required', locale));
      return;
    }
    final priceQar = int.tryParse(priceRaw);
    if (priceQar == null || priceQar <= 0) {
      _showSnack(MarketplaceStrings.t('mp_err_price_invalid', locale));
      return;
    }
    if (description.isEmpty) {
      _showSnack(MarketplaceStrings.t('mp_err_description_required', locale));
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      _showSnack(MarketplaceStrings.t('mp_err_sign_in_post', locale));
      return;
    }

    if (!FirebaseService.isReady) {
      _showSnack(MarketplaceStrings.t('mp_err_connection', locale));
      return;
    }

    final category = marketplaceCategoryByName(_selectedCategory);
    if (category == null) {
      _showSnack(MarketplaceStrings.t('mp_err_invalid_category', locale));
      return;
    }

    final profile = ref.read(userAIProfileProvider);
    final sellerFlag =
        ProfileDisplayHelper.nationalityFlag(profile?.nationality ?? '');

    setState(() => _submitting = true);
    try {
      final repo = ref.read(marketplaceFirestoreServiceProvider);
      final submission = MarketplaceListingSubmission(
        ownerUserId: user.uid,
        categoryId: category.id,
        title: title,
        priceQar: priceQar,
        description: description,
        condition: _selectedCondition,
        area: _selectedArea,
        sellerFlag: sellerFlag,
        relevantGroupIds:
            CommunityGroupTagging.normalize(_selectedGroupTags.toList()),
      );

      final listingId = await repo.createListing(submission);

      if (_photoFile != null) {
        final photoUrl = await repo.uploadPhoto(
          _photoFile!,
          listingId: listingId,
        );
        await repo.attachPhotos(listingId, [photoUrl]);
      }

      await clearFormDraft();
      ref.invalidate(marketplaceListingsProvider);

      if (!mounted) return;
      _showSnack(MarketplaceStrings.t('mp_success_posted', locale));
      context.pop();
    } on StateError catch (e) {
      if (mounted) _showSnack(e.message);
    } on MarketplaceFirestoreException catch (e) {
      if (mounted) {
        _showSnack(
          MarketplaceStrings.format(
            'mp_err_publish_detail',
            locale,
            params: {'message': e.message},
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnack(MarketplaceStrings.t('mp_err_publish', locale));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      borderRadius: AppSpacing.radiusSm,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textPrimary,
            size: AppSpacing.iconMd,
          ),
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: AppTypography.subtitle.copyWith(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _glassField(
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusSm,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        decoration: _inputDecoration(hint ?? ''),
        onChanged: (_) => notifyDraftChanged(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final joinedGroupIds =
        ref.watch(communityMembershipProvider).value ?? const {};
    final suggestedLabels = ref.watch(suggestedCommunityContentLabelIdsProvider);
    final showTagSelector =
        joinedGroupIds.isNotEmpty || suggestedLabels.isNotEmpty;
    return GlassScreenScaffold(
      title: MarketplaceStrings.t('mp_post_ad', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back_ios_rounded,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: _submitting ? null : () => context.pop(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (draftRestoreBanner != null) draftRestoreBanner!,
            _label(MarketplaceStrings.t('mp_label_category', locale)),
            const SizedBox(height: AppSpacing.sm),
            _buildDropdown(
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
                notifyDraftChanged();
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _label(MarketplaceStrings.t('mp_label_title', locale)),
            const SizedBox(height: AppSpacing.sm),
            _glassField(
              _titleController,
              hint: MarketplaceStrings.t('mp_hint_title', locale),
            ),
            const SizedBox(height: AppSpacing.lg),
            _label(MarketplaceStrings.t('mp_label_price', locale)),
            const SizedBox(height: AppSpacing.sm),
            _glassField(
              _priceController,
              hint: MarketplaceStrings.t('mp_hint_price', locale),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppSpacing.lg),
            _label(MarketplaceStrings.t('mp_label_description', locale)),
            const SizedBox(height: AppSpacing.sm),
            _glassField(
              _descriptionController,
              hint: MarketplaceStrings.t('mp_hint_description', locale),
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            _label(MarketplaceStrings.t('mp_label_condition', locale)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _conditions.map((condition) {
                final isSelected = _selectedCondition == condition;
                return GlassCard(
                  onTap: _submitting
                      ? null
                      : () {
                          setState(() => _selectedCondition = condition);
                          notifyDraftChanged();
                        },
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  borderRadius: AppSpacing.radiusFull,
                  glowColor: isSelected ? AppColors.cyanGlow : null,
                  glowIntensity: isSelected ? 0.2 : 0,
                  child: Text(
                    MarketplaceStrings.conditionLabel(condition, locale),
                    style: AppTypography.chipLabel.copyWith(
                      color: isSelected
                          ? AppColors.cyanGlow
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _label(MarketplaceStrings.t('mp_label_area', locale)),
            const SizedBox(height: AppSpacing.sm),
            _buildDropdown(
              value: _selectedArea,
              items: _areas,
              onChanged: (value) {
                setState(() => _selectedArea = value!);
                notifyDraftChanged();
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: _submitting ? null : _pickPhoto,
              child: GlassContainer(
                width: double.infinity,
                height: 140,
                borderRadius: AppSpacing.radiusSm,
                child: _photoFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: Image.file(
                          _photoFile!,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: AppColors.textSecondary,
                            size: AppSpacing.iconXl + 4,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            MarketplaceStrings.t('mp_add_photos', locale),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
              ),
            ),
            if (showTagSelector) ...[
              const SizedBox(height: AppSpacing.lg),
              CommunityGroupTagSelector(
                joinedGroupIds: joinedGroupIds,
                selectedIds: _selectedGroupTags,
                locale: locale,
                suggestedContentLabelIds: suggestedLabels,
                onChanged: _submitting
                    ? (_) {}
                    : (tags) => setState(() => _selectedGroupTags = tags),
                enabled: !_submitting,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            GlassCard(
              onTap: _submitting ? null : _onPostAd,
              glowColor: AppColors.cyanGlow,
              glowIntensity: 0.25,
              backgroundColor: AppColors.cyanGlow,
              borderRadius: AppSpacing.radiusSm,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: _submitting
                  ? const Center(child: GlassProgressIndicator())
                  : Text(
                      MarketplaceStrings.t('mp_post_free_ad', locale),
                      style: AppTypography.button.copyWith(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
