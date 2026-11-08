import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';
import 'package:raabta/screens/housing/post_listing_validation.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/monetization/boost_listing_screen.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/housing_firestore_service.dart';
import 'package:raabta/services/listings_api_service.dart';

class PostListingScreen extends ConsumerStatefulWidget {
  const PostListingScreen({super.key});

  @override
  ConsumerState<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends ConsumerState<PostListingScreen>
    with DraftPersistenceMixin {
  static const List<String> _amenityOptions = [
    'WiFi',
    'AC',
    'Parking',
    'Kitchen',
    'Laundry',
    'Balcony',
    'Gym',
    'Furnished',
  ];

  int _step = 0;
  bool _isSubmitting = false;

  final List<File> _photoFiles = [];
  final List<String> _uploadedPhotoUrls = [];
  final ImagePicker _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bedroomsController = TextEditingController(text: '1');
  final _bathroomsController = TextEditingController(text: '1');
  final _whatsappController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactNameController = TextEditingController();

  ListingType _type = ListingType.room;
  bool _furnished = true;
  String _area = qatarAreas.first;
  GenderPreference _gender = GenderPreference.any;
  NationalityPreference _nationality = NationalityPreference.any;
  final Set<String> _selectedAmenities = {'WiFi', 'AC'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await setupDraftPersistence(
        formId: DraftBoxKeys.housingPostListing,
        controllers: [
          _titleController,
          _priceController,
          _descriptionController,
          _bedroomsController,
          _bathroomsController,
          _whatsappController,
          _phoneController,
          _contactNameController,
        ],
        serialize: _serializeDraft,
        applyDraft: _applyDraft,
      );
    });
  }

  Map<String, dynamic> _serializeDraft() => {
        'step': _step,
        'title': _titleController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'bedrooms': _bedroomsController.text,
        'bathrooms': _bathroomsController.text,
        'whatsapp': _whatsappController.text,
        'phone': _phoneController.text,
        'contactName': _contactNameController.text,
        'type': _type.name,
        'furnished': _furnished,
        'area': _area,
        'gender': _gender.name,
        'nationality': _nationality.name,
        'amenities': _selectedAmenities.toList(),
        'photoPaths': _photoFiles.map((f) => f.path).toList(),
      };

  void _applyDraft(Map<String, dynamic> data) {
    _step = data['step'] as int? ?? _step;
    _titleController.text = data['title']?.toString() ?? '';
    _priceController.text = data['price']?.toString() ?? '';
    _descriptionController.text = data['description']?.toString() ?? '';
    _bedroomsController.text = data['bedrooms']?.toString() ?? '1';
    _bathroomsController.text = data['bathrooms']?.toString() ?? '1';
    _whatsappController.text = data['whatsapp']?.toString() ?? '';
    _phoneController.text = data['phone']?.toString() ?? '';
    _contactNameController.text = data['contactName']?.toString() ?? '';
    _type = ListingType.values.byName(
      data['type']?.toString() ?? ListingType.room.name,
    );
    _furnished = data['furnished'] != false;
    _area = data['area']?.toString() ?? qatarAreas.first;
    _gender = GenderPreference.values.byName(
      data['gender']?.toString() ?? GenderPreference.any.name,
    );
    _nationality = NationalityPreference.values.byName(
      data['nationality']?.toString() ?? NationalityPreference.any.name,
    );
    _selectedAmenities
      ..clear()
      ..addAll(
        (data['amenities'] as List<dynamic>? ?? const ['WiFi', 'AC'])
            .map((e) => e.toString()),
      );
    _photoFiles
      ..clear()
      ..addAll(
        DraftService.filterExistingPaths(data['photoPaths'] as List?)
            .map(File.new),
      );
    setState(() {});
  }

  @override
  void dispose() {
    disposeDraftMixin();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _whatsappController.dispose();
    _phoneController.dispose();
    _contactNameController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) {
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

  Widget _glassField({
    required TextEditingController controller,
    required String hint,
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
        decoration: _decoration(hint),
      ),
    );
  }

  Future<void> _pickPhotos(ImageSource source) async {
    if (source == ImageSource.camera) {
      final photo = await _picker.pickImage(source: source, imageQuality: 80);
      if (photo != null) {
        setState(() => _photoFiles.add(File(photo.path)));
      }
      return;
    }

    final photos = await _picker.pickMultiImage(imageQuality: 80);
    if (photos.isNotEmpty) {
      setState(() => _photoFiles.addAll(photos.map((p) => File(p.path))));
    }
  }

  String? _validateStep(int step, String locale) {
    return validatePostListingStep(
      step: step,
      locale: locale,
      input: PostListingStepInput(
        photoCount: _photoFiles.length,
        title: _titleController.text,
        priceText: _priceController.text,
        description: _descriptionController.text,
        whatsapp: _whatsappController.text,
        contactName: _contactNameController.text,
      ),
    );
  }

  Future<List<String>> _uploadPhotos({required String listingId}) async {
    if (_uploadedPhotoUrls.isNotEmpty) return _uploadedPhotoUrls;

    final urls = <String>[];
    final api = ref.read(listingsApiServiceProvider);
    final storage = HousingFirestoreService();

    for (final file in _photoFiles) {
      try {
        if (FirebaseService.isReady) {
          final url = await storage.uploadPhoto(file, listingId: listingId);
          urls.add(url);
        } else {
          final url = await api.uploadPhoto(file);
          urls.add(url);
        }
      } catch (_) {
        // Skip failed uploads — never substitute placeholder URLs.
      }
    }

    _uploadedPhotoUrls.addAll(urls);
    return urls;
  }

  Future<void> _submit() async {
    // Snapshot at submit tap — snackbars/errors stay in the language active when posted.
    final locale = ref.read(userLanguageProvider);
    if (FirebaseService.isReady && ref.read(currentUserProvider) == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(HousingStrings.t('error_sign_in_required', locale)),
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = CreateListingRequest(
        title: _titleController.text.trim(),
        area: _area,
        pricePerMonth: int.parse(_priceController.text.trim()),
        type: _type,
        furnished: _furnished,
        bedrooms: int.tryParse(_bedroomsController.text.trim()) ?? 1,
        bathrooms: int.tryParse(_bathroomsController.text.trim()) ?? 1,
        photoUrls: const [],
        description: _descriptionController.text.trim(),
        amenities: _selectedAmenities.toList(),
        genderPreference: _gender,
        nationalityPreference: _nationality,
        whatsapp: _whatsappController.text.trim().replaceAll('+', ''),
        phone: _phoneController.text.trim().isEmpty
            ? '+${_whatsappController.text.trim()}'
            : _phoneController.text.trim(),
        contactName: _contactNameController.text.trim(),
        featured: false,
        isPremiumUser: false,
      );

      final listing =
          await ref.read(housingRepositoryProvider).createListing(request);

      final photoUrls =
          await _uploadPhotos(listingId: listing.id);
      if (photoUrls.isNotEmpty) {
        await ref
            .read(housingRepositoryProvider)
            .attachPhotos(listing.id, photoUrls);
      }

      try {
        final scan = await ref.read(housingRepositoryProvider).scanListingScam(
              listingId: listing.id,
              request: request,
            );
        if (scan.verdict == ScamVerdict.likelyScam && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                HousingStrings.format(
                  'scam_review_notice',
                  locale,
                  params: {'score': '${scan.scamScore}'},
                ),
              ),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      } catch (_) {
        // Scan is best-effort — listing still created
      }

      ref.invalidate(housingListingsProvider);

      await clearFormDraft();

      if (!mounted) return;
      final photosFailed = _photoFiles.isNotEmpty &&
          photoUrls.length < _photoFiles.length;
      if (photosFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              HousingStrings.t('photos_upload_warning', locale),
            ),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            listing.status == ListingStatus.pending
                ? HousingStrings.t('success_listing_pending', locale)
                : HousingStrings.t('success_listing_published', locale),
          ),
          backgroundColor: const Color(0xFF22C55E),
          action: MonetizationState.showPremiumTierUi
              ? SnackBarAction(
                  label: HousingStrings.t('promote_snackbar_action', locale),
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => BoostListingScreen(
                          listingTitle: listing.title,
                          currentViews: 0,
                          currentContacts: 0,
                          listingId: listing.id,
                        ),
                      ),
                    );
                  },
                )
              : null,
        ),
      );
      Navigator.of(context).pop();
    } on ListingsApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            HousingStrings.format(
              'submit_failed',
              locale,
              params: {'error': '$e'},
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _nextStep() {
    // Snapshot at step advance — validation message matches locale when user tapped Next.
    final locale = ref.read(userLanguageProvider);
    final error = _validateStep(_step, locale);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_step < 5) {
      setState(() => _step++);
      notifyDraftChanged();
    } else {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final stepTitles = [
      HousingStrings.t('step_photos', locale),
      HousingStrings.t('step_details', locale),
      HousingStrings.t('step_location', locale),
      HousingStrings.t('step_contact', locale),
      HousingStrings.t('step_preview', locale),
      HousingStrings.t('step_submit', locale),
    ];

    return GlassScreenScaffold(
      title: HousingStrings.t('post_listing_title', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back_ios_rounded,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => Navigator.of(context).pop(),
      ),
      safeArea: false,
      body: Column(
        children: [
          if (draftRestoreBanner != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: draftRestoreBanner!,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: List.generate(stepTitles.length, (index) {
                final active = index <= _step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 5 ? AppSpacing.xs : 0),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.cyanGlow
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                HousingStrings.format(
                  'step_label',
                  locale,
                  params: {
                    'step': '${_step + 1}',
                    'title': stepTitles[_step],
                  },
                ),
                style: AppTypography.title,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildStepContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: GlassCard(
                      onTap: _isSubmitting
                          ? null
                          : () => setState(() => _step--),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      borderRadius: AppSpacing.radiusSm,
                      child: Text(
                        CommonActionStrings.t('action_back', locale),
                        style: AppTypography.button,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: GlassCard(
                    onTap: _isSubmitting ? null : _nextStep,
                    glowColor: AppColors.cyanGlow,
                    glowIntensity: 0.25,
                    backgroundColor: AppColors.cyanGlow,
                    borderRadius: AppSpacing.radiusSm,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _step == 5
                                ? HousingStrings.t('submit_listing', locale)
                                : HousingStrings.t('action_continue', locale),
                            style: AppTypography.button.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildPhotosStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildLocationStep();
      case 3:
        return _buildContactStep();
      case 4:
        return _buildPreviewStep();
      case 5:
        return _buildSubmitStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotosStep() {
    final locale = ref.watch(userLanguageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HousingStrings.t('photos_add_title', locale),
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                onTap: () => _pickPhotos(ImageSource.gallery),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                borderRadius: AppSpacing.radiusSm,
                glowColor: AppColors.cyanGlow,
                glowIntensity: 0.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, color: AppColors.cyanGlow),
                    const SizedBox(width: AppSpacing.sm),
                    Text(HousingStrings.t('photos_gallery', locale), style: AppTypography.link),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GlassCard(
                onTap: () => _pickPhotos(ImageSource.camera),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                borderRadius: AppSpacing.radiusSm,
                glowColor: AppColors.cyanGlow,
                glowIntensity: 0.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: AppColors.cyanGlow),
                    const SizedBox(width: AppSpacing.sm),
                    Text(HousingStrings.t('photos_camera', locale), style: AppTypography.link),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_photoFiles.isEmpty)
          GlassEmptyState(
            icon: Icons.add_photo_alternate_outlined,
            title: HousingStrings.t('photos_empty_title', locale),
            description: HousingStrings.t('photos_empty_body', locale),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _photoFiles.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_photoFiles[index], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _photoFiles.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    final locale = ref.watch(userLanguageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _glassField(
          controller: _titleController,
          hint: HousingStrings.t('field_listing_title', locale),
        ),
        const SizedBox(height: AppSpacing.md),
        _glassField(
          controller: _priceController,
          hint: HousingStrings.t('field_price_month', locale),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppSpacing.md),
        _glassField(
          controller: _descriptionController,
          hint: HousingStrings.t('field_description', locale),
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          HousingStrings.t('label_property_type', locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            ListingType.room,
            ListingType.flat,
            ListingType.sharing,
            ListingType.studio,
          ].map((t) {
            final selected = _type == t;
            return GlassCard(
              onTap: () => setState(() => _type = t),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppSpacing.radiusFull,
              glowColor: selected ? AppColors.cyanGlow : null,
              glowIntensity: selected ? 0.2 : 0,
              child: Text(
                HousingStrings.listingTypeLabel(t, locale)[0].toUpperCase() +
                    HousingStrings.listingTypeLabel(t, locale).substring(1),
                style: AppTypography.chipLabel.copyWith(
                  color: selected
                      ? AppColors.cyanGlow
                      : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassSwitchTile(
          title: HousingStrings.t('label_furnished', locale),
          value: _furnished,
          onChanged: (v) => setState(() => _furnished = v),
        ),
        Row(
          children: [
            Expanded(
              child: _glassField(
                controller: _bedroomsController,
                hint: HousingStrings.t('field_bedrooms', locale),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _glassField(
                controller: _bathroomsController,
                hint: HousingStrings.t('field_bathrooms', locale),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          HousingStrings.t('label_amenities_post', locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _amenityOptions.map((a) {
            final selected = _selectedAmenities.contains(a);
            return GlassCard(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedAmenities.remove(a);
                  } else {
                    _selectedAmenities.add(a);
                  }
                });
              },
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppSpacing.radiusFull,
              glowColor: selected ? AppColors.cyanGlow : null,
              glowIntensity: selected ? 0.2 : 0,
              child: Text(
                a,
                style: AppTypography.chipLabel.copyWith(
                  color: selected
                      ? AppColors.cyanGlow
                      : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    final locale = ref.watch(userLanguageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HousingStrings.t('location_step_hint', locale),
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.md),
        ...qatarAreas.map((area) {
          final selected = _area == area;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              onTap: () => setState(() => _area = area),
              glowColor: selected ? AppColors.cyanGlow : null,
              glowIntensity: selected ? 0.15 : 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? AppColors.cyanGlow : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(area, style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary,
                  )),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        Text(
          HousingStrings.t('gender_preference', locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: GenderPreference.values.map((g) {
            final selected = _gender == g;
            return GlassCard(
              onTap: () => setState(() => _gender = g),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppSpacing.radiusFull,
              glowColor: selected ? AppColors.cyanGlow : null,
              glowIntensity: selected ? 0.2 : 0,
              child: Text(
                HousingStrings.genderLabel(g, locale),
                style: AppTypography.chipLabel.copyWith(
                  color: selected
                      ? AppColors.cyanGlow
                      : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          HousingStrings.t('nationality_preference', locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: NationalityPreference.values.map((n) {
            final selected = _nationality == n;
            return GlassCard(
              onTap: () => setState(() => _nationality = n),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppSpacing.radiusFull,
              glowColor: selected ? AppColors.cyanGlow : null,
              glowIntensity: selected ? 0.2 : 0,
              child: Text(
                HousingStrings.nationalityLabel(n, locale),
                style: AppTypography.chipLabel.copyWith(
                  color: selected
                      ? AppColors.cyanGlow
                      : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactStep() {
    final locale = ref.watch(userLanguageProvider);
    return Column(
      children: [
        _glassField(
          controller: _contactNameController,
          hint: HousingStrings.t('field_contact_name', locale),
        ),
        const SizedBox(height: AppSpacing.md),
        _glassField(
          controller: _whatsappController,
          hint: HousingStrings.t('field_whatsapp', locale),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.md),
        _glassField(
          controller: _phoneController,
          hint: HousingStrings.t('field_phone_optional', locale),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    final locale = ref.watch(userLanguageProvider);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_photoFiles.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.file(
                _photoFiles.first,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(_titleController.text, style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text('📍 $_area', style: AppTypography.body),
          Text(
            HousingStrings.format(
              'preview_price_month',
              locale,
              params: {'price': _priceController.text},
            ),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.cyanGlow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(_descriptionController.text, style: AppTypography.body),
          const SizedBox(height: AppSpacing.sm),
          Text(
            HousingStrings.format(
              'preview_contact',
              locale,
              params: {
                'name': _contactNameController.text,
                'phone': _whatsappController.text,
              },
            ),
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitStep() {
    final locale = ref.watch(userLanguageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: AppSpacing.radiusSm,
          glowColor: AppColors.warning,
          glowIntensity: 0.12,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  HousingStrings.t('submit_pending_notice', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          HousingStrings.t('submit_agreement', locale),
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
