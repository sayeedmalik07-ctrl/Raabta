import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/categories/business_categories.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/businesses/add_business_submit_helpers.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/presentation/widgets/business_contact_mode_picker.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';
import 'package:raabta/screens/monetization/business_advertise_screen.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';

abstract final class AddBusinessSheet {
  static Future<void> show(BuildContext context, WidgetRef ref) {
    final locale = ref.read(userLanguageProvider);
    if (ref.read(currentUserProvider) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(BusinessesStrings.t('sign_in_to_add_business', locale)),
        ),
      );
      context.push('/login');
      return Future.value();
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.viewInsetsOf(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: _AddBusinessSheetBody(parentContext: context, ref: ref),
        );
      },
    );
  }
}

class _AddBusinessSheetBody extends StatefulWidget {
  const _AddBusinessSheetBody({
    required this.parentContext,
    required this.ref,
  });

  final BuildContext parentContext;
  final WidgetRef ref;

  @override
  State<_AddBusinessSheetBody> createState() => _AddBusinessSheetBodyState();
}

class _AddBusinessSheetBodyState extends State<_AddBusinessSheetBody> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _selectedCategory = kBusinessCategories[2].filter ?? 'restaurant';
  final _languageOptions = const [
    'English',
    'Urdu',
    'Hindi',
    'Arabic',
    'Malayalam',
  ];
  final _selectedLanguages = <String>{'English'};
  final _photoFiles = <File>[];
  final _picker = ImagePicker();
  var _offerIftarDeal = false;
  var _submitting = false;
  var _contactMode = BusinessContactMode.messageOnly;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _languageFlag(String language) {
    switch (language.toLowerCase()) {
      case 'urdu':
        return '🇵🇰';
      case 'hindi':
        return '🇮🇳';
      case 'arabic':
        return '🇶🇦';
      case 'malayalam':
        return '🇮🇳';
      case 'english':
        return '🇬🇧';
      default:
        return '🌐';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickPhoto(VoidCallback onChanged) async {
    if (_photoFiles.length >= 3) return;
    final photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (photo != null) {
      setState(() => _photoFiles.add(File(photo.path)));
      onChanged();
    }
  }

  Future<void> _submit(DraftSheetHandle draft) async {
    final locale = widget.ref.read(userLanguageProvider);
    if (_nameController.text.trim().isEmpty) {
      _showMessage(BusinessesStrings.t('enter_business_name', locale));
      return;
    }
    if (!isSpecificBusinessLocation(_locationController.text)) {
      _showMessage(BusinessesStrings.t('error_location_required', locale));
      return;
    }
    if (_phoneController.text.trim().isEmpty &&
        _whatsappController.text.trim().isEmpty) {
      _showMessage(BusinessesStrings.t('error_contact_required', locale));
      return;
    }
    final phone = _phoneController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final primaryContact = phone.isNotEmpty ? phone : whatsapp;
    if (!isValidQatarPhone(primaryContact)) {
      _showMessage(BusinessesStrings.t('error_phone_invalid', locale));
      return;
    }
    if (whatsapp.isNotEmpty && !isValidQatarPhone(whatsapp)) {
      _showMessage(BusinessesStrings.t('error_phone_invalid', locale));
      return;
    }
    if (_selectedLanguages.isEmpty) {
      _showMessage(BusinessesStrings.t('error_language_required', locale));
      return;
    }
    if (!isValidBusinessDescription(_descriptionController.text)) {
      _showMessage(BusinessesStrings.t('error_description_min', locale));
      return;
    }

    final tags = <String>[];
    if (_offerIftarDeal && _selectedCategory == 'restaurant') {
      tags.add('ramadan_iftar');
    }

    setState(() => _submitting = true);
    try {
      final repo = widget.ref.read(businessesRepositoryProvider);
      final id = await repo.createBusiness(
        name: _nameController.text,
        category: businessCategoryDisplayLabel(_selectedCategory),
        categoryId: _selectedCategory,
        location: _locationController.text,
        phone: phone.isNotEmpty ? phone : whatsapp,
        whatsapp: whatsapp.isEmpty ? null : whatsapp,
        description: _descriptionController.text,
        languages: _selectedLanguages.toList(),
        tags: tags,
        contactMode: _contactMode,
      );

      if (_photoFiles.isNotEmpty) {
        try {
          final urls = <String>[];
          for (final file in _photoFiles) {
            urls.add(await repo.uploadPhoto(file, businessId: id));
          }
          await repo.attachPhotos(id, urls);
        } catch (_) {
          if (widget.parentContext.mounted) {
            _showMessage(BusinessesStrings.t('photos_upload_warning', locale));
          }
        }
      }

      await draft.clearDraft();
      if (mounted) Navigator.pop(context);
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(BusinessesStrings.t('success_submitted', locale)),
            backgroundColor: AppColors.success,
            action: MonetizationState.showPremiumTierUi
                ? SnackBarAction(
                    label: BusinessesStrings.t('promote_snackbar_action', locale),
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.of(widget.parentContext).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => const BusinessAdvertiseScreen(),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (widget.parentContext.mounted) {
        _showMessage(mapBusinessSubmitError(e, locale));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.ref.watch(userLanguageProvider);

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return DraftAwareSheet(
          formId: DraftBoxKeys.businessListingAdd,
          controllers: [
            _nameController,
            _locationController,
            _phoneController,
            _whatsappController,
            _descriptionController,
          ],
          serialize: () => {
            'name': _nameController.text,
            'location': _locationController.text,
            'phone': _phoneController.text,
            'whatsapp': _whatsappController.text,
            'description': _descriptionController.text,
            'category': _selectedCategory,
            'languages': _selectedLanguages.toList(),
          },
          applyDraft: (data) {
            setSheetState(() {
              _nameController.text = data['name']?.toString() ?? '';
              _locationController.text = data['location']?.toString() ?? '';
              _phoneController.text = data['phone']?.toString() ?? '';
              _whatsappController.text = data['whatsapp']?.toString() ?? '';
              _descriptionController.text =
                  data['description']?.toString() ?? '';
              _selectedCategory =
                  data['category']?.toString() ??
                      kBusinessCategories[2].filter ??
                      'Restaurant';
              _selectedLanguages
                ..clear()
                ..addAll(
                  (data['languages'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      ['English'],
                );
            });
          },
          builder: (context, draft) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      BusinessesStrings.t('add_business', locale),
                      style: AppTypography.headline1,
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      controller: _nameController,
                      hint: BusinessesStrings.t('field_business_name', locale),
                      onChanged: draft.notifyChanged,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedCategory),
                      initialValue: _selectedCategory,
                      dropdownColor: AppColors.background,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: _fieldDecoration(
                        BusinessesStrings.t('field_category', locale),
                      ),
                      items: kBusinessCategories
                          .where((c) => c.filter != null)
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.filter,
                              child: Text('${c.emoji} ${c.label}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setSheetState(() {
                            _selectedCategory = v;
                            if (v != 'restaurant') _offerIftarDeal = false;
                          });
                          draft.notifyChanged();
                        }
                      },
                    ),
                    if (_selectedCategory == 'restaurant') ...[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          BusinessesStrings.t('iftar_deal_toggle', locale),
                          style: AppTypography.body,
                        ),
                        value: _offerIftarDeal,
                        activeThumbColor: AppColors.cyanGlow,
                        onChanged: (v) {
                          setSheetState(() => _offerIftarDeal = v);
                          draft.notifyChanged();
                        },
                      ),
                    ],
                    const SizedBox(height: 10),
                    _FormField(
                      controller: _locationController,
                      hint: BusinessesStrings.t('field_location', locale),
                      onChanged: draft.notifyChanged,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: _phoneController,
                      hint: BusinessesStrings.t('field_phone', locale),
                      keyboardType: TextInputType.phone,
                      onChanged: draft.notifyChanged,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: _whatsappController,
                      hint: BusinessesStrings.t('field_whatsapp', locale),
                      keyboardType: TextInputType.phone,
                      onChanged: draft.notifyChanged,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      BusinessesStrings.t('languages_spoken', locale),
                      style: AppTypography.body,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _languageOptions.map((lang) {
                        final selected = _selectedLanguages.contains(lang);
                        return FilterChip(
                          label: Text('${_languageFlag(lang)} $lang'),
                          selected: selected,
                          onSelected: (v) {
                            setSheetState(() {
                              if (v) {
                                _selectedLanguages.add(lang);
                              } else if (_selectedLanguages.length > 1) {
                                _selectedLanguages.remove(lang);
                              }
                            });
                            draft.notifyChanged();
                          },
                          selectedColor:
                              AppColors.cyanGlow.withValues(alpha: 0.2),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: _descriptionController,
                      hint: BusinessesStrings.t('field_description', locale),
                      maxLines: 3,
                      onChanged: draft.notifyChanged,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      BusinessesStrings.t('photos_optional', locale),
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._photoFiles.asMap().entries.map(
                          (entry) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  entry.value,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: () {
                                    setSheetState(
                                      () => _photoFiles.remove(entry.value),
                                    );
                                    draft.notifyChanged();
                                  },
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.error,
                                    child: Icon(Icons.close, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_photoFiles.length < 3)
                          OutlinedButton.icon(
                            onPressed: _submitting
                                ? null
                                : () => _pickPhoto(draft.notifyChanged),
                            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                            label: Text(BusinessesStrings.t('add_photo', locale)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BusinessContactModePicker(
                      locale: locale,
                      value: _contactMode,
                      onChanged: (mode) {
                        setSheetState(() => _contactMode = mode);
                        draft.notifyChanged();
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : () => _submit(draft),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyanGlow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _submitting
                              ? BusinessesStrings.t('submitting', locale)
                              : BusinessesStrings.t('submit_listing', locale),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged?.call(),
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
