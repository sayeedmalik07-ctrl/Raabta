import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/screens/community/widgets/community_section_primitives.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/domain/lost_found_area.dart';
import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/domain/lost_found_listing_media.dart';
import 'package:raabta/features/community/domain/lost_found_location_display.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/services/lost_found_photo_service.dart';
import 'package:raabta/features/community/widgets/lost_found_attributes_composer.dart';
import 'package:raabta/features/community/widgets/lost_found_listing_photo.dart';
import 'package:raabta/features/community/widgets/lost_found_match_section.dart';
import 'package:raabta/features/community/widgets/community_cross_post_prompt.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/community/widgets/community_group_tag_selector.dart';
import 'package:raabta/features/community/widgets/community_why_seeing_affordance.dart';
import 'package:raabta/features/community/utils/community_visibility_reasons.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/features/home/widgets/metric_chip.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:url_launcher/url_launcher.dart';

class LostFoundScreen extends ConsumerStatefulWidget {
  const LostFoundScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends ConsumerState<LostFoundScreen> {
  bool _showLost = true;
  bool _showResolved = false;
  bool _posting = false;

  static String _feedbackMessage(String message, String locale) {
    if (message.startsWith('community_')) {
      return CommunityStrings.t(message, locale);
    }
    return message;
  }

  Future<void> _showPostSheet() async {
    final joinedGroupIds =
        ref.read(communityMembershipProvider).value ?? const {};
    final suggestedLabels =
        ref.read(suggestedCommunityContentLabelIdsProvider);

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final contactController = TextEditingController();
    final brandController = TextEditingController();
    final itemTypeController = TextEditingController();
    final marksController = TextEditingController();
    final hiddenDetailController = TextEditingController();
    var occurred = DateTime.now();
    var selectedGroupTags = <String>{};
    String? selectedAreaCode;
    String? selectedCategory;
    var selectedColors = <String>{};
    File? pendingPhoto;
    var sheetUploading = false;
    final imagePicker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return CommunityReactiveLocale(
          builder: (context, locale) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return DraftAwareSheet(
              formId: DraftBoxKeys.lostFoundComposer('community'),
              controllers: [
                titleController,
                descController,
                locationController,
                contactController,
                brandController,
                itemTypeController,
                marksController,
                hiddenDetailController,
              ],
              serialize: () => {
                'title': titleController.text,
                'description': descController.text,
                'location': locationController.text,
                'contact': contactController.text,
                'occurred': occurred.toIso8601String(),
                'isLost': _showLost,
                'areaCode': selectedAreaCode ?? '',
                'category': selectedCategory ?? '',
                'colors': selectedColors.toList(),
                'brand': brandController.text,
                'itemType': itemTypeController.text,
                'marks': marksController.text,
                'hiddenDetail': hiddenDetailController.text,
              },
              applyDraft: (data) {
                setSheetState(() {
                  titleController.text = data['title']?.toString() ?? '';
                  descController.text = data['description']?.toString() ?? '';
                  locationController.text = data['location']?.toString() ?? '';
                  contactController.text = data['contact']?.toString() ?? '';
                  brandController.text = data['brand']?.toString() ?? '';
                  itemTypeController.text = data['itemType']?.toString() ?? '';
                  marksController.text = data['marks']?.toString() ?? '';
                  hiddenDetailController.text =
                      data['hiddenDetail']?.toString() ?? '';
                  final raw = data['occurred']?.toString();
                  if (raw != null) {
                    occurred = DateTime.tryParse(raw) ?? occurred;
                  }
                  final areaRaw = data['areaCode']?.toString() ?? '';
                  selectedAreaCode = LostFoundArea.normalizeAreaCode(
                    areaRaw.isEmpty ? null : areaRaw,
                  );
                  final catRaw = data['category']?.toString() ?? '';
                  selectedCategory = LostFoundCategory.normalize(
                    catRaw.isEmpty ? null : catRaw,
                  );
                  final colorsRaw = data['colors'];
                  if (colorsRaw is List) {
                    selectedColors = colorsRaw
                        .map((e) => e.toString().trim().toLowerCase())
                        .where(LostFoundColorPalette.all.contains)
                        .toSet();
                  }
                });
              },
              builder: (context, draft) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.lg,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _showLost
                              ? CommunityStrings.t(
                                  'community_lf_report_lost',
                                  locale,
                                )
                              : CommunityStrings.t(
                                  'community_lf_report_found',
                                  locale,
                                ),
                          style: AppTypography.headline2,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: CommunityStrings.t(
                              'community_lf_label_title',
                              locale,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: descController,
                          decoration: InputDecoration(
                            labelText: CommunityStrings.t(
                              'community_lf_label_description',
                              locale,
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: _showLost
                                ? CommunityStrings.t(
                                    'community_lf_label_last_seen',
                                    locale,
                                  )
                                : CommunityStrings.t(
                                    'community_lf_label_found_at',
                                    locale,
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String?>(
                          value: selectedAreaCode,
                          decoration: InputDecoration(
                            labelText: CommunityStrings.t(
                              'community_lf_label_area',
                              locale,
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                CommunityStrings.t(
                                  'community_lf_area_optional',
                                  locale,
                                ),
                              ),
                            ),
                            for (final area in LostFoundArea.supportedCodes)
                              DropdownMenuItem<String?>(
                                value: area,
                                child: Text(area),
                              ),
                          ],
                          onChanged: _posting || sheetUploading
                              ? null
                              : (value) {
                                  setSheetState(
                                    () => selectedAreaCode =
                                        LostFoundArea.normalizeAreaCode(value),
                                  );
                                  draft.notifyChanged();
                                },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: contactController,
                          decoration: InputDecoration(
                            labelText: CommunityStrings.t(
                              'community_lf_label_contact',
                              locale,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LostFoundAttributesComposer(
                          locale: locale,
                          selectedCategory: selectedCategory,
                          selectedColors: selectedColors,
                          brandController: brandController,
                          itemTypeController: itemTypeController,
                          marksController: marksController,
                          enabled: !_posting && !sheetUploading,
                          onCategoryChanged: (value) {
                            setSheetState(() {
                              selectedCategory = value;
                              if (LostFoundCategory.blocksPhoto(value)) {
                                pendingPhoto = null;
                              }
                            });
                            draft.notifyChanged();
                          },
                          onColorsChanged: (colors) {
                            setSheetState(() => selectedColors = colors);
                            draft.notifyChanged();
                          },
                        ),
                        if (!_showLost) ...[
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: hiddenDetailController,
                            enabled: !_posting && !sheetUploading,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: CommunityStrings.t(
                                'community_lf_label_hidden_detail',
                                locale,
                              ),
                              helperText: CommunityStrings.t(
                                'community_lf_hidden_detail_hint',
                                locale,
                              ),
                            ),
                            onChanged: (_) => draft.notifyChanged(),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              _showLost
                                  ? CommunityStrings.t(
                                      'community_lf_date_lost',
                                      locale,
                                    )
                                  : CommunityStrings.t(
                                      'community_lf_date_found',
                                      locale,
                                    ),
                            ),
                            subtitle: Text(DateFormat.yMMMd().format(occurred)),
                            trailing: CommunityHubIcons.actionGlyph(
                              Icons.calendar_today_outlined,
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: occurred,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 90)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setSheetState(() => occurred = date);
                                draft.notifyChanged();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LostFoundComposerPhotoPicker(
                          locale: locale,
                          pendingFile: pendingPhoto,
                          enabled: !_posting,
                          uploading: sheetUploading,
                          attachEnabled: selectedCategory != null &&
                              !LostFoundCategory.blocksPhoto(
                                selectedCategory,
                              ),
                          disabledHint: selectedCategory == null
                              ? CommunityStrings.t(
                                  'community_lf_err_category_before_photo',
                                  locale,
                                )
                              : null,
                          onPick: () async {
                            if (_posting || sheetUploading) return;
                            if (selectedCategory == null ||
                                LostFoundCategory.blocksPhoto(
                                  selectedCategory,
                                )) {
                              return;
                            }
                            try {
                              final picked = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: LostFoundPhotoService.maxEdgePx
                                    .toDouble(),
                                imageQuality: 85,
                              );
                              if (picked == null) return;
                              setSheetState(
                                () => pendingPhoto = File(picked.path),
                              );
                              draft.notifyChanged();
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      CommunityStrings.t(
                                        'community_lf_err_photo_upload',
                                        locale,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          onRemove: () {
                            setSheetState(() => pendingPhoto = null);
                            draft.notifyChanged();
                          },
                        ),
                        if (joinedGroupIds.isNotEmpty ||
                            suggestedLabels.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          CommunityGroupTagSelector(
                            joinedGroupIds: joinedGroupIds,
                            selectedIds: selectedGroupTags,
                            locale: locale,
                            suggestedContentLabelIds: suggestedLabels,
                            onChanged: _posting
                                ? (_) {}
                                : (tags) {
                                    setSheetState(
                                      () => selectedGroupTags = tags,
                                    );
                                    draft.notifyChanged();
                                  },
                            enabled: !_posting,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _posting || sheetUploading
                              ? null
                              : () async {
                                  final title = titleController.text.trim();
                                  final description = descController.text.trim();
                                  final location = locationController.text.trim();
                                  final contact = contactController.text.trim();
                                  final listingAttributes =
                                      LostFoundAttributesValidation.parseUserInput(
                                    categoryRaw: selectedCategory,
                                    colorsRaw: selectedColors,
                                    brand: brandController.text,
                                    itemType: itemTypeController.text,
                                    marks: marksController.text,
                                  );
                                  if (pendingPhoto != null &&
                                      selectedCategory == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          CommunityStrings.t(
                                            'community_lf_err_category_before_photo',
                                            locale,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (title.length < 4 || location.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          CommunityStrings.t(
                                            'community_lf_err_title_location',
                                            locale,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _posting = true);
                                  setSheetState(() => sheetUploading = true);
                                  String? orphanStoragePath;
                                  try {
                                    final repo = ref.read(
                                      communityRepositoryProvider,
                                    );
                                    final photoService = ref.read(
                                      lostFoundPhotoServiceProvider,
                                    );
                                    String? photoUrl;
                                    final allowPhoto =
                                        !LostFoundCategory.blocksPhoto(
                                      selectedCategory,
                                    );
                                    if (pendingPhoto != null && allowPhoto) {
                                      try {
                                        final uid = await repo.currentUserId();
                                        final upload =
                                            await photoService.uploadListingPhoto(
                                          ownerUserId: uid,
                                          file: pendingPhoto!,
                                        );
                                        photoUrl = upload.downloadUrl;
                                        orphanStoragePath = upload.storagePath;
                                      } on LostFoundPhotoException catch (e) {
                                        if (context.mounted) {
                                          final key = e.code == 'image_too_large'
                                              ? 'community_lf_err_photo_too_large'
                                              : 'community_lf_err_photo_upload';
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                CommunityStrings.t(key, locale),
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                    }

                                    final joinedGroupIds = ref.read(
                                      communityMembershipProvider,
                                    ).value ?? const {};
                                    final finalTags =
                                        await CommunityCrossPostPrompt.resolveTags(
                                      context: context,
                                      selectedTags: selectedGroupTags,
                                      joinedGroupIds: joinedGroupIds,
                                      locale: locale,
                                    );
                                    if (!context.mounted) return;

                                    final result = await ref
                                        .read(
                                          communityModerationOrchestratorProvider,
                                        )
                                        .submitLostFound(
                                          relevantGroupIds: finalTags,
                                          type: _showLost ? 'lost' : 'found',
                                          title: title,
                                          itemDescription: description,
                                          location: location,
                                          dateOccurred: occurred,
                                          contactInfo: contact,
                                          areaCode: selectedAreaCode,
                                          photoUrl: photoUrl,
                                          attributes: listingAttributes,
                                          finderHiddenDetail: _showLost
                                              ? null
                                              : hiddenDetailController.text,
                                          itemType: itemTypeController.text,
                                          marks: marksController.text,
                                        );
                                    if (!result.posted) {
                                      if (orphanStoragePath != null) {
                                        await photoService.deleteUploadedPhoto(
                                          orphanStoragePath,
                                        );
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _feedbackMessage(
                                                result.message,
                                                locale,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    orphanStoragePath = null;
                                    await draft.clearDraft();
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _feedbackMessage(
                                              result.message,
                                              locale,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (orphanStoragePath != null) {
                                      await ref
                                          .read(lostFoundPhotoServiceProvider)
                                          .deleteUploadedPhoto(
                                            orphanStoragePath,
                                          );
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            CommunityStrings.t(
                                              'community_lf_err_post',
                                              locale,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _posting = false);
                                    }
                                    setSheetState(() => sheetUploading = false);
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandFamilyMain,
                            foregroundColor: AppColors.background,
                          ),
                          child: _posting || sheetUploading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  CommunityStrings.t(
                                    'community_lf_post_listing',
                                    locale,
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
          },
        );
      },
    );

    titleController.dispose();
    descController.dispose();
    locationController.dispose();
    contactController.dispose();
    brandController.dispose();
    itemTypeController.dispose();
    marksController.dispose();
    hiddenDetailController.dispose();
  }

  Future<void> _contact(String contact) async {
    final normalized = contact.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse(
      normalized.startsWith('+') ? 'https://wa.me/$normalized' : 'tel:$normalized',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CommunityStrings.t(
                'community_lf_err_contact',
                ref.read(userLanguageProvider),
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openDetail(
    LostFoundItem item,
    String? currentUid,
  ) async {
    final group = CommunityGroupRegistry.byId(item.groupId);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return CommunityReactiveLocale(
          builder: (context, locale) {
            return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                label: item.isLost
                    ? CommunityStrings.t('community_lf_badge_lost', locale)
                    : CommunityStrings.t('community_lf_badge_found', locale),
                color: item.isLost ? AppColors.error : AppColors.success,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                item.title.isNotEmpty ? item.title : item.itemDescription,
                style: AppTypography.headline2,
              ),
              if (group != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text('${group.emoji} ${group.name}', style: AppTypography.body),
              ],
              const SizedBox(height: AppSpacing.sm),
              UserGeneratedTextWithLinkSafety(
                text: item.itemDescription,
                locale: locale,
                surface: LinkSafetySurface.lostFound,
              ),
              if (LostFoundListingMedia.shouldDisplayPhoto(item)) ...[
                const SizedBox(height: AppSpacing.md),
                LostFoundListingPhoto(photoUrl: item.photoUrl!),
              ],
              if (item.attributes != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  CommunityStrings.t(
                    LostFoundCategory.labelKey(item.attributes!.category),
                    locale,
                  ),
                  style: AppTypography.caption,
                ),
              ],
              if (!item.isLost && item.isOpen) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  CommunityStrings.t('community_lf_claimant_tip', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              LostFoundMatchSection(
                item: item,
                locale: locale,
                isOwner: currentUid != null && currentUid == item.createdBy,
              ),
              const SizedBox(height: AppSpacing.md),
              MetricChip(
                icon: Icons.location_on_outlined,
                value: LostFoundLocationDisplay.format(
                  location: item.location,
                  areaCode: item.areaCode,
                ),
                accentColor: AppColors.textSecondary,
              ),
              if (item.contactInfo.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _contact(item.contactInfo),
                    icon: CommunityHubIcons.actionGlyph(
                      Icons.chat_bubble_outline,
                      color: AppColors.background,
                    ),
                    label: Text(
                      item.isLost
                          ? CommunityStrings.t(
                              'community_lf_contact_whatsapp',
                              locale,
                            )
                          : CommunityStrings.t(
                              'community_lf_contact_claim',
                              locale,
                            ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.greenFamilyMain,
                    ),
                  ),
                ),
              ],
              if (currentUid == item.createdBy && item.isOpen) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(communityRepositoryProvider)
                          .resolveLostFound(item.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (_) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              CommunityStrings.t(
                                'community_lf_err_resolve',
                                locale,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    CommunityStrings.t('community_lf_mark_resolved', locale),
                  ),
                ),
              ],
            ],
          ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = _showLost ? 'lost' : 'found';
    final openAsync = ref.watch(lostFoundOpenProvider(type));
    final resolvedAsync = ref.watch(lostFoundResolvedProvider);
    final uidAsync = ref.watch(communityUserIdProvider);
    final body = _buildBody(openAsync, resolvedAsync, uidAsync.value);

    if (widget.embedded) return body;
    final locale = ref.watch(userLanguageProvider);
    return CommunitySectionPrimitives.standaloneScaffold(
      context: context,
      title: CommunityStrings.t('community_lf_title', locale),
      subtitle: CommunityStrings.t('community_lf_subtitle', locale),
      body: body,
    );
  }

  Widget _buildBody(
    AsyncValue<List<LostFoundItem>> openAsync,
    AsyncValue<List<LostFoundItem>> resolvedAsync,
    String? currentUid,
  ) {
    final locale = ref.watch(userLanguageProvider);
    return RefreshIndicator(
      color: CommunitySectionPrimitives.refreshColor,
      onRefresh: () async {
        ref.invalidate(lostFoundOpenProvider(_showLost ? 'lost' : 'found'));
        ref.invalidate(lostFoundResolvedProvider);
      },
      child: ListView(
        padding: CommunitySectionPrimitives.embeddedListPadding(
          embedded: widget.embedded,
        ),
        children: [
          if (widget.embedded)
            CommunitySectionPrimitives.embeddedSectionHeader(
              title: CommunityStrings.t('community_lf_title', locale),
              subtitle: CommunityStrings.t('community_lf_subtitle', locale),
              leadingIcon: Icons.travel_explore_outlined,
            ),
          if (widget.embedded) const SizedBox(height: AppSpacing.md),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: HubLayoutTokens.filterChipHeight,
            child: Row(
              children: [
                Expanded(
                  child: buildHubFilterChip(
                    label: Text(
                      CommunityStrings.t('community_lf_lost_items', locale),
                    ),
                    selected: _showLost,
                    onSelected: (_) => setState(() => _showLost = true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: buildHubFilterChip(
                    label: Text(
                      CommunityStrings.t('community_lf_found_items', locale),
                    ),
                    selected: !_showLost,
                    onSelected: (_) => setState(() => _showLost = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _posting ? null : _showPostSheet,
              icon: CommunityHubIcons.actionGlyph(
                Icons.add,
                color: AppColors.background,
              ),
              label: Text(
                _showLost
                    ? CommunityStrings.t('community_lf_report_lost', locale)
                    : CommunityStrings.t('community_lf_report_found', locale),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandFamilyMain,
                foregroundColor: AppColors.background,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          openAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: HubLoadingPlaceholder(
                height: 140,
                width: 360,
                silhouette: HubLoadingSilhouette.postCard,
              ),
            ),
            error: (_, _) => GlassEmptyState(
              accent: GlassEmptyStateAccent.teal,
              icon: Icons.error_outline,
              title: CommunityStrings.t(
                'community_lf_err_load',
                locale,
              ),
              description: CommunityStrings.t(
                'community_lf_err_load_hint',
                locale,
              ),
            ),
            data: (posts) {
              if (posts.isEmpty) {
                return GlassEmptyState(
                  accent: GlassEmptyStateAccent.teal,
                  icon: _showLost ? Icons.search_off : Icons.inventory_2_outlined,
                  title: _showLost
                      ? CommunityStrings.t(
                          'community_lf_empty_lost',
                          locale,
                        )
                      : CommunityStrings.t(
                          'community_lf_empty_found',
                          locale,
                        ),
                  description: CommunityStrings.t(
                    'community_lf_empty_hint',
                    locale,
                  ),
                );
              }
              return Column(
                children: [
                  for (final post in posts)
                    _LostFoundHubCard(
                      post: post,
                      locale: locale,
                      onTap: () => _openDetail(post, currentUid),
                    ),
                ],
              );
            },
          ),
          resolvedAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (resolved) {
              final mine = resolved
                  .where((r) => r.type == (_showLost ? 'lost' : 'found'))
                  .toList();
              if (mine.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  GestureDetector(
                    onTap: () => setState(() => _showResolved = !_showResolved),
                    child: Row(
                      children: [
                        Text(
                          CommunityStrings.format(
                            'community_lf_resolved_count',
                            locale,
                            params: {'count': '${mine.length}'},
                          ),
                          style: AppTypography.subtitle,
                        ),
                        CommunityHubIcons.actionGlyph(
                          _showResolved
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                        ),
                      ],
                    ),
                  ),
                  if (_showResolved)
                    for (final post in mine)
                      _LostFoundHubCard(
                        post: post,
                        locale: locale,
                        onTap: () => _openDetail(post, currentUid),
                        resolved: true,
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LostFoundHubCard extends ConsumerWidget {
  const _LostFoundHubCard({
    required this.post,
    required this.locale,
    required this.onTap,
    this.resolved = false,
  });

  final LostFoundItem post;
  final String locale;
  final VoidCallback onTap;
  final bool resolved;

  static final Color _whatsappGreen = AppColors.greenFamilyMain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = CommunityGroupRegistry.byId(post.groupId);
    final badgeLabel = resolved
        ? CommunityStrings.t('community_lf_badge_resolved', locale)
        : (post.isLost
            ? CommunityStrings.t('community_lf_badge_lost', locale)
            : CommunityStrings.t('community_lf_badge_found', locale));
    final locationLabel = LostFoundLocationDisplay.format(
      location: post.location,
      areaCode: post.areaCode,
    );
    final whenLabel = communityRelativeTime(post.dateOccurred, locale);
    final section = CommunityStrings.t('community_tab_lost_found', locale);
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);
    final visibility = CommunityVisibilityInput(
      relevantGroupIds: post.relevantGroupIds,
      contentLocation: post.location,
    );
    final whyLabel = CommunityStrings.t('community_why_seeing_link', locale);
    final headline =
        post.title.isNotEmpty ? post.title : post.itemDescription;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: HubPostCard(
        onTap: onTap,
        pinnedLabel: badgeLabel,
        authorName: group?.name ??
            CommunityStrings.t('community_lf_title', locale),
        authorInitial: group?.emoji ?? (post.isLost ? '🔍' : '✅'),
        sectionContextLine: '$section · $locationLabel · $whenLabel',
        trustTierBadge: (
          label: trustLabel,
          tier: HubContentTrustTier.community,
        ),
        body: headline,
        bodyChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.title.isNotEmpty &&
                post.itemDescription != post.title)
              Text(
                post.itemDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body,
              ),
            if (LostFoundListingMedia.shouldDisplayPhoto(post)) ...[
              const SizedBox(height: AppSpacing.md),
              LostFoundListingPhoto(
                photoUrl: post.photoUrl!,
                height: 140,
                compact: true,
              ),
            ],
          ],
        ),
        whySeeingLabel: whyLabel,
        onWhySeeingTap: () => CommunityWhySeeingAffordance.showForInput(
          context,
          ref,
          visibility,
        ),
        footer: !resolved && post.contactInfo.isNotEmpty
            ? Text(
                CommunityStrings.t('community_lf_tap_contact', locale),
                style: AppTypography.link.copyWith(color: _whatsappGreen),
              )
            : null,
      ),
    );
  }
}
