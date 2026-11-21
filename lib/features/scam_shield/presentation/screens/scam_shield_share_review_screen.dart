import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/features/scam_shield/domain/scam_input_channel_parser.dart';
import 'package:raabta/features/scam_shield/domain/scam_share_channel_detect.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_coordinator.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_helpers.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_strings.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_sender_chips.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_share_media_parser.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_share_payload.dart';
import 'package:raabta/features/scam_shield/domain/scam_sensitive_input_mask.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_results_reveal.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_notification_service.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_share_image_cleanup.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Review screen for content shared into Raabta from another app.
class ScamShieldShareReviewScreen extends ConsumerStatefulWidget {
  const ScamShieldShareReviewScreen({super.key});

  @override
  ConsumerState<ScamShieldShareReviewScreen> createState() =>
      _ScamShieldShareReviewScreenState();
}

class _ScamShieldShareReviewScreenState
    extends ConsumerState<ScamShieldShareReviewScreen> {
  final _controller = TextEditingController();

  ScamShieldContentType _contentType = ScamShieldContentType.whatsAppSms;
  ScamShieldInputChannel _inputChannel = ScamShieldInputChannel.osShare;
  ScamShieldAssessmentResult? _result;
  List<String> _lastEvidenceKindNames = const [];
  String _lastMaskedInput = '';
  String _lastSourceText = '';
  ScamMessageSenderType _senderType = ScamMessageSenderType.notSure;
  List<String> _previewImagePaths = const [];
  final List<String> _ownedShareImagePaths = [];
  bool _loading = false;
  bool _ocrLoading = false;
  String? _ocrErrorKey;
  ScamShieldInputChannel? _suggestedChannel;
  bool _initialized = false;
  bool _unsupportedOnly = false;
  bool _showTextTruncatedNotice = false;
  int _droppedExtraImageCount = 0;
  bool _showUnsupportedAttachmentsNotice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapFromShare());
  }

  @override
  void dispose() {
    if (!_ocrLoading) {
      for (final owned in _ownedShareImagePaths) {
        ScamShieldShareImageCleanup.bestEffortDeleteOwnedFile(owned);
      }
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bootstrapFromShare() async {
    final payload = ScamShieldSharePayloadStore.consume();
    if (payload == null || payload.isEmpty) {
      if (mounted) context.go('/scam-shield');
      return;
    }

    _unsupportedOnly = payload.unsupportedOnly;
    _showTextTruncatedNotice = payload.textWasTruncated;
    _droppedExtraImageCount = payload.droppedExtraImageCount;
    _showUnsupportedAttachmentsNotice =
        payload.unsupportedAttachmentCount > 0 && !_unsupportedOnly;

    if (payload.hasImage) {
      _ownedShareImagePaths.addAll(payload.imagePaths);
      _previewImagePaths = List<String>.from(payload.imagePaths);
    }
    if (payload.hasText) {
      _controller.text = payload.sharedText!;
      if (ScamShieldShareImageCleanup.shouldPurgeWithoutOcr(
        hasText: payload.hasText,
        hasImage: payload.hasImage,
      )) {
        await _purgeAllShareImages();
      }
    } else if (payload.hasImage && payload.imagePaths.isNotEmpty) {
      await _runOcr(payload.imagePaths.first);
    }

    _refreshSuggestion();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _runOcr(String path) async {
    setState(() {
      _ocrLoading = true;
      _ocrErrorKey = null;
    });

    try {
      final ocr = ref.read(scannerOcrServiceProvider);
      final text = await ocr.extractText(path);
      if (!mounted) return;
      if (text.isNotEmpty) {
        final clamped = ScamShieldShareMediaParser.clampTextForShareInput(text);
        _controller.text = clamped.text;
        if (clamped.truncated) {
          _showTextTruncatedNotice = true;
        }
        _refreshSuggestion();
      } else {
        _ocrErrorKey = 'ss_share_ocr_empty';
      }
    } catch (_) {
      if (mounted) _ocrErrorKey = 'ss_share_ocr_failed';
    } finally {
      await _purgeShareImage(path);
      if (mounted) setState(() => _ocrLoading = false);
    }
  }

  Future<void> _purgeShareImage(String path) async {
    if (!_ownedShareImagePaths.contains(path)) return;
    await ScamShieldShareImageCleanup.bestEffortDeleteOwnedFile(path);
    _ownedShareImagePaths.remove(path);
    if (mounted) {
      setState(
        () => _previewImagePaths =
            _previewImagePaths.where((p) => p != path).toList(),
      );
    } else {
      _previewImagePaths =
          _previewImagePaths.where((p) => p != path).toList();
    }
  }

  Future<void> _purgeAllShareImages() async {
    final paths = List<String>.from(_ownedShareImagePaths);
    for (final path in paths) {
      await _purgeShareImage(path);
    }
  }

  void _refreshSuggestion() {
    _suggestedChannel = ScamShareChannelDetect.suggest(_controller.text);
  }

  Future<void> _assess() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    scamShieldLightHaptic();
    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final service = ref.read(scamShieldAssessmentServiceProvider);
      final locale = AppLocale.normalize(ref.read(userLanguageProvider));
      final canUseAi = await scamShieldCanUseAi(ref);

      final result = await service.assess(
        text: text,
        contentType: _contentType,
        language: locale,
        userId: scamShieldUserId(ref),
        canUseAi: canUseAi,
        inputChannel: _inputChannel,
        senderType: _senderType,
      );

      if (result.usedAi) {
        await scamShieldRecordAiUsage(ref);
      }

      final evidenceKinds = await ScamAnonymousSignalHelpers.evidenceKindNames(
        ref: ref,
        text: text,
        locale: locale,
        result: result,
        senderType: _senderType,
      );

      final entry = ScamShieldHistoryEntry.fromAssessment(
        result: result,
        inputText: ScamSensitiveInputMask.mask(text),
        evidenceKinds: evidenceKinds,
      );
      await ref.read(scamShieldHistoryRepositoryProvider).saveEntry(entry);
      ref.invalidate(scamShieldHistoryProvider);
      ref.invalidate(scamShieldActiveAlertProvider);

      await ScamShieldNotificationService.maybeNotifyShareAssessment(
        result: result,
        locale: locale,
        lifecycleState: WidgetsBinding.instance.lifecycleState,
      );

      await ScamAnonymousSignalHelpers.afterAssessmentShown(
        ref: ref,
        text: text,
        locale: locale,
        result: result,
        senderType: _senderType,
        evidenceKindNames: evidenceKinds,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _lastMaskedInput = ScamSensitiveInputMask.mask(text);
          _lastSourceText = text;
          _lastEvidenceKindNames = evidenceKinds;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final charCount = _controller.text.length;

    if (!_initialized) {
      return GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_share_review_title', locale),
        body: Padding(
          padding: scamShieldScreenPadding,
          child: ScamShieldAssessLoading(
            message: ScamShieldStrings.t('ss_share_ocr_loading', locale),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_share_review_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: ScamShieldEntranceReveal(
          child: SingleChildScrollView(
            padding: scamShieldScreenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeSectionHeader(
                  overline: ScamShieldStrings.t('ss_scan_overline', locale),
                  title: ScamShieldStrings.t('ss_share_review_subtitle', locale),
                  leadingIcon: Icons.ios_share_outlined,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamShieldStrings.t('ss_disclaimer', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (_unsupportedOnly) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ScamShieldStrings.t('ss_share_unsupported_only', locale),
                    style: AppTypography.body.copyWith(color: AppColors.warning),
                  ),
                ],
                if (_showTextTruncatedNotice) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ScamShieldStrings.format(
                      'ss_share_text_truncated',
                      locale,
                      {'max': ScamShieldConfig.maxInputChars.toString()},
                    ),
                    style: AppTypography.caption.copyWith(color: AppColors.warning),
                  ),
                ],
                if (_droppedExtraImageCount > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ScamShieldStrings.format(
                      'ss_share_extra_images_dropped',
                      locale,
                      {'count': _droppedExtraImageCount.toString()},
                    ),
                    style: AppTypography.caption.copyWith(color: AppColors.warning),
                  ),
                ],
                if (_showUnsupportedAttachmentsNotice) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ScamShieldStrings.t('ss_share_unsupported_attachments', locale),
                    style: AppTypography.caption.copyWith(color: AppColors.warning),
                  ),
                ],
                if (_previewImagePaths.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _previewImagePaths.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final path = _previewImagePaths[index];
                        return ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                          child: Image.file(
                            File(path),
                            height: 160,
                            width: 160,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (_ocrLoading) ...[
                  const SizedBox(height: AppSpacing.md),
                  ScamShieldAssessLoading(
                    message: ScamShieldStrings.t('ss_share_ocr_loading', locale),
                  ),
                ],
                if (_ocrErrorKey != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ScamShieldStrings.t(_ocrErrorKey!, locale),
                    style: AppTypography.caption.copyWith(color: AppColors.warning),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                ScamShieldScanInputBlock(
                  locale: locale,
                  controller: _controller,
                  hintText: ScamShieldStrings.t('ss_share_review_hint', locale),
                  charCount: charCount,
                  maxChars: ScamShieldConfig.maxInputChars,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      ScamShieldConfig.maxInputChars,
                    ),
                  ],
                  onChanged: (_) => setState(_refreshSuggestion),
                  footer: _suggestedChannel != null &&
                          _suggestedChannel != _inputChannel
                      ? Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: () => setState(() {
                              _inputChannel = _suggestedChannel!;
                              _result = null;
                            }),
                            icon: const Icon(Icons.lightbulb_outline, size: 18),
                            label: Text(
                              ScamShieldStrings.format(
                                'ss_share_channel_suggest',
                                locale,
                                {
                                  'channel': ScamShieldStrings.t(
                                    _suggestedChannel!.labelKey,
                                    locale,
                                  ),
                                },
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_loading)
                  ScamShieldAssessLoading(
                    message: ScamShieldStrings.t('ss_assess_loading', locale),
                  )
                else
                  GlassPrimaryButton(
                    onPressed: _unsupportedOnly ||
                            _ocrLoading ||
                            _controller.text.trim().isEmpty
                        ? null
                        : _assess,
                    label: ScamShieldStrings.t('ss_share_assess_cta', locale),
                    expand: true,
                    accentColor: scamShieldAccent,
                    icon: Icons.radar,
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  ScamShieldStrings.t('ss_input_channel', locale),
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ScamShieldOptionChips<ScamShieldInputChannel>(
                  options: _reviewChannels,
                  selected: _inputChannel,
                  accentColor: scamShieldAccent,
                  labelFor: (c) => ScamShieldStrings.t(c.labelKey, locale),
                  onSelected: (channel) => setState(() {
                    _inputChannel = channel;
                    _result = null;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ScamShieldStrings.t('ss_content_type', locale),
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ScamShieldOptionChips<ScamShieldContentType>(
                  options: ScamShieldContentType.values.toList(),
                  selected: _contentType,
                  accentColor: scamShieldAccent,
                  labelFor: (t) => ScamShieldStrings.t(t.labelKey, locale),
                  onSelected: (type) => setState(() {
                    _contentType = type;
                    _result = null;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                ScamShieldSenderRow(
                  locale: locale,
                  selected: _senderType,
                  onSelected: (t) => setState(() {
                    _senderType = t;
                    _result = null;
                  }),
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  ScamShieldResultsReveal(
                    result: _result!,
                    locale: locale,
                    maskedInput: _lastMaskedInput,
                    sourceText: _lastSourceText,
                    senderType: _senderType,
                    onLegitimateTap: () async {
                      await ScamAnonymousSignalCoordinator
                          .markLegitFalseAlarmForLatestQueued(
                        result: _result!,
                        sourceTextForLocalClassification: _lastSourceText,
                        evidenceKindNames: _lastEvidenceKindNames,
                        locale: locale,
                        senderType: _senderType,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ScamAnonymousSignalStrings.t(
                              'ss_signal_legit_ack',
                              locale,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static final _reviewChannels = ScamShieldInputChannel.values
      .where((c) => c != ScamShieldInputChannel.pasteText)
      .toList();
}
