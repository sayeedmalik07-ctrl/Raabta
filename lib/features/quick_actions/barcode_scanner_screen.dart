import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:screenshot/screenshot.dart';

import 'package:raabta/services/sharing/models/shareable_card_data.dart' as share;
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

import 'barcode_scanner/data/qatar_example_barcodes.dart';
import 'barcode_scanner/food_local_analyzer.dart';
import 'barcode_scanner/l10n/food_inspector_strings.dart';
import 'barcode_scanner/models/dietary_profile.dart';
import 'barcode_scanner/models/food_health_card.dart';
import 'barcode_scanner/models/scan_error_kind.dart';
import 'barcode_scanner/services/food_inspector_analysis_service.dart';
import 'barcode_scanner/services/food_scan_history_repository.dart';
import 'barcode_scanner/widgets/example_barcode_tile.dart';
import 'barcode_scanner/widgets/export_btn.dart';
import 'barcode_scanner/widgets/expiry_date_scan_sheet.dart';
import 'barcode_scanner/widgets/food_health_card_widget.dart';
import 'barcode_scanner/widgets/food_inspector_empty_state.dart';
import 'barcode_scanner/widgets/food_inspector_primitives.dart';
import 'barcode_scanner/widgets/food_inspector_theme.dart';
import 'barcode_scanner/widgets/recent_scan_strip.dart';
import 'barcode_scanner/widgets/scan_overlay.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  final _screenshotController = ScreenshotController();
  final _manualController = TextEditingController();

  bool _scanning = true;
  bool _loading = false;
  bool _exporting = false;
  bool _torchOn = false;
  bool _cameraAvailable = false;
  bool _showManualEntry = false;
  bool _profilePromptShown = false;
  FoodHealthCard? _card;
  String? _error;
  ScanErrorKind? _errorKind;
  Map<String, dynamic>? _lastProduct;
  String? _lastBarcode;
  List<FoodScanHistoryEntry> _recentScans = [];
  DietaryProfile? _dietaryProfile;

  late AnimationController _animController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _checkCameraAvailability();
    _loadDietaryProfile();
    _loadScanHistory();
    ref.listenManual(userLanguageProvider, (previous, next) {
      if (previous == next) return;
      if (_lastProduct != null &&
          _lastBarcode != null &&
          _card != null &&
          !_loading) {
        _reanalyzeForLocaleChange();
      }
    });
  }

  Future<void> _loadScanHistory() async {
    final entries = await FoodScanHistoryRepository.load();
    if (mounted) setState(() => _recentScans = entries);
  }

  Future<void> _reanalyzeForLocaleChange() async {
    final product = _lastProduct;
    final barcode = _lastBarcode;
    if (product == null || barcode == null) return;

    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    setState(() => _loading = true);
    try {
      final card = await _analyzeProduct(product, locale, barcode);
      if (!mounted) return;
      setState(() => _card = card);
      _animController.forward(from: 0);
      _feedbackForScanResult(card);
    } catch (_) {
      // Keep previous card if re-analysis fails.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadDietaryProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(DietaryProfile.firestoreCollection)
          .doc('current_user')
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _dietaryProfile = DietaryProfile.fromFirestore(doc);
        });
      }
    } catch (_) {
      // Profile unavailable — scan without personalization
    }
  }

  void _checkCameraAvailability() {
    if (Platform.isIOS || Platform.isAndroid) {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
      _cameraAvailable = true;
    } else {
      _cameraAvailable = false;
      _showManualEntry = true;
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _manualController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    if (_scannerController == null) return;
    await _scannerController!.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _loading) return;
    final code = capture.barcodes.isNotEmpty
        ? capture.barcodes.first.rawValue
        : null;
    if (code == null || code.isEmpty) return;
    await _processBarcode(code);
  }

  Future<void> _onManualSubmit() async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final code = _manualController.text.trim();
    if (code.isEmpty) {
      _snack(FoodInspectorStrings.t('snack_enter_barcode', locale));
      return;
    }
    FocusScope.of(context).unfocus();
    await _processBarcode(code);
  }

  Future<void> _processBarcode(String code) async {
    if (_loading) return;
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));

    // Optional profile setup — never block scanning indefinitely.
    if (_dietaryProfile == null && !_profilePromptShown) {
      _profilePromptShown = true;
      try {
        final profileDoc = await FirebaseFirestore.instance
            .collection(DietaryProfile.firestoreCollection)
            .doc('current_user')
            .get()
            .timeout(const Duration(seconds: 3));
        if (!profileDoc.exists && mounted) {
          await context.push('/dietary-profile');
          await _loadDietaryProfile();
        } else if (profileDoc.exists) {
          _dietaryProfile = DietaryProfile.fromFirestore(profileDoc);
        }
      } catch (_) {
        // Firestore unavailable — continue without personalization.
      }
    }

    setState(() {
      _scanning = false;
      _loading = true;
      _error = null;
      _card = null;
    });

    if (_scannerController != null) {
      await _scannerController!.stop();
    }

    try {
      _lastBarcode = code;
      final product = await _fetchProduct(code);
      if (product == null) {
        if (!mounted) return;
        setState(() {
          _error = FoodInspectorStrings.format(
            'error_product_not_found',
            locale,
            {'code': code},
          );
          _errorKind = ScanErrorKind.notFound;
        });
        return;
      }

      _lastProduct = product;

      final card = await _analyzeProduct(product, locale, code);
      if (!mounted) return;

      setState(() => _card = card);
      _animController.forward(from: 0);
      _feedbackForScanResult(card);
      await _addRecentScan(card);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FoodInspectorStrings.t('error_analyze_failed', locale);
        _errorKind = ScanErrorKind.analyzeFailed;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _feedbackForScanResult(FoodHealthCard card) {
    foodInspectorScanCompleteHaptic();
    if (card.allergyWarnings.isNotEmpty) foodInspectorAllergenHaptic();
  }

  Future<void> _addRecentScan(FoodHealthCard card) async {
    await FoodScanHistoryRepository.save(
      barcode: card.barcode,
      productName: card.productName,
      healthScore: card.healthScore,
      scoreColor: card.verdictColor,
    );
    final entries = await FoodScanHistoryRepository.load();
    if (mounted) setState(() => _recentScans = entries);
  }

  Future<Map<String, dynamic>?> _fetchProduct(String barcode) async {
    final res = await http
        .get(
          Uri.parse(
            'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
          ),
        )
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['status'] != 1) return null;
    return data['product'] as Map<String, dynamic>;
  }

  Future<FoodHealthCard> _analyzeProduct(
    Map<String, dynamic> product,
    String locale,
    String barcode,
  ) async {
    try {
      final claudeService = ref.read(claudeAIServiceProvider);
      final analysisService = foodInspectorAnalysisServiceFactory(claudeService);
      final local = await analysisService.analyze(
        product: product,
        language: locale,
        profile: _dietaryProfile,
      );
      return _healthCardFromLocalAnalysis(
        local: local,
        product: product,
        locale: locale,
        barcode: barcode,
      );
    } catch (_) {
      return _buildLocalHealthCard(product, locale, barcode);
    }
  }

  FoodHealthCard _healthCardFromLocalAnalysis({
    required LocalFoodAnalysis local,
    required Map<String, dynamic> product,
    required String locale,
    required String barcode,
  }) {
    final productName = product['product_name'] ??
        product['product_name_en'] ??
        FoodInspectorStrings.t('unknown_product', locale);
    final brand = product['brands'] ?? 'N/A';
    final imageUrl = product['image_url'] as String?;

    return FoodHealthCard(
      barcode: barcode,
      productName: productName.toString(),
      brand: brand.toString(),
      imageUrl: imageUrl,
      healthScore: local.healthScore,
      verdict: local.verdict,
      verdictColor: local.verdictColor,
      motivationalMessage: local.motivationalMessage,
      summary: local.summary,
      nutrients: local.nutrients
          .map(
            (n) => NutrientInfo(
              name: n.name,
              amount: n.amount,
              per100g: n.per100g,
              dailyPct: n.dailyPct,
            ),
          )
          .toList(),
      additives: local.additives
          .map(
            (a) => DecodedAdditive(
              code: a.code,
              plainName: a.plainName,
              status: a.status,
              reason: a.reason,
            ),
          )
          .toList(),
      language: locale,
      allergyWarnings: local.allergyWarnings,
      halalInfo: local.halalInfo,
    );
  }

  FoodHealthCard _buildLocalHealthCard(
    Map<String, dynamic> product,
    String locale,
    String barcode,
  ) {
    final local = FoodLocalAnalyzer.analyze(
      product: product,
      language: locale,
      profile: _dietaryProfile,
    );
    return _healthCardFromLocalAnalysis(
      local: local,
      product: product,
      locale: locale,
      barcode: barcode,
    );
  }

  Future<void> _saveToGallery() async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    setState(() => _exporting = true);
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      final bytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (bytes == null) return;
      await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 95,
        name: 'RAABTA_HealthCard_${DateTime.now().millisecondsSinceEpoch}',
      );
      _snack(FoodInspectorStrings.t('snack_saved_gallery', locale));
    } catch (_) {
      _snack(FoodInspectorStrings.t('snack_save_failed', locale));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareCard() async {
    if (_card == null) return;

    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final card = _card!;
    final shareData = share.HealthScoreCardData(
      productName:         card.productName,
      brand:               card.brand,
      productImageUrl:     card.imageUrl,
      healthScore:         card.healthScore,
      verdict:             card.verdict,
      verdictColor:        card.verdictColor,
      motivationalMessage: card.motivationalMessage,
      topNutrients: card.nutrients
          .take(4)
          .map((n) => share.NutrientRow(
                name:     n.name,
                amount:   n.amount,
                dailyPct: n.dailyPct,
              ))
          .toList(),
      topAdditives: card.additives
          .take(3)
          .map((a) => share.AdditiveRow(
                code:      a.code,
                plainName: a.plainName,
                status:    a.status,
              ))
          .toList(),
      halalSnapshot:   _halalShareSnapshot(card),
      allergyWarnings: card.allergyWarnings,
      language:        card.language,
      shareCaption: FoodInspectorStrings.format(
        'share_caption',
        locale,
        {
          'emoji': '🥗',
          'product': card.productName,
          'score': '${card.healthScore}',
          'host': CommonStrings.publicWebsiteHost,
        },
      ),
    );

    await ShareCardSheet.show(context, shareData);
  }

  share.HalalShareSnapshot _halalShareSnapshot(FoodHealthCard card) {
    return share.HalalShareSnapshot(
      communityLabels: card.halalInfo.communityLabels,
      hasCommunityData: card.halalInfo.hasCommunityHalalData,
    );
  }

  Future<void> _resetScan() async {
    setState(() {
      _scanning = true;
      _card = null;
      _error = null;
      _errorKind = null;
      _loading = false;
      _lastProduct = null;
      _lastBarcode = null;
      _showManualEntry = !_cameraAvailable;
    });
    _animController.reset();
    _manualController.clear();
    if (_cameraAvailable && _scannerController != null) {
      await _scannerController!.start();
    }
  }

  void _openManualAfterError() {
    setState(() {
      _error = null;
      _errorKind = null;
      _showManualEntry = true;
      _scanning = true;
    });
    _manualController.clear();
    _scannerController?.start();
  }

  Future<void> _retryLastScan() async {
    final barcode = _lastBarcode;
    if (barcode != null && _errorKind == ScanErrorKind.analyzeFailed) {
      setState(() {
        _error = null;
        _errorKind = null;
      });
      await _processBarcode(barcode);
      return;
    }
    await _resetScan();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: FoodInspectorStrings.t('screen_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: _buildAppBarActions(locale),
        safeArea: _card != null,
        body: _card != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildResultView(locale),
                  if (_loading) _buildResultLoadingOverlay(locale),
                ],
              )
            : _buildScannerView(locale),
      ),
    );
  }

  List<Widget> _buildAppBarActions(String locale) {
    return [
      if (_card != null) ...[
        TextButton(
          onPressed: () => context.push('/dietary-profile'),
          child: Text(
            FoodInspectorStrings.t('edit_dietary_profile', locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassSecondary
                  : Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        TextButton(
          onPressed: _resetScan,
          child: Text(
            FoodInspectorStrings.t('rescan', locale),
            style: AppTypography.button.copyWith(color: foodInspectorGold),
          ),
        ),
      ],
      const SizedBox(width: 8),
    ];
  }

  Widget _buildScannerView(String locale) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderRadius: 10,
            glowColor: foodInspectorPurple,
            glowIntensity: 0.08,
            backgroundColor: foodInspectorPurple.withValues(alpha: 0.08),
            child: Row(
            children: [
              const Icon(Icons.translate, color: foodInspectorGold, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  FoodInspectorStrings.format(
                    'results_in',
                    locale,
                    {'language': AppLocale.toPickerLabel(locale)},
                  ),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassSecondary
                        : Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ),
              if (_cameraAvailable)
                GestureDetector(
                  onTap: () => setState(() => _showManualEntry = !_showManualEntry),
                  child: Text(
                    _showManualEntry
                        ? FoodInspectorStrings.t('camera', locale)
                        : FoodInspectorStrings.t('manual', locale),
                    style: const TextStyle(
                      color: foodInspectorGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
            ),
          ),
        ),
        Expanded(child: _buildScannerMainPanel(locale)),
        if (_showManualEntry &&
            _cameraAvailable &&
            !_loading &&
            _error == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _buildManualEntryField(locale),
          ),
        if (_recentScans.isNotEmpty && !_loading) _buildRecentScansStrip(),
        if (!_loading && _error == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: GlassSecondaryButton(
                label: FoodInspectorStrings.t('expiry_scan_entry', locale),
                icon: Icons.event_outlined,
                onPressed: () => ExpiryDateScanSheet.show(context, locale),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScannerMainPanel(String locale) {
    if (_loading) {
      return _buildInlineLoadingPanel(locale);
    }
    if (_error != null) {
      return _buildInlineErrorPanel(locale);
    }
    if (_cameraAvailable && !_showManualEntry) {
      return Stack(
        children: [
          MobileScanner(
            controller: _scannerController!,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.videocam_off_rounded,
                          color: foodInspectorGold,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error.errorCode.message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              setState(() => _showManualEntry = true),
                          child: Text(
                            FoodInspectorStrings.t(
                              'enter_barcode_manually',
                              locale,
                            ),
                            style: const TextStyle(color: foodInspectorGold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const ScanOverlay(),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleTorch,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _torchOn
                        ? foodInspectorGold
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                  color: _torchOn ? foodInspectorGold : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  FoodInspectorStrings.t('scan_hint', locale),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_cameraAvailable) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: 16,
              glowColor: foodInspectorPurple,
              glowIntensity: 0.1,
              backgroundColor: foodInspectorPurple.withValues(alpha: 0.1),
              child: Column(
                children: [
                  const Icon(
                    Icons.desktop_mac_rounded,
                    color: foodInspectorGold,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    FoodInspectorStrings.t('desktop_no_camera_title', locale),
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textPrimary
                          : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    FoodInspectorStrings.t('desktop_no_camera_body', locale),
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassSecondary
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              FoodInspectorStrings.t('popular_in_qatar', locale),
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ...qatarExampleBarcodes.map(
              (e) => ExampleBarcodeTile(
                example: e,
                onTap: () => _processBarcode(e.code),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildManualEntryField(locale),
        ],
      ),
    );
  }

  Widget _buildInlineLoadingPanel(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          glowColor: foodInspectorPurple,
          glowIntensity: 0.12,
          backgroundColor: foodInspectorPurple.withValues(alpha: 0.08),
          child: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: foodInspectorGold,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FoodInspectorStrings.t('loading_title', locale),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FoodInspectorStrings.t('loading_subtitle', locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineErrorPanel(String locale) {
    final isNotFound = _errorKind == ScanErrorKind.notFound;
    return FoodInspectorEmptyState(
      compact: true,
      icon: isNotFound ? Icons.search_off_rounded : Icons.wifi_off_rounded,
      title: FoodInspectorStrings.t(
        isNotFound ? 'empty_not_found_title' : 'empty_analyze_title',
        locale,
      ),
      description: _error!,
      primaryActionLabel: FoodInspectorStrings.t('try_again', locale),
      onPrimaryAction: () => unawaited(_retryLastScan()),
      secondaryActionLabel: isNotFound
          ? FoodInspectorStrings.t('enter_barcode_manually', locale)
          : null,
      onSecondaryAction: isNotFound ? _openManualAfterError : null,
    );
  }

  Widget _buildResultLoadingOverlay(String locale) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildInlineLoadingPanel(locale),
        ),
      ),
    );
  }

  Widget _buildManualEntryField(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassTextField(
          controller: _manualController,
          hint: FoodInspectorStrings.t('hint_barcode', locale),
          icon: Icons.qr_code_2_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _onManualSubmit(),
        ),
        const SizedBox(height: 12),
        GlassPrimaryButton(
          label: FoodInspectorStrings.t('search', locale),
          icon: Icons.search,
          expand: true,
          accentColor: foodInspectorPurple,
          onPressed: _loading ? null : _onManualSubmit,
        ),
      ],
    );
  }

  Widget _buildRecentScansStrip() {
    return RecentScanStrip(
      scans: _recentScans,
      onScanTap: _processBarcode,
    );
  }

  Widget _buildResultView(String locale) {
    final card = _card!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.isLight
                ? AppColors.glassSurface
                : Colors.white.withValues(alpha: 0.03),
            border: Border(
              bottom: BorderSide(
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      FoodInspectorStrings.format(
                        'barcode_label',
                        locale,
                        {'code': card.barcode},
                      ),
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textOnGlassMuted
                            : Colors.white.withValues(alpha: 0.35),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_exporting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: foodInspectorGold,
                    strokeWidth: 2,
                  ),
                )
              else
                Row(
                  children: [
                    ExportBtn(
                      icon: Icons.download_rounded,
                      label: FoodInspectorStrings.t('save', locale),
                      color: foodInspectorPurple,
                      onTap: _saveToGallery,
                    ),
                    const SizedBox(width: 8),
                    ExportBtn(
                      icon: Icons.share_rounded,
                      label: FoodInspectorStrings.t('share', locale),
                      color: const Color(0xFF25D366),
                      onTap: _shareCard,
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Screenshot(
              controller: _screenshotController,
              child: FoodHealthCardWidget(
                card: card,
                scoreAnim: _scoreAnim,
                locale: locale,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
