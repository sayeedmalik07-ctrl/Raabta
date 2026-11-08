import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:raabta/features/arabic_companion/arabic_companion_config.dart';
import 'package:raabta/features/arabic_companion/data/arabic_translations_cache_service.dart';
import 'package:raabta/features/arabic_companion/providers/arabic_companion_providers.dart';

import 'landmark_translator/landmark_stt_locale.dart';
import 'landmark_translator/l10n/landmark_translator_strings.dart';
import 'landmark_translator/models/saved_landmark.dart';
import 'landmark_translator/services/landmark_translation_cache.dart';
import 'landmark_translator/services/ride_link_service.dart';
import 'landmark_translator/widgets/navigation_ride_sheet.dart';
import 'landmark_translator/widgets/saved_landmarks_list.dart';
import 'landmark_translator/widgets/save_landmark_sheet.dart';

class LandmarkTranslatorScreen extends ConsumerStatefulWidget {
  const LandmarkTranslatorScreen({super.key, this.companionMode = true});

  /// When true, shown as Arabic Companion live translation (secondary surface).
  final bool companionMode;

  @override
  ConsumerState<LandmarkTranslatorScreen> createState() =>
      _LandmarkTranslatorScreenState();
}

class _LandmarkTranslatorScreenState
    extends ConsumerState<LandmarkTranslatorScreen> {
  final _controller = TextEditingController();
  final _tts = FlutterTts();
  bool _isTranslating = false;
  bool _isSpeaking = false;
  String? _arabicResult;
  String? _englishGps;
  String? _area;
  String? _confidence;
  String? _errorMsg;
  bool _fromOfflineCache = false;
  bool _fromSharedCache = false;

  // ── TTS state ──────────────────────────────────────
  bool _ttsReady = true;
  bool _ttsFailed = false;

  // ── Voice input state ────────────────────────────────
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  // ── Saved landmarks state ────────────────────────────
  List<SavedLandmark> _savedLandmarks = [];
  bool _loadingLandmarks = false;

  final _quickChips = [
    'Al Meera',
    'Lulu Hypermarket',
    'City Center Doha',
    'The Pearl',
    'Villagio Mall',
    'Doha Festival City',
    'Hamad Airport',
    'QatarEnergy HQ',
    'Al Sadd',
    'West Bay',
    'Al Khor',
    'Industrial Area',
    'Souq Waqif',
    'Education City',
  ];

  @override
  void initState() {
    super.initState();
    _setupTts();
    _initVoiceAndLandmarks();
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _setupTts() async {
    try {
      await _tts.setLanguage('ar-QA');
      await _tts.setSpeechRate(0.65);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _ttsFailed = true;
            _ttsReady = false;
          });
        }
      });
      if (mounted) setState(() => _ttsReady = true);
    } catch (_) {
      if (mounted) setState(() => _ttsReady = false);
    }
  }

  Future<void> _translate() async {
    // Snapshot for this translate request (prompt language + error strings).
    final locale = ref.read(userLanguageProvider);
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMsg = LandmarkTranslatorStrings.t('error_empty', locale);
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _arabicResult = null;
      _englishGps = null;
      _area = null;
      _confidence = null;
      _fromOfflineCache = false;
      _fromSharedCache = false;
      _errorMsg = null;
    });

    try {
      final cacheService = ref.read(arabicTranslationsCacheServiceProvider);

      final shared = await cacheService.find(input);
      if (shared != null && mounted) {
        _applyTranslationResult(
          arabic: shared.arabic,
          englishGps: shared.englishGps,
          area: shared.area,
          confidence: shared.confidence ?? 'medium',
          fromSharedCache: true,
          fromOfflineCache: false,
        );
        return;
      }

      final localCached = await LandmarkTranslationCache.find(input);
      if (localCached != null && mounted) {
        _applyTranslationResult(
          arabic: localCached.arabic,
          englishGps: localCached.englishGps,
          area: localCached.area,
          confidence: localCached.confidence ?? 'medium',
          fromSharedCache: false,
          fromOfflineCache: true,
        );
        return;
      }

      if (!await arabicCompanionCanUseAi(ref)) {
        if (mounted) {
          setState(() {
            _errorMsg = LandmarkTranslatorStrings.t('ai_limit_reached', locale);
            _isTranslating = false;
          });
        }
        return;
      }

      final claudeService = ref.read(claudeAIServiceProvider);
      final inputLanguage = LandmarkSttLocale.languageNameForPrompt(locale);

      final prompt = '''
You are a Qatar address and navigation expert helping expats communicate
locations to local drivers, delivery riders, and anyone who needs directions in Qatar.

The user wrote their location in $inputLanguage (app language). The text may mix
$inputLanguage with English landmark names — interpret both.

Convert the description into natural Gulf/Qatari colloquial Arabic that a
Karwa taxi driver or local driver would immediately understand. Also provide a
clean English GPS description for Google Maps.

Input address ($inputLanguage): "$input"

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "arabic": "<natural Gulf Arabic a Qatar driver understands, using local landmark names>",
  "englishGps": "<clean English description with area name, street if known, nearest landmark>",
  "area": "<district or area name in English e.g. Al Khor, West Bay, Al Sadd>",
  "confidence": "<high|medium|low>"
}

Rules:
- Arabic must be natural Gulf Arabic, not formal Modern Standard Arabic
- Use well-known Qatar landmark names in Arabic (مول سيتي سنتر, اللولو, المير etc.)
- If input mentions Al Khor, use الخور
- If input mentions Pearl, use اللؤلؤة
- Keep Arabic short and clear — what you would say to a driver
- englishGps should be usable as a Google Maps search query
''';

      final response = await claudeService.sendMessage(
        prompt,
        requestType: ArabicCompanionConfig.aiRequestType,
      );

      final clean = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}');
      if (start == -1 || end == -1) {
        throw FormatException('Invalid AI response');
      }

      final json =
          jsonDecode(clean.substring(start, end + 1)) as Map<String, dynamic>;

      final arabic = json['arabic'] as String? ?? 'خطأ في الترجمة';
      final englishGps = json['englishGps'] as String? ?? input;
      final area = json['area'] as String?;
      final confidence = json['confidence'] as String?;

      await arabicCompanionRecordAiUsage(ref);

      final cachedEntry = CachedArabicTranslation(
        input: input,
        arabic: arabic,
        englishGps: englishGps,
        area: area,
        confidence: confidence,
      );
      await cacheService.persist(cachedEntry);
      await LandmarkTranslationCache.save(cachedEntry.toLocalEntry());

      if (mounted) {
        _applyTranslationResult(
          arabic: arabic,
          englishGps: englishGps,
          area: area,
          confidence: confidence,
          fromSharedCache: false,
          fromOfflineCache: false,
        );
      }
    } catch (_) {
      final cached = await LandmarkTranslationCache.find(input);
      if (cached != null && mounted) {
        setState(() {
          _arabicResult = cached.arabic;
          _englishGps = cached.englishGps;
          _area = cached.area;
          _confidence = cached.confidence ?? 'medium';
          _fromOfflineCache = true;
          _fromSharedCache = false;
          _errorMsg = null;
          _isTranslating = false;
        });
      } else if (mounted) {
        setState(() {
          _errorMsg = LandmarkTranslatorStrings.t(
            'error_translate',
            // Snapshot: error belongs to the failed request's locale.
            ref.read(userLanguageProvider),
          );
          _isTranslating = false;
        });
      }
    }
  }

  void _applyTranslationResult({
    required String arabic,
    required String englishGps,
    String? area,
    String? confidence,
    required bool fromSharedCache,
    required bool fromOfflineCache,
  }) {
    setState(() {
      _arabicResult = arabic;
      _englishGps = englishGps;
      _area = area;
      _confidence = confidence;
      _fromSharedCache = fromSharedCache;
      _fromOfflineCache = fromOfflineCache;
      _isTranslating = false;
      _errorMsg = null;
    });
  }

  Future<void> _speakArabic() async {
    if (_arabicResult == null) return;
    // Snapshot at speak tap — snackbar strings match locale when TTS started.
    final locale = ref.read(userLanguageProvider);

    if (_isSpeaking) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }

    if (!_ttsReady) {
      setState(() => _ttsFailed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LandmarkTranslatorStrings.t('tts_unavailable', locale)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSpeaking = true;
      _ttsFailed = false;
    });

    try {
      await _tts.setLanguage('ar-QA');
      final result = await _tts.speak(_arabicResult!);
      if (result != 1 && mounted) {
        setState(() {
          _ttsFailed = true;
          _isSpeaking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LandmarkTranslatorStrings.t('tts_unavailable', locale),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _ttsReady = false;
          _ttsFailed = true;
          _isSpeaking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LandmarkTranslatorStrings.t('tts_unavailable', locale),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copyArabic() {
    if (_arabicResult == null) return;
    // Snapshot at copy tap — confirmation snackbar matches locale when copied.
    final locale = ref.read(userLanguageProvider);
    Clipboard.setData(ClipboardData(text: _arabicResult!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LandmarkTranslatorStrings.t('copied_arabic', locale)),
        backgroundColor: AppColors.successBright,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareResult() {
    if (_arabicResult == null) return;
    Share.share(
      '📍 My Qatar Address (RAABTA Arabic Companion)\n\n'
      '🇬🇧 English:\n${_englishGps ?? _controller.text}\n\n'
      '🇶🇦 Arabic for driver:\n$_arabicResult\n\n'
      'Translated by RAABTA • ${CommonStrings.publicWebsiteHost}',
    );
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _arabicResult = null;
      _englishGps = null;
      _area = null;
      _confidence = null;
      _fromOfflineCache = false;
      _fromSharedCache = false;
      _errorMsg = null;
    });
  }

  // ── Init voice + load saved landmarks ───────────────
  Future<void> _initVoiceAndLandmarks() async {
    // Voice init — iOS and Android only
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        _speechAvailable = await _speech.initialize(
          onError: (_) =>
              setState(() => _isListening = false),
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              setState(() => _isListening = false);
            }
          },
        );
      } catch (_) {
        _speechAvailable = false;
      }
    }

    // Load saved landmarks
    await _loadSavedLandmarks();
  }

  Future<void> _loadSavedLandmarks() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _savedLandmarks = [];
          _loadingLandmarks = false;
        });
      }
      return;
    }

    setState(() { _loadingLandmarks = true; });
    try {
      final snapshot = await SavedLandmark.collectionForUser(uid)
          .orderBy('lastUsed', descending: true)
          .limit(8)
          .get();
      if (mounted) {
        setState(() {
          _savedLandmarks = snapshot.docs
              .map(SavedLandmark.fromFirestore)
              .toList();
        });
      }
    } catch (_) {
      // Landmarks unavailable — hide the panel silently
    } finally {
      if (mounted) setState(() { _loadingLandmarks = false; });
    }
  }

  // ── Toggle voice listening ───────────────────────────
  Future<void> _toggleListening() async {
    // Snapshot at listen start — STT locale + errors match language when mic opened.
    final locale = ref.read(userLanguageProvider);
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LandmarkTranslatorStrings.t('voice_unavailable', locale),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() { _isListening = false; });
      return;
    }

    setState(() { _isListening = true; });

    final sttLocale = LandmarkSttLocale.forAppLocale(locale);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        localeId: sttLocale,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  // ── Prefill from saved landmark ──────────────────────
  void _selectSavedLandmark(SavedLandmark landmark) {
    _controller.text = landmark.englishDescription;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() {
      _arabicResult = landmark.arabicDescription;
      _englishGps = landmark.englishDescription;
      _area = null;
      _confidence = 'high';
      _fromOfflineCache = false;
      _fromSharedCache = false;
      _errorMsg = null;
    });
  }

  // ── Open in ride app with clipboard fallback ─────────
  Future<void> _showNavigationRideSheet() async {
    if (_arabicResult == null) return;
    // Snapshot when ride sheet opens — labels match locale at open time.
    final locale = ref.read(userLanguageProvider);
    final uberAvailable = await RideLinkService.isUberInstalled();
    if (!mounted) return;

    await NavigationRideSheet.show(
      context,
      locale: locale,
      destinationQuery: _englishGps ?? _controller.text,
      arabicText: _arabicResult!,
      uberAvailable: uberAvailable,
      onSnack: (_) {},
    );
  }

  // ── Save current translation as a destination ────────
  void _saveCurrentAsDestination() {
    if (_arabicResult == null) return;
    // Snapshot at save tap — sheet + success snackbar match locale when saved.
    final locale = ref.read(userLanguageProvider);
    SaveLandmarkSheet.show(
      context,
      locale: locale,
      userId: ref.read(currentUserProvider)?.uid,
      englishDescription: _controller.text.trim(),
      arabicDescription: _arabicResult!,
      onSaved: () {
        _loadSavedLandmarks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LandmarkTranslatorStrings.t('destination_saved', locale),
            ),
            backgroundColor: AppColors.successBright,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final remainingAi = ref.watch(arabicCompanionRemainingAiProvider);
    final titleKey = widget.companionMode ? 'companion_translate_title' : 'title';
    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            LandmarkTranslatorStrings.t(titleKey, locale),
            style: AppTypography.title.copyWith(color: AppColors.textPrimary),
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_arabicResult != null)
            TextButton(
              onPressed: _reset,
              child: Text(
                LandmarkTranslatorStrings.t('clear', locale),
                style: AppTypography.button.copyWith(
                  color: AppColors.successBright,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            remainingAi.when(
              data: (remaining) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${LandmarkTranslatorStrings.t('ai_remaining', locale)}: $remaining',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            if (_savedLandmarks.isNotEmpty ||
                _loadingLandmarks) ...[
              SavedLandmarksList(
                locale: locale,
                landmarks:  _savedLandmarks,
                isLoading:  _loadingLandmarks,
                onSelect:   _selectSavedLandmark,
              ),
            ],
            GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 12,
              glowColor: AppColors.success,
              glowIntensity: 0.1,
              backgroundColor: AppColors.success.withValues(alpha: 0.07),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LandmarkTranslatorStrings.t('how_to_title', locale),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.isLight
                                ? AppColors.textPrimary
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LandmarkTranslatorStrings.t('how_to_body', locale),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassSecondary
                                : Colors.white.withValues(alpha: 0.55),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              LandmarkTranslatorStrings.t('input_label', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: LandmarkTranslatorStrings.inputHint(locale),
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.25),
                  height: 1.5,
                ),
                fillColor: AppColors.isLight
                    ? AppColors.glassSurface
                    : Colors.white.withValues(alpha: 0.05),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.isLight
                        ? AppColors.glassBorder
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.isLight
                        ? AppColors.glassBorder
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.successBright,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: (Platform.isIOS || Platform.isAndroid)
                    ? GestureDetector(
                        onTap: _toggleListening,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isListening
                                ? Container(
                                    key: const ValueKey('listening'),
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorBright
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.errorBright
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.mic_rounded,
                                      color: AppColors.errorBright,
                                      size: 18,
                                    ),
                                  )
                                : const Icon(
                                    key: ValueKey('idle'),
                                    Icons.mic_none_rounded,
                                    color: AppColors.successBright,
                                    size: 18,
                                  ),
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {
                _errorMsg = null;
              }),
            ),
            if (!Platform.isIOS && !Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  LandmarkTranslatorStrings.t('voice_mobile_only', locale),
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
            if (_isListening)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.errorBright,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LandmarkTranslatorStrings.t('listening', locale),
                      style: AppTypography.chipLabel.copyWith(
                        color: AppColors.errorBright,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Text(
              LandmarkTranslatorStrings.t(
                widget.companionMode
                    ? 'quick_translate_shortcuts'
                    : 'quick_landmarks',
                locale,
              ),
              style: AppTypography.overline.copyWith(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white38,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickChips.map((chip) {
                return GestureDetector(
                  onTap: () {
                    final current = _controller.text.trim();
                    _controller.text =
                        current.isEmpty ? chip : '$current, $chip';
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successBright.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.successBright.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '+ $chip',
                      style: AppTypography.chipLabel.copyWith(
                        color: AppColors.successBright,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_errorMsg != null) ...[
              GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: 10,
                glowColor: AppColors.error,
                glowIntensity: 0.1,
                backgroundColor: AppColors.error.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.errorBright,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.errorBright,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translate,
                icon: _isTranslating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isTranslating
                      ? LandmarkTranslatorStrings.t('translating_btn', locale)
                      : LandmarkTranslatorStrings.t('translate_btn', locale),
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successBright,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor:
                      AppColors.successBright.withValues(alpha: 0.4),
                ),
              ),
            ),
            if (_arabicResult != null) ...[
              const SizedBox(height: 28),
              if (_fromSharedCache) ...[
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 10,
                  glowColor: AppColors.cyanGlow,
                  glowIntensity: 0.08,
                  backgroundColor: AppColors.cyanGlow.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_done_outlined,
                        color: AppColors.cyanGlow,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LandmarkTranslatorStrings.t(
                            'shared_cache_banner',
                            locale,
                          ),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.cyanGlow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_fromOfflineCache) ...[
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 10,
                  glowColor: AppColors.amberGlow,
                  glowIntensity: 0.08,
                  backgroundColor: AppColors.amberGlow.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        color: AppColors.amberGlow,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LandmarkTranslatorStrings.t(
                            'offline_cache_banner',
                            locale,
                          ),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.amberGlow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_englishGps != null) ...[
                GlassContainer(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF00B4D8),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LandmarkTranslatorStrings.t('gps_label', locale),
                              style: AppTypography.overline.copyWith(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassMuted
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            if (_area != null && _area!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 14,
                                    color: AppColors.cyanGlow.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${LandmarkTranslatorStrings.t('area_label', locale)}: $_area',
                                    style: AppTypography.chipLabel.copyWith(
                                      color: AppColors.cyanGlow,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 3),
                            Text(
                              _englishGps!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassSecondary
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                borderRadius: 16,
                glowColor: AppColors.success,
                glowIntensity: 0.12,
                backgroundColor: AppColors.success.withValues(alpha: 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🇶🇦', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              LandmarkTranslatorStrings.t(
                                'arabic_for_driver',
                                locale,
                              ),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassMuted
                                    : Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                        _confidenceBadge(locale),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        _arabicResult!,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: AppTypography.title.copyWith(
                          color: AppColors.accentGold,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: _ttsReady || _isSpeaking
                                ? _speakArabic
                                : null,
                            icon: Icon(
                              _ttsFailed
                                  ? Icons.volume_off_rounded
                                  : _isSpeaking
                                      ? Icons.stop_rounded
                                      : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              _isSpeaking
                                  ? LandmarkTranslatorStrings.t('stop', locale)
                                  : LandmarkTranslatorStrings.t(
                                      'play_driver',
                                      locale,
                                    ),
                              style: AppTypography.chipLabel.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successBright,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _copyArabic,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              side: BorderSide(
                                color: AppColors.isLight
                                    ? AppColors.glassBorder
                                    : Colors.white.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(
                              Icons.copy_rounded,
                              color: AppColors.isLight
                                  ? AppColors.textTertiary
                                  : Colors.white54,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _shareResult,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              side: BorderSide(
                                color: AppColors.isLight
                                    ? AppColors.glassBorder
                                    : Colors.white.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              color: AppColors.isLight
                                  ? AppColors.textTertiary
                                  : Colors.white54,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Ride app row ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _showNavigationRideSheet,
                      icon: const Text(
                        '🚗',
                        style: TextStyle(fontSize: 16),
                      ),
                      label: Text(
                        LandmarkTranslatorStrings.t('nav_rides_btn', locale),
                        style: AppTypography.chipLabel.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000000),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _saveCurrentAsDestination,
                      icon: const Icon(
                        Icons.bookmark_add_rounded,
                        color: AppColors.successBright,
                        size: 16,
                      ),
                      label: Text(
                        LandmarkTranslatorStrings.t('save_btn', locale),
                        style: AppTypography.chipLabel.copyWith(
                          color: AppColors.successBright,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        side: const BorderSide(
                          color: AppColors.successBright,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  '💡 ${LandmarkTranslatorStrings.t('nav_hint', locale)}',
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  '💡 ${LandmarkTranslatorStrings.t('show_driver_hint', locale)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
      ),
    );
  }

  Widget _confidenceBadge(String locale) {
    final level = (_confidence ?? 'medium').toLowerCase();
    final Color color;
    final IconData icon;
    final String label;

    switch (level) {
      case 'high':
        color = AppColors.successBright;
        icon = Icons.check_circle;
        label = LandmarkTranslatorStrings.t('confidence_high', locale);
      case 'low':
        color = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        label = LandmarkTranslatorStrings.t('confidence_low', locale);
      default:
        color = AppColors.amberGlow;
        icon = Icons.info_outline;
        label = LandmarkTranslatorStrings.t('confidence_medium', locale);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTypography.chipLabel.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
