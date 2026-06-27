import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

// ─── THEME ─────────────────────────────────────────────

const _bgColor = Color(0xFF0D0826);
const _purple = Color(0xFF6C3FC5);
const _gold = Color(0xFFFFB627);

// ─── DATA MODELS ───────────────────────────────────────

class NutrientInfo {
  final String name;
  final String amount;
  final double per100g;
  final double dailyPct;

  const NutrientInfo({
    required this.name,
    required this.amount,
    required this.per100g,
    required this.dailyPct,
  });
}

class DecodedAdditive {
  final String code;
  final String plainName;
  final String status;
  final String reason;

  const DecodedAdditive({
    required this.code,
    required this.plainName,
    required this.status,
    required this.reason,
  });
}

class FoodHealthCard {
  final String barcode;
  final String productName;
  final String brand;
  final String? imageUrl;
  final int healthScore;
  final String verdict;
  final Color verdictColor;
  final String motivationalMessage;
  final String summary;
  final List<NutrientInfo> nutrients;
  final List<DecodedAdditive> additives;
  final String language;

  const FoodHealthCard({
    required this.barcode,
    required this.productName,
    required this.brand,
    this.imageUrl,
    required this.healthScore,
    required this.verdict,
    required this.verdictColor,
    required this.motivationalMessage,
    required this.summary,
    required this.nutrients,
    required this.additives,
    required this.language,
  });
}

class _RecentScanEntry {
  final String barcode;
  final String productName;
  final int healthScore;
  final Color scoreColor;

  const _RecentScanEntry({
    required this.barcode,
    required this.productName,
    required this.healthScore,
    required this.scoreColor,
  });
}

class _ExampleBarcodeEntry {
  final String code;
  final String label;
  final String emoji;

  const _ExampleBarcodeEntry({
    required this.code,
    required this.label,
    required this.emoji,
  });
}

