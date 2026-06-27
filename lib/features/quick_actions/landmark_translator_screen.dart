import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:share_plus/share_plus.dart';

class LandmarkTranslatorScreen extends ConsumerStatefulWidget {
  const LandmarkTranslatorScreen({super.key});

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
  String? _errorMsg;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('ar-QA');
    await _tts.setSpeechRate(0.65);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _translate() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMsg = 'Please enter your address or landmark description.';
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _arabicResult = null;
      _englishGps = null;
      _errorMsg = null;
    });

    try {
      final claudeService = ref.read(claudeAIServiceProvider);

      final prompt = '''
You are a Qatar address and navigation expert helping expats communicate 
locations to local taxi and Careem drivers.

Convert this English landmark description into natural Arabic that a 
Qatar taxi driver would immediately understand. Also provide a clean 
English GPS description.

Input address: "$input"

Respond ONLY with valid JSON, no markdown, no explanation:
{
  "arabic": "<natural Arabic address a Qatar driver understands, using local landmark names>",
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
        requestType: 'landmark_translator',
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

      setState(() {
        _arabicResult = json['arabic'] as String? ?? 'خطأ في الترجمة';
        _englishGps = json['englishGps'] as String? ?? input;
      });
    } catch (_) {
      setState(() {
        _errorMsg = 'Translation failed. Check your connection and try again.';
      });
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  Future<void> _speakArabic() async {
    if (_arabicResult == null) return;
    if (_isSpeaking) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }
    setState(() {
      _isSpeaking = true;
    });
    await _tts.setLanguage('ar-QA');
    await _tts.speak(_arabicResult!);
  }

  void _copyArabic() {
    if (_arabicResult == null) return;
    Clipboard.setData(ClipboardData(text: _arabicResult!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arabic address copied to clipboard'),
        backgroundColor: Color(0xFF2DC653),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareResult() {
    if (_arabicResult == null) return;
    Share.share(
      '📍 My Qatar Address (RAABTA Landmark Translator)\n\n'
      '🇬🇧 English:\n${_englishGps ?? _controller.text}\n\n'
      '🇶🇦 Arabic for driver:\n$_arabicResult\n\n'
      'Translated by RAABTA • raabta.app',
    );
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _arabicResult = null;
      _englishGps = null;
      _errorMsg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0826),
        elevation: 0,
        title: const Text(
          'Landmark Translator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_arabicResult != null)
            TextButton(
              onPressed: _reset,
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Color(0xFF2DC653),
                  fontWeight: FontWeight.w700,
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2DC653).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2DC653).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to use',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Type your address using English landmarks. '
                          'RAABTA translates it to Arabic and reads it '
                          'aloud so your taxi or Careem driver understands '
                          'instantly — even without a street address.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
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
            const Text(
              'Your address or landmark',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g. Villa 23, opposite Lulu Hypermarket, '
                    'Street 12, near the mosque, Al Khor',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 13,
                  height: 1.5,
                ),
                fillColor: Colors.white.withValues(alpha: 0.05),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF2DC653),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (_) => setState(() {
                _errorMsg = null;
              }),
            ),
            const SizedBox(height: 14),
            const Text(
              'Quick add Qatar landmarks:',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
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
                      color: const Color(0xFF2DC653).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2DC653).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '+ $chip',
                      style: const TextStyle(
                        color: Color(0xFF2DC653),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_errorMsg != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE63946).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE63946),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: Color(0xFFE63946),
                          fontSize: 12,
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
                      ? 'Translating with AI...'
                      : 'Translate to Arabic',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DC653),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor:
                      const Color(0xFF2DC653).withValues(alpha: 0.4),
                ),
              ),
            ),
            if (_arabicResult != null) ...[
              const SizedBox(height: 28),
              if (_englishGps != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
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
                              'GPS Description',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _englishGps!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2DC653).withValues(alpha: 0.12),
                      const Color(0xFF2DC653).withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2DC653).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
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
                              'Arabic for your driver',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF2DC653).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF2DC653),
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Ready',
                                style: TextStyle(
                                  color: Color(0xFF2DC653),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        _arabicResult!,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFFFFB627),
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
                            onPressed: _speakArabic,
                            icon: Icon(
                              _isSpeaking
                                  ? Icons.stop_rounded
                                  : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              _isSpeaking ? 'Stop' : '▶  Play for Driver',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2DC653),
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
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              color: Colors.white54,
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
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '💡 Show this screen to your driver or tap Play',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