// ─── SCREEN ────────────────────────────────────────────

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
  FoodHealthCard? _card;
  String? _error;
  String _language = 'English';
  final List<_RecentScanEntry> _recentScans = [];

  late AnimationController _animController;
  late Animation<double> _scoreAnim;

  static const _languages = [
    'English',
    'Arabic',
    'Hindi',
    'Tagalog',
    'Urdu',
    'Bengali',
  ];

  static const _langFlags = {
    'English': '🇬🇧',
    'Arabic': '🇶🇦',
    'Hindi': '🇮🇳',
    'Tagalog': '🇵🇭',
    'Urdu': '🇵🇰',
    'Bengali': '🇧🇩',
  };

  static const _qatarExamples = [
    _ExampleBarcodeEntry(
      code: '6291108730282',
      label: 'Almarai Fresh Milk',
      emoji: '🥛',
    ),
    _ExampleBarcodeEntry(
      code: '6291000130152',
      label: 'Al Ain Water',
      emoji: '💧',
    ),
    _ExampleBarcodeEntry(
      code: '5449000000996',
      label: 'Coca-Cola',
      emoji: '🥤',
    ),
    _ExampleBarcodeEntry(
      code: '8000500310427',
      label: 'Nutella',
      emoji: '🍫',
    ),
    _ExampleBarcodeEntry(
      code: '5000159484695',
      label: 'Maggi Noodles',
      emoji: '🍜',
    ),
  ];

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
    final code = _manualController.text.trim();
    if (code.isEmpty) {
      _snack('Enter a barcode number first');
      return;
    }
    FocusScope.of(context).unfocus();
    await _processBarcode(code);
  }

  Future<void> _processBarcode(String code) async {
    if (_loading) return;

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
      final product = await _fetchProduct(code);
      if (product == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Product not found for barcode $code.\nTry manual entry or another product.';
        });
        return;
      }

      final card = await _analyzeWithClaude(product, _language, code);
      if (!mounted) return;

      setState(() {
        _card = card;
      });
      _animController.forward(from: 0);
      _addRecentScan(card);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not analyze product. Check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _addRecentScan(FoodHealthCard card) {
    setState(() {
      _recentScans.removeWhere((s) => s.barcode == card.barcode);
      _recentScans.insert(
        0,
        _RecentScanEntry(
          barcode: card.barcode,
          productName: card.productName,
          healthScore: card.healthScore,
          scoreColor: card.verdictColor,
        ),
      );
      if (_recentScans.length > 5) {
        _recentScans.removeLast();
      }
    });
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

  Future<FoodHealthCard> _analyzeWithClaude(
    Map<String, dynamic> product,
    String language,
    String barcode,
  ) async {
    final productName = product['product_name'] ??
        product['product_name_en'] ??
        'Unknown Product';
    final brand = product['brands'] ?? 'N/A';
    final ingredients = product['ingredients_text'] ??
        product['ingredients_text_en'] ??
        '';
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    final imageUrl = product['image_url'] as String?;

    final prompt = '''
You are a food safety expert helping expats in Qatar understand food labels.
Analyze this product and respond ONLY with valid JSON — no markdown, no explanation.

Product: $productName
Brand: $brand
Barcode: $barcode
Ingredients: $ingredients
Nutriments (per 100g): ${jsonEncode(nutriments)}
Response language: $language

Return EXACTLY this structure:
{
  "healthScore": <integer 0-100>,
  "verdict": "<Excellent|Good|Moderate|Poor|Avoid>",
  "verdictHex": "<one of: #2DC653|#7BC67E|#FFB627|#FF6B35|#E63946>",
  "motivationalMessage": "<positive sentence max 14 words in $language>",
  "summary": "<2 sentences plain summary in $language — is it healthy? should they buy it?>",
  "nutrients": [
    {
      "name": "<nutrient name in $language>",
      "amount": "<value with unit e.g. 12g>",
      "per100g": <number>,
      "dailyPct": <0-100>
    }
  ],
  "additives": [
    {
      "code": "<E-number or name like MSG, Aspartame>",
      "plainName": "<what it does in $language, max 6 words>",
      "status": "<safe|caution|avoid>",
      "reason": "<one line why, in $language>"
    }
  ]
}

Scoring rules: 85-100=Excellent #2DC653, 70-84=Good #7BC67E, 50-69=Moderate #FFB627, 30-49=Poor #FF6B35, 0-29=Avoid #E63946
Include max 8 nutrients actually present in data.
Decode EVERY E-number and additive found in the ingredients.
motivationalMessage must always be positive and encouraging even for poor products.
For Arabic and Urdu use short RTL-friendly sentences.
''';

    final claudeService = ref.read(claudeAIServiceProvider);
    final rawResponse = await claudeService.sendMessage(
      prompt,
      language: language,
      requestType: 'food_inspector',
    );

    final clean = rawResponse
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw const FormatException('Invalid AI response');
    }

    final json =
        jsonDecode(clean.substring(start, end + 1)) as Map<String, dynamic>;

    final hexColor =
        (json['verdictHex'] as String? ?? '#FFB627').replaceAll('#', '');
    final color = Color(int.parse('FF$hexColor', radix: 16));

    final nutrients = (json['nutrients'] as List? ?? []).map((n) {
      final item = Map<String, dynamic>.from(n as Map);
      return NutrientInfo(
        name: item['name'] as String? ?? '',
        amount: item['amount'] as String? ?? '0g',
        per100g: (item['per100g'] as num?)?.toDouble() ?? 0,
        dailyPct: (item['dailyPct'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    final additives = (json['additives'] as List? ?? []).map((a) {
      final item = Map<String, dynamic>.from(a as Map);
      return DecodedAdditive(
        code: item['code'] as String? ?? '',
        plainName: item['plainName'] as String? ?? '',
        status: item['status'] as String? ?? 'caution',
        reason: item['reason'] as String? ?? '',
      );
    }).toList();

    return FoodHealthCard(
      barcode: barcode,
      productName: productName,
      brand: brand,
      imageUrl: imageUrl,
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 50,
      verdict: json['verdict'] as String? ?? 'Moderate',
      verdictColor: color,
      motivationalMessage: json['motivationalMessage'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      nutrients: nutrients,
      additives: additives,
      language: language,
    );
  }

  Future<void> _saveToGallery() async {
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
      _snack('✅ Health Card saved to gallery!');
    } catch (_) {
      _snack('Could not save. Try again.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareCard() async {
    setState(() => _exporting = true);
    try {
      final bytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/raabta_health_card.png')
        ..writeAsBytesSync(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '🥗 ${_card?.productName} — Health Score: ${_card?.healthScore}/100\n\nScanned by RAABTA • raabta.app',
        subject: 'RAABTA Food Health Card',
      );
    } catch (_) {
      _snack('Could not share. Try again.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _resetScan() async {
    setState(() {
      _scanning = true;
      _card = null;
      _error = null;
      _loading = false;
      _showManualEntry = !_cameraAvailable;
    });
    _animController.reset();
    _manualController.clear();
    if (_cameraAvailable && _scannerController != null) {
      await _scannerController!.start();
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A1035),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: _loading
          ? _buildLoadingView()
          : _error != null
              ? _buildErrorView()
              : _card != null
                  ? _buildResultView()
                  : _buildScannerView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text(
        'Food Inspector',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _purple.withValues(alpha: 0.55)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _language,
              dropdownColor: const Color(0xFF1A1035),
              icon: const Icon(Icons.keyboard_arrow_down, color: _gold, size: 18),
              items: _languages
                  .map(
                    (l) => DropdownMenuItem(
                      value: l,
                      child: Text(
                        '${_langFlags[l]} $l',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _language = v);
              },
            ),
          ),
        ),
        if (_card != null)
          TextButton(
            onPressed: _resetScan,
            child: const Text(
              'Rescan',
              style: TextStyle(
                color: _gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _purple.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.translate, color: _gold, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Results in: ${_langFlags[_language]} $_language',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ),
              if (_cameraAvailable)
                GestureDetector(
                  onTap: () => setState(() => _showManualEntry = !_showManualEntry),
                  child: Text(
                    _showManualEntry ? 'Camera' : 'Manual',
                    style: const TextStyle(
                      color: _gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_cameraAvailable && !_showManualEntry)
          Expanded(
            child: Stack(
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
                                color: _gold,
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
                                child: const Text(
                                  'Enter barcode manually',
                                  style: TextStyle(color: _gold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const _ScanOverlay(),
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
                              ? _gold
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                        color: _torchOn ? _gold : Colors.white,
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
                      child: const Text(
                        'Point at any product barcode\nNutrients + chemicals decoded instantly',
                        style: TextStyle(
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
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_cameraAvailable) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _purple.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.desktop_mac_rounded,
                            color: _gold,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Camera not available on desktop',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter a barcode below or tap a popular Qatar product',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Popular in Qatar',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._qatarExamples.map(
                      (e) => _ExampleBarcode(
                        example: e,
                        onTap: () => _processBarcode(e.code),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildManualEntryField(),
                ],
              ),
            ),
          ),
        if (_cameraAvailable && !_showManualEntry && _recentScans.isNotEmpty)
          _buildRecentScansStrip(),
        if (_showManualEntry && _cameraAvailable) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _buildManualEntryField(),
          ),
          if (_recentScans.isNotEmpty) _buildRecentScansStrip(),
        ],
      ],
    );
  }

  Widget _buildManualEntryField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _manualController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter barcode number',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _purple.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _purple.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _gold, width: 1.5),
              ),
              prefixIcon: Icon(
                Icons.qr_code_2_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 20,
              ),
            ),
            onSubmitted: (_) => _onManualSubmit(),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: _purple,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _onManualSubmit,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentScansStrip() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _recentScans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final scan = _recentScans[i];
          return _RecentScan(
            scan: scan,
            onTap: () => _processBarcode(scan.barcode),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: _purple,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 24),
          const Text(
            '🔬 Analyzing ingredients...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Decoding chemicals & calculating health score',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Color(0xFFE63946),
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final card = _card!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Barcode: ${card.barcode}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
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
                    color: _gold,
                    strokeWidth: 2,
                  ),
                )
              else
                Row(
                  children: [
                    _ExportBtn(
                      icon: Icons.download_rounded,
                      label: 'Save',
                      color: _purple,
                      onTap: _saveToGallery,
                    ),
                    const SizedBox(width: 8),
                    _ExportBtn(
                      icon: Icons.share_rounded,
                      label: 'Share',
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
              child: _HealthCardWidget(card: card, scoreAnim: _scoreAnim),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SCAN OVERLAY ──────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const frameW = 270.0;
        const frameH = 130.0;
        final left = (constraints.maxWidth - frameW) / 2;
        final top = (constraints.maxHeight - frameH) / 2;
        final scanRect = Rect.fromLTWH(left, top, frameW, frameH);

        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _OverlayPainter(scanRect: scanRect),
            ),
            Positioned(
              left: left,
              top: top,
              width: frameW,
              height: frameH,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _purple, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const _Corner(alignment: Alignment.topLeft),
                  const _Corner(alignment: Alignment.topRight),
                  const _Corner(alignment: Alignment.bottomLeft),
                  const _Corner(alignment: Alignment.bottomRight),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({required this.scanRect});

  final Rect scanRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanRect, const Radius.circular(12)),
      );
    final overlayPath = Path.combine(PathOperation.difference, fullPath, cutout);
    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect;
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(painter: _CornerPainter(alignment: alignment)),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.alignment});

  final Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gold
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? 16.0 : -16.0;
    final dy = isTop ? 16.0 : -16.0;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}

// ─── HEALTH CARD ───────────────────────────────────────

class _HealthCardWidget extends StatelessWidget {
  const _HealthCardWidget({required this.card, required this.scoreAnim});

  final FoodHealthCard card;
  final Animation<double> scoreAnim;

  bool get _isRtl => card.language == 'Arabic' || card.language == 'Urdu';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: card.verdictColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  card.verdictColor.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          card.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(width: 60),
                        ),
                      ),
                    if (card.imageUrl != null) const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.productName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.brand,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Barcode: ${card.barcode}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: card.verdictColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: card.verdictColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              card.verdict,
                              style: TextStyle(
                                color: card.verdictColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    _ScoreRing(
                      score: card.healthScore,
                      color: card.verdictColor,
                      anim: scoreAnim,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: card.verdictColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: card.verdictColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '✨ ${card.motivationalMessage}',
                    textAlign: _isRtl ? TextAlign.right : TextAlign.center,
                    textDirection:
                        _isRtl ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      color: card.verdictColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  card.summary,
                  textAlign: _isRtl ? TextAlign.right : TextAlign.left,
                  textDirection:
                      _isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          if (card.nutrients.isNotEmpty) ...[
            _SectionTitle('📊  Nutrition per 100g', _isRtl),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: card.nutrients
                    .map((n) => _NutrientBar(n: n, isRtl: _isRtl))
                    .toList(),
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
          ],
          if (card.additives.isNotEmpty) ...[
            _SectionTitle('🧪  Additives Decoded', _isRtl),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: card.additives
                    .map((a) => _AdditiveRow(a: a, isRtl: _isRtl))
                    .toList(),
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: _purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'R',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Scanned by RAABTA  •  raabta.app',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.color,
    required this.anim,
  });

  final int score;
  final Color color;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) => SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: (score / 100) * anim.value,
              strokeWidth: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              color: color,
              strokeCap: StrokeCap.round,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(score * anim.value).round()}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    height: 1,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.isRtl);

  final String text;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Align(
        alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({required this.n, required this.isRtl});

  final NutrientInfo n;
  final bool isRtl;

  Color get _color {
    if (n.dailyPct < 10) return const Color(0xFF2DC653);
    if (n.dailyPct < 25) return const Color(0xFF7BC67E);
    if (n.dailyPct < 50) return const Color(0xFFFFB627);
    return const Color(0xFFE63946);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: Text(
                  n.name,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                n.amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '${n.dailyPct.round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (n.dailyPct / 100).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditiveRow extends StatelessWidget {
  const _AdditiveRow({required this.a, required this.isRtl});

  final DecodedAdditive a;
  final bool isRtl;

  Color get _color {
    switch (a.status) {
      case 'safe':
        return const Color(0xFF2DC653);
      case 'avoid':
        return const Color(0xFFE63946);
      default:
        return const Color(0xFFFFB627);
    }
  }

  String get _icon {
    switch (a.status) {
      case 'safe':
        return '🟢';
      case 'avoid':
        return '🔴';
      default:
        return '🟡';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              a.code,
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  a.plainName,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.reason,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_icon, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _ExportBtn extends StatelessWidget {
  const _ExportBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentScan extends StatelessWidget {
  const _RecentScan({required this.scan, required this.onTap});

  final _RecentScanEntry scan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: scan.scoreColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scan.scoreColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scan.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${scan.healthScore}',
                  style: TextStyle(
                    color: scan.scoreColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleBarcode extends StatelessWidget {
  const _ExampleBarcode({required this.example, required this.onTap});

  final _ExampleBarcodeEntry example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _purple.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Text(example.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        example.code,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _gold.withValues(alpha: 0.6),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
